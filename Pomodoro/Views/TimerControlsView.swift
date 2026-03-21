import SwiftUI

/// タイマー操作ボタン群
struct TimerControlsView: View {
    @ObservedObject var viewModel: PomodoroViewModel

    var body: some View {
        HStack(spacing: 20) {
            // リセットボタン
            ControlButton(
                symbol: "arrow.counterclockwise",
                label: "リセット",
                action: { viewModel.reset() },
                isEnabled: viewModel.timerState != .idle
            )
            .keyboardShortcut("r", modifiers: .command)

            // 開始 / 一時停止ボタン（メイン）
            Button(action: { viewModel.toggleStartPause() }) {
                ZStack {
                    Circle()
                        .fill(.primary.opacity(0.08))
                        .frame(width: 56, height: 56)

                    Image(systemName: playPauseIcon)
                        .font(.system(size: 22, weight: .medium))
                        .foregroundStyle(.primary)
                }
            }
            .buttonStyle(.plain)
            .keyboardShortcut(.return, modifiers: .command)
            .accessibilityLabel(viewModel.timerState == .running ? "一時停止" : "開始")
            .help(viewModel.timerState == .running ? "一時停止 (⌘↩)" : "開始 (⌘↩)")

            // スキップボタン
            ControlButton(
                symbol: "forward.end.fill",
                label: "スキップ",
                action: { viewModel.skip() },
                isEnabled: true
            )
            .keyboardShortcut(.rightArrow, modifiers: .command)
        }
    }

    private var playPauseIcon: String {
        switch viewModel.timerState {
        case .idle:    return "play.fill"
        case .running: return "pause.fill"
        case .paused:  return "play.fill"
        }
    }
}

/// 個別のコントロールボタン
struct ControlButton: View {
    let symbol: String
    let label: String
    let action: () -> Void
    let isEnabled: Bool

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(.primary.opacity(0.05))
                    .frame(width: 40, height: 40)

                Image(systemName: symbol)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(isEnabled ? Color.primary : Color.secondary.opacity(0.5))
            }
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .accessibilityLabel(label)
        .help(label)
    }
}

#Preview {
    TimerControlsView(viewModel: PomodoroViewModel(settings: PomodoroSettings()))
        .padding()
}
