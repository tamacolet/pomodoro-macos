import SwiftUI

/// アプリのルートコンテンツビュー
struct ContentView: View {
    @ObservedObject var viewModel: PomodoroViewModel
    @ObservedObject var settings: PomodoroSettings

    var body: some View {
        TimerView(viewModel: viewModel, settings: settings)
    }
}

#Preview {
    ContentView(
        viewModel: PomodoroViewModel(settings: PomodoroSettings()),
        settings: PomodoroSettings()
    )
}
