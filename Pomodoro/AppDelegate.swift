import AppKit
import SwiftUI
import Combine

/// AppDelegate - メニューバー常駐とDockアイコン管理
@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {

    private var statusItem: NSStatusItem?
    private var popover: NSPopover?
    private var viewModel: PomodoroViewModel?
    private var settings: PomodoroSettings?
    private var cancellables = Set<AnyCancellable>()
    private var menuBarUpdateTimer: Timer?

    func configure(viewModel: PomodoroViewModel, settings: PomodoroSettings) {
        self.viewModel = viewModel
        self.settings = settings
    }

    nonisolated func applicationDidFinishLaunching(_ notification: Notification) {
        Task { @MainActor in
            // 通知権限をリクエスト
            NotificationManager.shared.requestAuthorization()

            // メニューバーのセットアップ
            if let settings = self.settings, settings.showInMenuBar {
                self.setupMenuBar()
            }

            // メニューバー表示設定の変更を監視
            self.settings?.objectWillChange.sink { [weak self] _ in
                Task { @MainActor in
                    self?.updateMenuBarVisibility()
                }
            }.store(in: &self.cancellables)

            // ウィンドウのスタイル設定
            self.configureMainWindow()
        }
    }

    nonisolated func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            Task { @MainActor in
                for window in NSApp.windows {
                    window.makeKeyAndOrderFront(nil)
                }
            }
        }
        return true
    }

    func setupMenuBarIfNeeded() {
        // 通知権限をリクエスト
        NotificationManager.shared.requestAuthorization()

        // メニューバーのセットアップ
        if let settings = settings, settings.showInMenuBar {
            setupMenuBar()
        }

        // メニューバー表示設定の変更を監視
        settings?.objectWillChange.sink { [weak self] _ in
            Task { @MainActor in
                self?.updateMenuBarVisibility()
            }
        }.store(in: &cancellables)

        // ウィンドウのスタイル設定
        configureMainWindow()
    }

    // MARK: - Menu Bar

    private func setupMenuBar() {
        guard let viewModel = viewModel, let settings = settings else { return }

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "timer", accessibilityDescription: "ポモドーロ")
            button.image?.size = NSSize(width: 16, height: 16)
            button.action = #selector(togglePopover)
            button.target = self
        }

        // ポップオーバーの設定
        let popover = NSPopover()
        popover.contentSize = NSSize(width: 260, height: 300)
        popover.behavior = .transient
        popover.animates = true

        let menuBarView = MenuBarView(viewModel: viewModel, settings: settings)
        popover.contentViewController = NSHostingController(rootView: menuBarView)

        self.popover = popover

        // メニューバーテキスト更新タイマー
        startMenuBarUpdateTimer()
    }

    private func removeMenuBar() {
        menuBarUpdateTimer?.invalidate()
        menuBarUpdateTimer = nil
        if let statusItem = statusItem {
            NSStatusBar.system.removeStatusItem(statusItem)
        }
        statusItem = nil
        popover = nil
    }

    private func updateMenuBarVisibility() {
        guard let settings = settings else { return }
        if settings.showInMenuBar && statusItem == nil {
            setupMenuBar()
        } else if !settings.showInMenuBar && statusItem != nil {
            removeMenuBar()
        }
    }

    @objc private func togglePopover() {
        guard let popover = popover, let button = statusItem?.button else { return }

        if popover.isShown {
            popover.performClose(nil)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            // ポップオーバーにフォーカス
            popover.contentViewController?.view.window?.makeKey()
        }
    }

    private func startMenuBarUpdateTimer() {
        menuBarUpdateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateMenuBarTitle()
            }
        }
    }

    private func updateMenuBarTitle() {
        guard let viewModel = viewModel, let button = statusItem?.button else { return }

        if viewModel.timerState == .idle {
            button.title = ""
            button.image = NSImage(systemSymbolName: "timer", accessibilityDescription: "ポモドーロ")
            button.image?.size = NSSize(width: 16, height: 16)
        } else {
            button.image = nil
            let time = DateUtils.formatTimeShort(viewModel.timeRemaining)
            let icon = viewModel.currentSession == .focus ? "🍅" : "☕"
            let pause = viewModel.timerState == .paused ? " ⏸" : ""
            button.title = "\(icon) \(time)\(pause)"
        }
    }

    // MARK: - Window Configuration

    private func configureMainWindow() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if let window = NSApp.windows.first {
                window.titlebarAppearsTransparent = true
                window.isMovableByWindowBackground = true
                window.backgroundColor = .clear
                window.title = "ポモドーロ"

                // ウィンドウの最小サイズ
                window.minSize = NSSize(width: 320, height: 440)

                // タイトルバーのスタイル
                window.titleVisibility = .hidden
                window.styleMask.insert(.fullSizeContentView)
            }
        }
    }
}
