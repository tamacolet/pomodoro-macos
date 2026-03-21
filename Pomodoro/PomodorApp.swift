import SwiftUI
/// ポモドーロ - macOSネイティブ ポモドーロタイマー
@main
struct PomodorApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var settings = PomodoroSettings()
    @StateObject private var viewModel: PomodoroViewModel
    init() {
        let settings = PomodoroSettings()
        _settings = StateObject(wrappedValue: settings)
        _viewModel = StateObject(wrappedValue: PomodoroViewModel(settings: settings))
    }
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel, settings: settings)
                .onAppear {
                    appDelegate.configure(viewModel: viewModel, settings: settings)
                    appDelegate.setupMenuBarIfNeeded()
                }
        }
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 360, height: 500)
        .commands {
            // 「新規ウィンドウ」を無効化
            CommandGroup(replacing: .newItem) { }
            CommandMenu("タイマー") {
                Button(viewModel.timerState == .running ? "一時停止" : "開始") {
                    viewModel.toggleStartPause()
                }
                .keyboardShortcut(.return, modifiers: .command)
                Button("リセット") {
                    viewModel.reset()
                }
                .keyboardShortcut("r", modifiers: .command)
                Button("スキップ") {
                    viewModel.skip()
                }
                .keyboardShortcut(.rightArrow, modifiers: .command)
            }
        }
    }
}
