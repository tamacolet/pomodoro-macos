import Foundation
import SwiftUI

/// アプリ設定を管理するObservableObject
/// UserDefaultsで永続化する
final class PomodoroSettings: ObservableObject {

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

    // MARK: - ヘルパー

    /// セッション種別に応じた秒数を返す
    func duration(for sessionType: SessionType) -> TimeInterval {
        switch sessionType {
        case .focus:      return TimeInterval(focusDuration * 60)
        case .shortBreak: return TimeInterval(shortBreakDuration * 60)
        case .longBreak:  return TimeInterval(longBreakDuration * 60)
        }
    }
}
