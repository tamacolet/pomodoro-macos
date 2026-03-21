import Foundation

/// タイマーの動作状態
enum TimerState: String, Codable {
    case idle      // 未開始
    case running   // 実行中
    case paused    // 一時停止中
}
