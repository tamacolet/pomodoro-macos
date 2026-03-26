import Foundation
import Combine
import AppKit

/// ポモドーロタイマーの中核ViewModel
/// 現在時刻ベースで残り時間を計算し、スリープ復帰にも対応
@MainActor
final class PomodoroViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var timerState: TimerState = .idle
    @Published var currentSession: SessionType = .focus
    @Published var timeRemaining: TimeInterval = 0
    @Published var progress: Double = 0.0  // 0.0 ~ 1.0
    @Published var completedPomodoros: Int = 0
    @Published var currentSetIndex: Int = 0  // 現在のセット（0始まり）

    // MARK: - Dependencies

    let settings: PomodoroSettings

    // MARK: - Private Properties

    private var timer: Timer?
    private var endDate: Date?
    private var totalDuration: TimeInterval = 0
    private var pausedTimeRemaining: TimeInterval = 0
    private var cancellables = Set<AnyCancellable>()
    private var wakeObserver: Any?

    // MARK: - Computed Properties

    /// 今日の完了ポモドーロ数（UserDefaultsから取得）
    var todayCompletedCount: Int {
        let key = "completedPomodoros_\(DateUtils.todayKey)"
        return UserDefaults.standard.integer(forKey: key)
    }

    /// メニューバー表示用テキスト
    var menuBarText: String {
        switch timerState {
        case .idle:
            return "🍅"
        case .running, .paused:
            let icon = currentSession == .focus ? "🍅" : "☕"
            let time = DateUtils.formatTimeShort(timeRemaining)
            let state = timerState == .paused ? "⏸" : ""
            return "\(icon) \(time)\(state)"
        }
    }

    // MARK: - Init

    init(settings: PomodoroSettings) {
        self.settings = settings
        self.timeRemaining = settings.duration(for: .focus)
        self.totalDuration = settings.duration(for: .focus)
        setupWakeNotification()
    }

    deinit {
        timer?.invalidate()
        if let observer = wakeObserver {
            NSWorkspace.shared.notificationCenter.removeObserver(observer)
        }
    }

    // MARK: - Public Actions

    /// 開始
    func start() {
        guard timerState != .running else { return }

        if timerState == .idle {
            // 新規開始
            totalDuration = settings.duration(for: currentSession)
            timeRemaining = totalDuration
        }

        // 終了予定時刻を計算
        let remaining = timerState == .paused ? pausedTimeRemaining : timeRemaining
        endDate = Date().addingTimeInterval(remaining)
        timerState = .running

        startDisplayTimer()
    }

    /// 一時停止
    func pause() {
        guard timerState == .running else { return }
        pausedTimeRemaining = timeRemaining
        timerState = .paused
        stopDisplayTimer()
        endDate = nil
    }

    /// 開始/一時停止トグル
    func toggleStartPause() {
        switch timerState {
        case .idle, .paused:
            start()
        case .running:
            pause()
        }
    }

    /// リセット
    func reset() {
        stopDisplayTimer()
        timerState = .idle
        endDate = nil
        pausedTimeRemaining = 0
        totalDuration = settings.duration(for: currentSession)
        timeRemaining = totalDuration
        progress = 0.0
    }

    /// スキップ（現在のセッションを完了扱いにして次へ）
    func skip() {
        completeCurrentSession()
    }

    // MARK: - Private Methods

    /// ディスプレイ更新用タイマーを開始（0.1秒間隔）
    private func startDisplayTimer() {
        stopDisplayTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateTimeDisplay()
            }
        }
        // RunLoopのcommonモードに追加（UIスクロール中も更新）
        if let timer = timer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }

    /// ディスプレイ更新用タイマーを停止
    private func stopDisplayTimer() {
        timer?.invalidate()
        timer = nil
    }

    /// 現在時刻ベースで残り時間を更新
    private func updateTimeDisplay() {
        guard timerState == .running, let endDate = endDate else { return }

        let remaining = endDate.timeIntervalSinceNow
        if remaining <= 0 {
            // セッション完了
            timeRemaining = 0
            progress = 1.0
            completeCurrentSession()
        } else {
            timeRemaining = remaining
            progress = totalDuration > 0 ? 1.0 - (remaining / totalDuration) : 0.0
        }
    }

    /// セッション完了処理
    private func completeCurrentSession() {
        stopDisplayTimer()
        timerState = .idle
        endDate = nil

        // 集中セッション完了時のカウント
        if currentSession == .focus {
            completedPomodoros += 1
            currentSetIndex += 1
            incrementTodayCount()

            // 通知
            if settings.notificationsEnabled {
                NotificationManager.shared.sendSessionCompleteNotification(sessionType: .focus)
            }
            if settings.playSoundOnComplete {
                SoundManager.shared.playCompletionSound(for: .focus, settings: settings)
            }

            // 次のセッションを決定
            if currentSetIndex >= settings.sessionsBeforeLongBreak {
                currentSession = .longBreak
                currentSetIndex = 0
            } else {
                currentSession = .shortBreak
            }
        } else {
            // 休憩完了
            if settings.notificationsEnabled {
                NotificationManager.shared.sendSessionCompleteNotification(sessionType: currentSession)
            }
            if settings.playSoundOnComplete {
                SoundManager.shared.playCompletionSound(for: currentSession, settings: settings)
            }
            currentSession = .focus
        }

        // 次のセッションの時間をセット
        totalDuration = settings.duration(for: currentSession)
        timeRemaining = totalDuration
        progress = 0.0

        // 自動開始
        if settings.autoStartNextSession {
            start()
        }
    }

    /// 今日の完了数をインクリメント
    private func incrementTodayCount() {
        let key = "completedPomodoros_\(DateUtils.todayKey)"
        let current = UserDefaults.standard.integer(forKey: key)
        UserDefaults.standard.set(current + 1, forKey: key)
    }

    /// スリープ復帰通知を監視
    private func setupWakeNotification() {
        wakeObserver = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didWakeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.handleWake()
            }
        }
    }

    /// スリープ復帰時の処理
    private func handleWake() {
        guard timerState == .running else { return }
        // endDateベースなので自動的に正しい残り時間が計算される
        updateTimeDisplay()
    }
}
