import AppKit
import Foundation

/// アプリで利用できる通知音を管理するユーティリティ
final class SoundManager {
    struct SoundOption: Identifiable, Hashable {
        let id: String
        let displayName: String
        let fileURL: URL?
        let sourceLabel: String

        var isPlayable: Bool {
            id != Self.noneID
        }

        static let noneID = "none"
        static let systemDefaultID = "system:glass"

        static let none = SoundOption(
            id: noneID,
            displayName: "なし",
            fileURL: nil,
            sourceLabel: "無音"
        )

        static let systemDefault = SoundOption(
            id: systemDefaultID,
            displayName: "システム: Glass",
            fileURL: nil,
            sourceLabel: "macOS標準"
        )
    }

    static let shared = SoundManager()

    private let supportedExtensions = ["mp3", "wav", "aiff", "aif", "m4a", "caf"]
    private var activeSound: NSSound?

    private init() {
        ensureUserSoundsDirectoryExists()
    }

    /// 利用可能な通知音の一覧を返す
    func availableSounds() -> [SoundOption] {
        var options: [SoundOption] = [.none, .systemDefault]
        options.append(contentsOf: loadBundleSoundOptions())
        options.append(contentsOf: loadUserSoundOptions())

        return options.sorted { lhs, rhs in
            switch (lhs.id, rhs.id) {
            case (SoundOption.noneID, _):
                return true
            case (_, SoundOption.noneID):
                return false
            case (SoundOption.systemDefaultID, _):
                return true
            case (_, SoundOption.systemDefaultID):
                return false
            default:
                if lhs.sourceLabel == rhs.sourceLabel {
                    return lhs.displayName.localizedCaseInsensitiveCompare(rhs.displayName) == .orderedAscending
                }
                return lhs.sourceLabel.localizedCaseInsensitiveCompare(rhs.sourceLabel) == .orderedAscending
            }
        }
    }

    /// 指定した通知音を再生
    func playSound(id: String) {
        activeSound?.stop()

        if id == SoundOption.noneID { return }

        if id == SoundOption.systemDefaultID {
            if let sound = NSSound(named: .glass) {
                activeSound = sound
                sound.play()
            }
            return
        }

        guard let fileURL = resolveFileURL(for: id),
              let sound = NSSound(contentsOf: fileURL, byReference: false) else {
            return
        }

        activeSound = sound
        sound.play()
    }

    /// セッション完了時のサウンドを再生
    func playCompletionSound(for sessionType: SessionType, settings: PomodoroSettings) {
        playSound(id: settings.completionSoundID(for: sessionType))
    }

    /// ユーザー音源フォルダをFinderで開く
    func openUserSoundsDirectory() {
        NSWorkspace.shared.open(userSoundsDirectoryURL())
    }

    // MARK: - Private

    private func resolveFileURL(for id: String) -> URL? {
        let parts = id.split(separator: ":", maxSplits: 1)
        guard parts.count == 2 else { return nil }
        let prefix = parts[0]
        let filename = String(parts[1])

        switch prefix {
        case "bundle":
            return Bundle.main.resourceURL?
                .appendingPathComponent("Sounds", isDirectory: true)
                .appendingPathComponent(filename)
        case "user":
            return userSoundsDirectoryURL().appendingPathComponent(filename)
        default:
            return nil
        }
    }

    private func loadBundleSoundOptions() -> [SoundOption] {
        guard let soundsFolderURL = Bundle.main.resourceURL?.appendingPathComponent("Sounds", isDirectory: true) else {
            return []
        }

        return loadAudioFiles(from: soundsFolderURL, idPrefix: "bundle", sourceLabel: "プリセット")
    }

    private func loadUserSoundOptions() -> [SoundOption] {
        loadAudioFiles(from: userSoundsDirectoryURL(), idPrefix: "user", sourceLabel: "追加音源")
    }

    private func loadAudioFiles(from directoryURL: URL, idPrefix: String, sourceLabel: String) -> [SoundOption] {
        let fileManager = FileManager.default
        guard let fileURLs = try? fileManager.contentsOfDirectory(
            at: directoryURL,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        ) else {
            return []
        }

        return fileURLs
            .filter { supportedExtensions.contains($0.pathExtension.lowercased()) }
            .map { fileURL in
                SoundOption(
                    id: "\(idPrefix):\(fileURL.lastPathComponent)",
                    displayName: displayName(for: fileURL.lastPathComponent),
                    fileURL: fileURL,
                    sourceLabel: sourceLabel
                )
            }
    }

    private func displayName(for fileName: String) -> String {
        let presetNames: [String: String] = [
            "achievement-bell.mp3": "Achievement Bell",
            "bell-notification.mp3": "Bell Notification",
            "happy-bells-notification.mp3": "Happy Bells Notification",
            "long-pop.mp3": "Long Pop",
            "software-interface-start.mp3": "Software Interface Start"
        ]

        if let presetName = presetNames[fileName] {
            return presetName
        }

        return fileName
            .replacingOccurrences(of: ".\((fileName as NSString).pathExtension)", with: "")
            .replacingOccurrences(of: "-", with: " ")
            .replacingOccurrences(of: "_", with: " ")
            .split(separator: " ")
            .map { $0.prefix(1).uppercased() + $0.dropFirst().lowercased() }
            .joined(separator: " ")
    }

    private func userSoundsDirectoryURL() -> URL {
        let baseURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Library/Application Support", isDirectory: true)

        return baseURL
            .appendingPathComponent("Pomodoro", isDirectory: true)
            .appendingPathComponent("Sounds", isDirectory: true)
    }

    private func ensureUserSoundsDirectoryExists() {
        try? FileManager.default.createDirectory(
            at: userSoundsDirectoryURL(),
            withIntermediateDirectories: true
        )
    }
}

// MARK: - NSSound.Name 拡張
extension NSSound.Name {
    static let glass = NSSound.Name("Glass")
    static let purr = NSSound.Name("Purr")
    static let hero = NSSound.Name("Hero")
}
