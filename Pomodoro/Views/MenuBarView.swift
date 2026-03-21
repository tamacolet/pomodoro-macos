import SwiftUI

/// メニューバーのポップオーバー内容
struct MenuBarView: View {
    @ObservedObject var viewModel: PomodoroViewModel
    @ObservedObject var settings: PomodoroSettings

    var body: some View {
        VStack(spacing: 12) {
            // セッション情報
            HStack(spacing: 6) {
                Image(systemName: viewModel.currentSession.sfSymbol)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(sessionColor)

                Text(viewModel.currentSession.displayName)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)

                Spacer()

                // セットドット
                HStack(spacing: 4) {
                    ForEach(0..<settings.sessionsBeforeLongBreak, id: \.self) { index in
                        Circle()
                            .fill(index < viewModel.currentSetIndex ? sessionColor : .primary.opacity(0.12))
                            .frame(width: 5, height: 5)
                    }
                }
            }

            // タイマー表示
            HStack {
                // ミニ進捗リング
                ProgressRingView(
                    progress: viewModel.progress,
                    sessionType: viewModel.currentSession,
                    lineWidth: 3
                )
                .frame(width: 36, height: 36)

                Text(DateUtils.formatTimeRemaining(viewModel.timeRemaining))
                    .font(.system(size: 28, weight: .light, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(.primary)

                Spacer()
            }

            Divider()
                .opacity(0.5)

            // コントロールボタン
            HStack(spacing: 16) {
                MenuBarButton(
                    symbol: playPauseIcon,
                    label: viewModel.timerState == .running ? "一時停止" : "開始",
                    action: { viewModel.toggleStartPause() }
                )

                MenuBarButton(
                    symbol: "arrow.counterclockwise",
                    label: "リセット",
                    action: { viewModel.reset() }
                )

                MenuBarButton(
                    symbol: "forward.end.fill",
                    label: "スキップ",
                    action: { viewModel.skip() }
                )

                Spacer()
            }

            Divider()
                .opacity(0.5)

            // 今日の完了数
            HStack(spacing: 4) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary.opacity(0.6))
                Text("今日: \(viewModel.todayCompletedCount) ポモドーロ")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
                Spacer()
            }

            Divider()
                .opacity(0.5)

            // アプリを開く / 終了
            HStack {
                Button("ポモドーロ を開く") {
                    NSApp.activate(ignoringOtherApps: true)
                    if let window = NSApp.windows.first(where: { $0.title == "ポモドーロ" || $0.isKeyWindow }) {
                        window.makeKeyAndOrderFront(nil)
                    } else {
                        // メインウィンドウがない場合、新しく開く
                        NSApp.activate(ignoringOtherApps: true)
                    }
                }
                .buttonStyle(.plain)
                .font(.system(size: 12))
                .foregroundStyle(.primary)

                Spacer()

                Button("終了") {
                    NSApp.terminate(nil)
                }
                .buttonStyle(.plain)
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .frame(width: 260)
    }

    private var playPauseIcon: String {
        switch viewModel.timerState {
        case .idle:    return "play.fill"
        case .running: return "pause.fill"
        case .paused:  return "play.fill"
        }
    }

    private var sessionColor: Color {
        switch viewModel.currentSession {
        case .focus:      return .orange
        case .shortBreak: return .green
        case .longBreak:  return .blue
        }
    }
}

/// メニューバー用の小さなボタン
struct MenuBarButton: View {
    let symbol: String
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: symbol)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.primary)
                Text(label)
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
            }
            .frame(width: 48, height: 40)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(.primary.opacity(0.05))
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }
}

#Preview {
    MenuBarView(
        viewModel: PomodoroViewModel(settings: PomodoroSettings()),
        settings: PomodoroSettings()
    )
}
