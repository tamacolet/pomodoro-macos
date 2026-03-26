import Foundation
import SwiftUI

/// アプリ設定を管理するObservableObject
/// UserDefaultsで永続化する
final class PomodoroSettings: ObservableObject {

    static let defaultFocusSoundID = "bundle:achievement-bell.mp3"
    static let defaultShortBreakSoundID = "bundle:happy-bells-notification.mp3"
    static let defaultLongBreakSoundID = "bundle:long-pop.mp3"

    // MARK: - 時間設定（分単位）

    @AppStorage("focusDuration") var focusDuration: Int = 25 {
        willSet { objectWillChange.send() }
    }
    @AppStorage("shortBreakDuration") var shortBreakDuration: Int = 5 {
        willSet { objectWillChange.send() }
    }
    @AppStorage("longBreakDuration") var longBreakDuration: Int = 15 {
        willSet { objectWillChange.send() }
    }
    @AppStorage("sessionsBeforeLongBreak") var sessionsBeforeLongBreak: Int = 4 {
        willSet { objectWillChange.send() }
    }

    // MARK: - 動作設定

    @AppStorage("notificationsEnabled") var notificationsEnabled: Bool = true {
        willSet { objectWillChange.send() }
    }
    @AppStorage("autoStartNextSession") var autoStartNextSession: Bool = false {
        willSet { objectWillChange.send() }
    }
    @AppStorage("showInMenuBar") var showInMenuBar: Bool = true {
        willSet { objectWillChange.send() }
    }
    @AppStorage("playSoundOnComplete") var playSoundOnComplete: Bool = true {
        willSet { objectWillChange.send() }
    }
    @AppStorage("focusCompletionSoundID") var focusCompletionSoundID: String = PomodoroSettings.defaultFocusSoundID {
        willSet { objectWillChange.send() }
    }
    @AppStorage("shortBreakCompletionSoundID") var shortBreakCompletionSoundID: String = PomodoroSettings.defaultShortBreakSoundID {
        willSet { objectWillChange.send() }
    }
    @AppStorage("longBreakCompletionSoundID") var longBreakCompletionSoundID: String = PomodoroSettings.defaultLongBreakSoundID {
        willSet { objectWillChange.send() }
    }

    // MARK: - ヘルパー

    /// セッション種別に応じた秒数を返す
    func duration(for sessionType: SessionType) -> TimeInterval {
        switch sessionType {
        case .focus:      return TimeInterval(focusDuration * 60)
        case .shortBreak: return TimeInterval(shortBreakDuration * 60)
        case .longBreak:  return TimeInterval(longBreakDuration * 60)
        }
    }

    /// セッション種別ごとの完了音IDを返す
    func completionSoundID(for sessionType: SessionType) -> String {
        switch sessionType {
        case .focus:
            return focusCompletionSoundID
        case .shortBreak:
            return shortBreakCompletionSoundID
        case .longBreak:
            return longBreakCompletionSoundID
        }
    }

    /// セッション種別ごとのデフォルト完了音IDを返す
    static func defaultCompletionSoundID(for sessionType: SessionType) -> String {
        switch sessionType {
        case .focus:      return defaultFocusSoundID
        case .shortBreak: return defaultShortBreakSoundID
        case .longBreak:  return defaultLongBreakSoundID
        }
    }

    /// セッション種別ごとの完了音IDを更新する
    func setCompletionSoundID(_ soundID: String, for sessionType: SessionType) {
        switch sessionType {
        case .focus:
            focusCompletionSoundID = soundID
        case .shortBreak:
            shortBreakCompletionSoundID = soundID
        case .longBreak:
            longBreakCompletionSoundID = soundID
        }
    }
}
