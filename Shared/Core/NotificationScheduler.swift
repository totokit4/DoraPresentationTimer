//
//  NotificationScheduler.swift
//  DoraPresentationTimer
//
//  Created by OpenAI on 2026/08/19.
//

import Foundation
import UserNotifications

final class NotificationScheduler {
    private let center: UNUserNotificationCenter
    private let identifierPrefix = "DoraPresentationTimer.timer."

    init(center: UNUserNotificationCenter = .current()) {
        self.center = center
    }

    func schedule(
        reminders: [ReminderRule],
        remainingSeconds: Int,
        durationSeconds: Int,
        settings: AppSettings,
        shouldSchedule: @escaping () -> Bool
    ) {
        cancel()

        center.requestAuthorization(options: [.alert, .sound]) { [weak self] granted, _ in
            guard granted else { return }
            DispatchQueue.main.async {
                guard shouldSchedule() else { return }
                self?.addNotificationRequests(
                    reminders: reminders,
                    remainingSeconds: remainingSeconds,
                    durationSeconds: durationSeconds,
                    settings: settings
                )
            }
        }
    }

    func cancel() {
        let identifiers = SoundType.allCases.map(notificationIdentifier(for:))
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    private func addNotificationRequests(
        reminders: [ReminderRule],
        remainingSeconds: Int,
        durationSeconds: Int,
        settings: AppSettings
    ) {
        let enabledReminders = reminders.filter { rule in
            guard let secondsBeforeEnd = rule.secondsBeforeEnd else { return false }
            guard rule.isEnabled && durationSeconds > secondsBeforeEnd else { return false }
            return secondsBeforeEnd == 0 || !settings.isIOSDCModeEnabled
        }

        for rule in enabledReminders {
            guard let secondsBeforeEnd = rule.secondsBeforeEnd else { continue }
            let fireAfterSeconds = remainingSeconds - secondsBeforeEnd
            guard fireAfterSeconds > 0 else { continue }

            let content = UNMutableNotificationContent()
            content.title = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ?? "Dora Presentation Timer"
            content.body = settings.language.localizedString(forKey: rule.localizationKey)
            #if os(watchOS)
            content.sound = .default
            #else
            content.sound = UNNotificationSound(named: UNNotificationSoundName("\(rule.sound.fileName).mp3"))
            #endif

            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(fireAfterSeconds), repeats: false)
            let request = UNNotificationRequest(
                identifier: notificationIdentifier(for: rule.sound),
                content: content,
                trigger: trigger
            )

            center.add(request)
        }
    }

    private func notificationIdentifier(for sound: SoundType) -> String {
        "\(identifierPrefix)\(sound.rawValue)"
    }
}
