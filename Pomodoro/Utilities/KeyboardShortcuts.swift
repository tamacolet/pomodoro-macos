import SwiftUI

/// キーボードショートカットの定義
enum AppShortcuts {
    /// 開始 / 一時停止 トグル: ⌘ Return
    static let toggleTimer = KeyboardShortcut(.return, modifiers: .command)

    /// リセット: ⌘ R
    static let resetTimer = KeyboardShortcut("r", modifiers: .command)

    /// スキップ: ⌘ →
    static let skipSession = KeyboardShortcut(.rightArrow, modifiers: .command)

    /// 設定を開く: ⌘ ,
    static let openSettings = KeyboardShortcut(",", modifiers: .command)
}
