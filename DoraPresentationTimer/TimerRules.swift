//
//  TimerRules.swift
//  DoraPresentationTimer
//
//  Created by saki iwamoto on 2026/01/23.
//

import Foundation

/// タイマーが発火すべきイベント
enum TimerEvent: Equatable {
    case playSound(SoundType)
    case finished
}

struct TimerRules {
    /// 起こすべきイベントを返す
    /// - Parameters:
    ///   - remainingSeconds: 残秒数
    ///   - durationSeconds: 初期設定秒
    /// - Returns: イベント（なければnil）
    static func event(remainingSeconds: Int, durationSeconds: Int) -> TimerEvent? {
        guard remainingSeconds >= 0 else { return nil }
        guard durationSeconds >= 0 else { return nil }

        switch remainingSeconds {
        case 3 * 60:
            // 初期が3分以下なら「3分前」は鳴らさない
            return durationSeconds > 3 * 60 ? .playSound(.clappers1) : nil

        case 1 * 60:
            // 初期が1分以下なら「1分前」は鳴らさない
            return durationSeconds > 1 * 60 ? .playSound(.clappers2) : nil

        case 0:
            // 終了は常に鳴らす
            return .finished
        default:
            return nil
        }
    }
}
