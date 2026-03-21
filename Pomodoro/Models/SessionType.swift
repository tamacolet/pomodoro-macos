import Foundation

/// ポモドーロのセッション種別
enum SessionType: String, Codable, CaseIterable {
    case focus = "focus"
    case shortBreak = "shortBreak"
    case longBreak = "longBreak"

    var displayName: String {
        switch self {
        case .focus:      return "集中"
        case .shortBreak: return "短い休憩"
        case .longBreak:  return "長い休憩"
        }
    }

    var sfSymbol: String {
        switch self {
        case .focus:      return "brain.head.profile"
        case .shortBreak: return "cup.and.saucer.fill"
        case .longBreak:  return "moon.fill"
        }
    }

    /// セッション種別に応じたアクセントカラー名
    var accentColorName: String {
        switch self {
        case .focus:      return "FocusAccent"
        case .shortBreak: return "ShortBreakAccent"
        case .longBreak:  return "LongBreakAccent"
        }
    }
}
