//
//  AppSettings.swift
//  DoraPresentationTimer
//
//  Created by saki iwamoto on 2026/02/05.
//

import Foundation

enum TimerSoundStyle: String, Codable {
    case dora
    case bell

    // リマインダーの役割を保持し、再生する音源だけを切り替える。
    func sound(for sound: SoundType) -> SoundType {
        switch sound {
        case .clappers1, .callBell1:
            return self == .bell ? .callBell1 : .clappers1
        case .clappers2, .callBell2:
            return self == .bell ? .callBell2 : .clappers2
        case .dora, .callBell3:
            return self == .bell ? .callBell3 : .dora
        }
    }
}

struct AppSettings: Codable, Equatable {
    var durationSeconds: Int
    var reminders: [ReminderRule]
    var colorMode: AppColorMode
    var soundStyle: TimerSoundStyle = .dora
    var language: AppLanguage
    var isIOSDCModeEnabled: Bool
    var penlightColor: PenlightColor
    /// 外部ディスプレイの背景色（"RRGGBB"）
    var externalDisplayBackgroundColorHex: String
    /// 外部ディスプレイに残り時間を表示するか
    var isExternalDisplayTimerVisible: Bool

    static let `default` = AppSettings(
        durationSeconds: 10 * 60,
        reminders: [
            .init(id: UUID(), label: "1回目", secondsBeforeEnd: 3 * 60, sound: .clappers1, isEnabled: true),
            .init(id: UUID(), label: "2回目", secondsBeforeEnd: 1 * 60, sound: .clappers2, isEnabled: true),
            .init(id: UUID(), label: "終了時間", secondsBeforeEnd: 0, sound: .dora, isEnabled: true)
        ],
        colorMode: .system,
        language: .japanese,
        isIOSDCModeEnabled: false,
        penlightColor: .red,
        externalDisplayBackgroundColorHex: AppSettings.defaultExternalDisplayBackgroundColorHex,
        isExternalDisplayTimerVisible: false
    )

    static let defaultExternalDisplayBackgroundColorHex = "000000"
}

extension AppSettings {
    private enum CodingKeys: String, CodingKey {
        case durationSeconds
        case reminders
        case colorMode
        case soundStyle
        case language
        case isIOSDCModeEnabled
        case penlightColor
        case externalDisplayBackgroundColorHex
        case isExternalDisplayTimerVisible
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        durationSeconds = try container.decode(Int.self, forKey: .durationSeconds)
        reminders = try container.decode([ReminderRule].self, forKey: .reminders)
        colorMode = try container.decodeIfPresent(AppColorMode.self, forKey: .colorMode) ?? .system
        soundStyle = try container.decodeIfPresent(TimerSoundStyle.self, forKey: .soundStyle) ?? .dora
        language = try container.decodeIfPresent(AppLanguage.self, forKey: .language) ?? .japanese
        isIOSDCModeEnabled = try container.decodeIfPresent(Bool.self, forKey: .isIOSDCModeEnabled) ?? false
        penlightColor = try container.decodeIfPresent(PenlightColor.self, forKey: .penlightColor) ?? .red
        externalDisplayBackgroundColorHex = try container.decodeIfPresent(String.self, forKey: .externalDisplayBackgroundColorHex)
            ?? Self.defaultExternalDisplayBackgroundColorHex
        isExternalDisplayTimerVisible = try container.decodeIfPresent(Bool.self, forKey: .isExternalDisplayTimerVisible) ?? false
    }
}

struct ReminderRule: Codable, Equatable, Identifiable {
    let id: UUID
    var label: String
    var secondsBeforeEnd: Int?
    var sound: SoundType
    var isEnabled: Bool

    var localizationKey: String {
        switch sound {
        case .clappers1, .callBell1:
            return "reminder.first"
        case .clappers2, .callBell2:
            return "reminder.second"
        case .dora, .callBell3:
            return "reminder.finish"
        }
    }
}
