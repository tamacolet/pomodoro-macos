import Foundation

/// 日付関連のユーティリティ
enum DateUtils {
    /// 残り時間を "MM:SS" 形式にフォーマット
    static func formatTimeRemaining(_ seconds: TimeInterval) -> String {
        let totalSeconds = max(0, Int(ceil(seconds)))
        let minutes = totalSeconds / 60
        let secs = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, secs)
    }

    /// 残り時間を短縮形式にフォーマット（メニューバー用）
    static func formatTimeShort(_ seconds: TimeInterval) -> String {
        let totalSeconds = max(0, Int(ceil(seconds)))
        let minutes = totalSeconds / 60
        let secs = totalSeconds % 60
        if minutes > 0 {
            return "\(minutes):\(String(format: "%02d", secs))"
        } else {
            return "0:\(String(format: "%02d", secs))"
        }
    }

    /// 今日の日付キー（ポモドーロカウント用）
    static var todayKey: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}
