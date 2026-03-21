import SwiftUI

/// メインのタイマー画面
struct TimerView: View {
    @ObservedObject var viewModel: PomodoroViewModel
    @ObservedObject var settings: PomodoroSettings
    @State private var showSettings = false

    var body: some View {
        ZStack {
            // 背景
            backgroundLayer

            VStack(spacing: 0) {
                // ツールバー領域
                toolbarArea

                Spacer(minLength: 16)

                // セッションインジケーター
                SessionIndicatorView(
                    currentSession: viewModel.currentSession,
                    currentSetIndex: viewModel.currentSetIndex,
                    totalSets: settings.sessionsBeforeLongBreak
                )
                .padding(.bottom, 20)

                // タイマーリング + 残り時間
                timerDisplay
                    .padding(.bottom, 24)

                // コントロールボタン
                TimerControlsView(viewModel: viewModel)
                    .padding(.bottom, 20)

                Spacer(minLength: 16)

                // 今日の完了数
                todayCountView
                    .padding(.bottom, 20)
            }
            .padding(.horizontal, 24)
        }
        .frame(minWidth: 320, idealWidth: 360, maxWidth: 500,
               minHeight: 440, idealHeight: 500, maxHeight: 700)
        .sheet(isPresented: $showSettings) {
            SettingsView(settings: settings)
        }
    }

    // MARK: - Subviews

    private var backgroundLayer: some View {
        ZStack {
            // Reduce Transparency対応: 不透明フォールバック
            Color(nsColor: .windowBackgroundColor)

            // すりガラス効果
            VisualEffectBackground(material: .hudWindow, blendingMode: .behindWindow)
        }
        .ignoresSafeArea()
    }

    private var toolbarArea: some View {
        HStack {
            Spacer()
            Button(action: { showSettings = true }) {
                Image(systemName: "gearshape")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .keyboardShortcut(",", modifiers: .command)
            .accessibilityLabel("設定")
            .help("設定 (⌘,)")
        }
        .padding(.top, 12)
    }

    private var timerDisplay: some View {
        ZStack {
            // 進捗リング
            ProgressRingView(
                progress: viewModel.progress,
                sessionType: viewModel.currentSession,
                lineWidth: 6
            )
            .frame(width: 200, height: 200)

            // 残り時間テキスト
            VStack(spacing: 4) {
                Text(DateUtils.formatTimeRemaining(viewModel.timeRemaining))
                    .font(.system(size: 48, weight: .light, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(.primary)
                    .accessibilityLabel("残り時間 \(accessibilityTimeText)")

                if viewModel.timerState == .paused {
                    Text("一時停止中")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.secondary)
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.2), value: viewModel.timerState)
        }
    }

    private var todayCountView: some View {
        HStack(spacing: 4) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 12))
                .foregroundStyle(.secondary.opacity(0.7))

            Text("今日: \(viewModel.todayCompletedCount) ポモドーロ")
                .font(.system(size: 12, weight: .regular))
                .foregroundStyle(.secondary)
        }
        .accessibilityLabel("今日の完了数 \(viewModel.todayCompletedCount)")
    }

    private var accessibilityTimeText: String {
        let total = max(0, Int(ceil(viewModel.timeRemaining)))
        let min = total / 60
        let sec = total % 60
        return "\(min)分\(sec)秒"
    }
}

// MARK: - NSVisualEffectView ブリッジ

/// AppKitのNSVisualEffectViewをSwiftUIで使用するためのブリッジ
struct VisualEffectBackground: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .followsWindowActiveState
        view.isEmphasized = true
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}

#Preview {
    TimerView(
        viewModel: PomodoroViewModel(settings: PomodoroSettings()),
        settings: PomodoroSettings()
    )
}
