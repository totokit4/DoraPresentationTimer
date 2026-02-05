//
//  SettingsStore.swift
//  DoraPresentationTimer
//
//  Created by saki iwamoto on 2026/02/05.
//

import Foundation
import Combine

final class SettingsStore: ObservableObject {
    @Published var settings: AppSettings {
        didSet { save(settings) }
    }

    private let key = "app_settings_v1"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.settings = Self.load(from: defaults, key: key) ?? .default
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
