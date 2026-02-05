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
    ///   - reminders: リマインドルール
    /// - Returns: イベント（なければnil）
    static func event(remainingSeconds: Int,
                      durationSeconds: Int,
                      reminders: [ReminderRule]) -> TimerEvent? {
        guard remainingSeconds >= 0 else { return nil }
        guard durationSeconds >= 0 else { return nil }
        
        // 有効なルールのみ
        let enabledReminders = reminders.filter { $0.isEnabled }

        // 「残り◯秒」で鳴るルールを探す
        guard let rule = enabledReminders.first(where: {
            $0.secondsBeforeEnd == remainingSeconds
        }) else {
            return nil
        }

        // 初期時間以下のリマインドは鳴らさない（例：初期60秒で「3分前」は無視）
        if durationSeconds <= rule.secondsBeforeEnd {
            return nil
        }

        // 終了
        if rule.secondsBeforeEnd == 0 {
            return .finished
        }

        // 通常リマインド
        return .playSound(rule.sound)
    }
}
