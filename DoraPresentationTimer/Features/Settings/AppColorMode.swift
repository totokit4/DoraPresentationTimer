//
//  AppColorMode.swift
//  DoraPresentationTimer
//
//  Created by OpenAI on 2026/07/30.
//

import SwiftUI

enum AppColorMode: String, Codable, Equatable, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var displayName: String {
        NSLocalizedString(localizationKey, comment: "")
    }

    var localizationKey: String {
        switch self {
        case .system: return "colorMode.system"
        case .light: return "colorMode.light"
        case .dark: return "colorMode.dark"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}
