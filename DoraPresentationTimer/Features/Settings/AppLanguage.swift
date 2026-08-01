//
//  AppLanguage.swift
//  DoraPresentationTimer
//
//  Created by OpenAI on 2026/07/31.
//

import Foundation

enum AppLanguage: String, Codable, Equatable, CaseIterable, Identifiable {
    case japanese = "ja"
    case english = "en"
    case simplifiedChinese = "zh-Hans"
    case korean = "ko"
    case spanish = "es"

    var id: String { rawValue }

    var localeIdentifier: String { rawValue }

    var displayName: String {
        switch self {
        case .japanese: return "日本語"
        case .english: return "English"
        case .simplifiedChinese: return "简体中文"
        case .korean: return "한국어"
        case .spanish: return "Español"
        }
    }

    func localizedString(forKey key: String) -> String {
        guard let path = Bundle.main.path(forResource: rawValue, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return NSLocalizedString(key, comment: "")
        }

        return bundle.localizedString(forKey: key, value: nil, table: nil)
    }
}
