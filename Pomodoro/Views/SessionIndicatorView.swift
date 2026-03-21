import SwiftUI

/// セッション種別とセット進捗を表示するインジケーター
struct SessionIndicatorView: View {
    let currentSession: SessionType
    let currentSetIndex: Int
    let totalSets: Int

    var body: some View {
        VStack(spacing: 8) {
            // セッション種別ラベル
            HStack(spacing: 6) {
                Image(systemName: currentSession.sfSymbol)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(sessionColor.opacity(0.9))

                Text(currentSession.displayName)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.secondary)
            }

            // セットインジケーター（ドット）
            HStack(spacing: 6) {
                ForEach(0..<totalSets, id: \.self) { index in
                    Circle()
                        .fill(index < currentSetIndex ? sessionColor : .primary.opacity(0.12))
                        .frame(width: 6, height: 6)
                        .animation(.easeInOut(duration: 0.3), value: currentSetIndex)
                }
            }
        }
    }

    private var sessionColor: Color {
        switch currentSession {
        case .focus:      return .orange
        case .shortBreak: return .green
        case .longBreak:  return .blue
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        SessionIndicatorView(currentSession: .focus, currentSetIndex: 2, totalSets: 4)
        SessionIndicatorView(currentSession: .shortBreak, currentSetIndex: 3, totalSets: 4)
        SessionIndicatorView(currentSession: .longBreak, currentSetIndex: 0, totalSets: 4)
    }
    .padding()
}
