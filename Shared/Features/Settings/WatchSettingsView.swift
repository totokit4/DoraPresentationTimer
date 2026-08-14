//
//  WatchSettingsView.swift
//  DoraPresentationTimer
//
//  Created by OpenAI on 2026/08/15.
//

import SwiftUI

private enum WatchEditTarget: Identifiable {
    case duration
    case reminder(UUID)

    var id: String {
        switch self {
        case .duration:
            return "duration"
        case .reminder(let id):
            return "reminder-\(id.uuidString)"
        }
    }
}

struct WatchSettingsView: View {
    @EnvironmentObject private var settingsStore: SettingsStore
    @State private var editTarget: WatchEditTarget?

    private var languageBinding: Binding<AppLanguage> {
        Binding(
            get: { settingsStore.settings.language },
            set: { newValue in settingsStore.update { $0.language = newValue } }
        )
    }

    var body: some View {
        List {
            Section("section.timer") {
                Button {
                    editTarget = .duration
                } label: {
                    valueRow(
                        title: "settings.duration",
                        value: settingsStore.settings.durationSeconds.formattedAsMMSS
                    )
                }
            }

            Section("section.reminders") {
                ForEach(editableReminders) { reminder in
                    Button {
                        editTarget = .reminder(reminder.id)
                    } label: {
                        valueRow(
                            title: LocalizedStringKey(reminder.localizationKey),
                            value: reminderText(for: reminder)
                        )
                    }
                }
            }

            Section("section.language") {
                ForEach(AppLanguage.allCases) { language in
                    Button {
                        languageBinding.wrappedValue = language
                    } label: {
                        languageRow(language)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .sheet(item: $editTarget) { target in
            switch target {
            case .duration:
                TimePickerSheet(
                    title: "sheet.setDuration",
                    totalSeconds: Binding(
                        get: { settingsStore.settings.durationSeconds },
                        set: { newValue in
                            settingsStore.update { $0.durationSeconds = newValue }
                        }
                    ),
                    isTimerRunning: false
                )

            case .reminder(let id):
                if let rule = settingsStore.settings.reminders.first(where: { $0.id == id }) {
                    ReminderTimePickerSheet(
                        title: LocalizedStringKey(rule.localizationKey),
                        totalSeconds: Binding(
                            get: {
                                settingsStore.settings.reminders.first(where: { $0.id == id })?.secondsBeforeEnd
                            },
                            set: { newValue in
                                settingsStore.update { settings in
                                    guard let index = settings.reminders.firstIndex(where: { $0.id == id }) else { return }
                                    settings.reminders[index].secondsBeforeEnd = newValue
                                }
                            }
                        ),
                        maxSeconds: settingsStore.settings.durationSeconds
                    )
                }
            }
        }
    }

    private var editableReminders: [ReminderRule] {
        settingsStore.settings.reminders.filter { $0.sound != .dora }
    }

    private func valueRow(title: LocalizedStringKey, value: String) -> some View {
        HStack(spacing: 8) {
            Text(title)
            Spacer(minLength: 8)
            Text(value)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .monospacedDigit()
                .lineLimit(1)
        }
    }

    private func languageRow(_ language: AppLanguage) -> some View {
        HStack(spacing: 8) {
            Text(language.displayName)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
            Spacer(minLength: 8)
            if settingsStore.settings.language == language {
                Image(systemName: "checkmark")
                    .font(.caption)
                    .foregroundStyle(.orange)
            }
        }
    }

    private func reminderText(for rule: ReminderRule) -> String {
        guard let secondsBeforeEnd = rule.secondsBeforeEnd else {
            return settingsStore.settings.language.localizedString(forKey: "settings.reminder.unset")
        }

        let format = settingsStore.settings.language.localizedString(forKey: "settings.reminder.secondsBeforeEnd")
        return String(
            format: format,
            locale: Locale(identifier: settingsStore.settings.language.localeIdentifier),
            secondsBeforeEnd
        )
    }
}

#Preview {
    NavigationStack {
        WatchSettingsView()
            .environmentObject(SettingsStore())
    }
}
