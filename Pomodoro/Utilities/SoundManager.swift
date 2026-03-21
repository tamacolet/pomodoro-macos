import AppKit

/// システムサウンドを再生するユーティリティ
final class SoundManager {
    static let shared = SoundManager()

    private init() {}

    /// セッション完了時のサウンドを再生
    func playCompletionSound() {
        // macOS標準のサウンドを使用
        if let sound = NSSound(named: .glass) {
            sound.play()
        }
    }
}

// MARK: - NSSound.Name 拡張
extension NSSound.Name {
    static let glass = NSSound.Name("Glass")
    static let purr = NSSound.Name("Purr")
    static let hero = NSSound.Name("Hero")
}
