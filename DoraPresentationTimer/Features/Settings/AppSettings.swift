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
    var colorMode: AppColorMode

    static let `default` = AppSettings(
        durationSeconds: 10 * 60,
        reminders: [
            .init(id: UUID(), label: "リマインド1回目", secondsBeforeEnd: 3 * 60, sound: .clappers1, isEnabled: true),
            .init(id: UUID(), label: "リマインド2回目", secondsBeforeEnd: 1 * 60, sound: .clappers2, isEnabled: true),
            .init(id: UUID(), label: "終了時間", secondsBeforeEnd: 0, sound: .dora, isEnabled: true)
        ],
        colorMode: .system
    )
}

extension AppSettings {
    private enum CodingKeys: String, CodingKey {
        case durationSeconds
        case reminders
        case colorMode
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        durationSeconds = try container.decode(Int.self, forKey: .durationSeconds)
        reminders = try container.decode([ReminderRule].self, forKey: .reminders)
        colorMode = try container.decodeIfPresent(AppColorMode.self, forKey: .colorMode) ?? .system
    }
}

struct ReminderRule: Codable, Equatable, Identifiable {
    let id: UUID
    var label: String
    var secondsBeforeEnd: Int?
    var sound: SoundType
    var isEnabled: Bool

    var localizedLabel: String {
        switch sound {
        case .clappers1:
            return String(localized: "reminder.first")
        case .clappers2:
            return String(localized: "reminder.second")
        case .dora:
            return String(localized: "reminder.finish")
        }
    }
}
