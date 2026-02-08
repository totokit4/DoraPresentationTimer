//
//  AppSettings.swift
//  DoraPresentationTimer
//
//  Created by saki iwamoto on 2026/02/05.
//

import Foundation

struct AppSettings: Codable, Equatable {
    var durationSeconds: Int
    var reminders: [ReminderRule]

    static let `default` = AppSettings(
        durationSeconds: 10 * 60,
        reminders: [
            .init(id: UUID(), label: "リマインド1回目", secondsBeforeEnd: 3 * 60, sound: .clappers1, isEnabled: true),
            .init(id: UUID(), label: "リマインド2回目", secondsBeforeEnd: 1 * 60, sound: .clappers2, isEnabled: true),
            .init(id: UUID(), label: "終了時間", secondsBeforeEnd: 0, sound: .dora, isEnabled: true)
        ]
    )
}

struct ReminderRule: Codable, Equatable, Identifiable {
    let id: UUID
    var label: String
    var secondsBeforeEnd: Int
    var sound: SoundType
    var isEnabled: Bool
}
