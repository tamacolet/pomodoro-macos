import SwiftUI

/// 円形の進捗リング
struct ProgressRingView: View {
    let progress: Double
    let sessionType: SessionType
    let lineWidth: CGFloat

    init(progress: Double, sessionType: SessionType, lineWidth: CGFloat = 8) {
        self.progress = progress
        self.sessionType = sessionType
        self.lineWidth = lineWidth
    }

    var body: some View {
        ZStack {
            // 背景リング
            Circle()
                .stroke(
                    Color.primary.opacity(0.08),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )

            // 進捗リング
            Circle()
                .trim(from: 0, to: CGFloat(min(progress, 1.0)))
                .stroke(
                    ringGradient,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.3), value: progress)
        }
    }

    private var ringGradient: AngularGradient {
        let color = ringColor
        return AngularGradient(
            gradient: Gradient(colors: [
                color.opacity(0.6),
                color,
                color.opacity(0.8)
            ]),
            center: .center,
            startAngle: .degrees(0),
            endAngle: .degrees(360 * progress)
        )
    }

    private var ringColor: Color {
        switch sessionType {
        case .focus:      return .orange
        case .shortBreak: return .green
        case .longBreak:  return .blue
        }
    }
}

#Preview {
    VStack(spacing: 30) {
        ProgressRingView(progress: 0.65, sessionType: .focus)
            .frame(width: 200, height: 200)
        ProgressRingView(progress: 0.3, sessionType: .shortBreak)
            .frame(width: 200, height: 200)
        ProgressRingView(progress: 0.9, sessionType: .longBreak)
            .frame(width: 200, height: 200)
    }
    .padding()
}
