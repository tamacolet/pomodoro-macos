import Foundation
import UserNotifications

/// macOS通知を管理するシングルトン
final class NotificationManager {
    static let shared = NotificationManager()

    private init() {}

    /// 通知権限をリクエスト
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { granted, error in
            if let error = error {
                print("Notification authorization error: \(error.localizedDescription)")
            }
            if granted {
                print("Notification permission granted")
            }
        }
    }

    /// セッション完了通知を送信
    func sendSessionCompleteNotification(sessionType: SessionType) {
        let content = UNMutableNotificationContent()

        switch sessionType {
        case .focus:
            content.title = "集中セッション完了"
            content.body = "お疲れさまでした。休憩を取りましょう。"
        case .shortBreak:
            content.title = "休憩終了"
            content.body = "次の集中セッションを始めましょう。"
        case .longBreak:
            content.title = "長い休憩終了"
            content.body = "リフレッシュできましたか？次のセッションを始めましょう。"
        }

        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil // 即座に送信
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Notification error: \(error.localizedDescription)")
            }
        }
    }
}
