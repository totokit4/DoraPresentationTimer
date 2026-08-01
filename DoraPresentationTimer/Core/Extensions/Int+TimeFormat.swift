//
//  Int+TimeFormat.swift
//  DoraPresentationTimer
//
//  Created by saki iwamoto on 2026/01/31.
//

import Foundation

extension Int {
    /// 秒数を "mm:ss" 形式に整形します（例: 75 -> "01:15"）
    var formattedAsMMSS: String {
        let m = self / 60
        let s = self % 60
        return String(format: "%02d:%02d", m, s)
    }

    func formattedForAccessibility(language: AppLanguage) -> String {
        let format = language.localizedString(forKey: "accessibility.time.minutesSeconds")
        return String(
            format: format,
            locale: Locale(identifier: language.localeIdentifier),
            self / 60,
            self % 60
        )
    }
}
