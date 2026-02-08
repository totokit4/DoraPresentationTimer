//
//  SettingsStore.swift
//  DoraPresentationTimer
//
//  Created by saki iwamoto on 2026/02/05.
//

import Foundation
import Combine

final class SettingsStore: ObservableObject {
    @Published private(set) var settings: AppSettings

    private let key = "app_settings_v1"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.settings = Self.load(from: defaults, key: key) ?? .default
    }
    
    func update(_ transform: (inout AppSettings) -> Void) {
        var new = settings
        transform(&new)
        new = normalized(new)
        settings = new
        save(new)
    }

    /// 設定値をアプリ内部で安全に扱える状態へ正規化する
    /// - durationSeconds と reminders の関係を整合させる
    private func normalized(_ s: AppSettings) -> AppSettings {
        var s = s

        // 終了(dora)は常に0固定
        s.reminders = s.reminders.map { r in
            var r = r
            if r.sound == .dora { r.secondsBeforeEnd = 0 }
            r.secondsBeforeEnd = max(0, r.secondsBeforeEnd)
            return r
        }

        // durationが0は「クリア状態」なので reminders を duration に合わせて丸めない
        guard s.durationSeconds > 0 else { return s }

        let maxSec = s.durationSeconds
        s.reminders = s.reminders.map { r in
            var r = r
            if r.sound != .dora {
                r.secondsBeforeEnd = min(r.secondsBeforeEnd, maxSec)
            }
            return r
        }

        return s
    }

    private func save(_ settings: AppSettings) {
        do {
            let data = try JSONEncoder().encode(settings)
            defaults.set(data, forKey: key)
        } catch {
            debugPrint(error)
        }
    }

    private static func load(from defaults: UserDefaults, key: String) -> AppSettings? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(AppSettings.self, from: data)
    }
}
