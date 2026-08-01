//
//  SettingsView.swift
//  DoraPresentationTimer
//
//  Created by saki iwamoto on 2026/02/02.
//

import SwiftUI

private enum EditTarget: Identifiable {
    case duration
    case reminder(UUID)
    
    var id: String {
        switch self {
        case .duration: return "duration"
        case .reminder(let uuid): return "reminder-\(uuid.uuidString)"
        }
    }
}

struct SettingsView: View {
    @EnvironmentObject var settingsStore: SettingsStore
    @State private var editTarget: EditTarget?
    
    private let soundPlayer = SoundPlayer()

    private var colorModeBinding: Binding<AppColorMode> {
        Binding(
            get: { settingsStore.settings.colorMode },
            set: { newValue in
                settingsStore.update { $0.colorMode = newValue }
            }
        )
    }

    private var languageBinding: Binding<AppLanguage> {
        Binding(
            get: { settingsStore.settings.language },
            set: { newValue in
                settingsStore.update { $0.language = newValue }
            }
        )
    }
    
    var body: some View {
        List {
            Section("section.timer") {
                oneLineRow(
                    left: "settings.duration",
                    middle: settingsStore.settings.durationSeconds.formattedAsMMSS,
                    accessibilityValue: settingsStore.settings.durationSeconds.formattedForAccessibility(language: settingsStore.settings.language),
                    showSpeaker: false,
                    isEditable: true,
                    speakerAccessibilityLabel: "",
                    onSpeaker: {},
                    onTap: { editTarget = .duration }
                )
            }

            Section("section.reminders") {
                ForEach(settingsStore.settings.reminders) { r in
                    oneLineRow(
                        left: LocalizedStringKey(r.localizationKey),
                        middle: reminderText(for: r),
                        accessibilityValue: reminderText(for: r),
                        showSpeaker: true,
                        isEditable: r.sound != .dora,
                        speakerAccessibilityLabel: soundPreviewAccessibilityLabel(for: r),
                        onSpeaker: { soundPlayer.play(r.sound) },
                        onTap: {
                            guard r.sound != .dora else { return }
                            editTarget = .reminder(r.id)
                        }
                    )
                }
            }

            Section("section.appearance") {
                Picker("settings.colorMode", selection: colorModeBinding) {
                    ForEach(AppColorMode.allCases) { mode in
                        Text(LocalizedStringKey(mode.localizationKey)).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
            }

            Section("section.language") {
                Picker("settings.language", selection: languageBinding) {
                    ForEach(AppLanguage.allCases) { language in
                        Text(language.displayName).tag(language)
                    }
                }
            }
        }
        .navigationTitle("settings.title")
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
                .presentationDetents([.fraction(0.35), .medium])
                .presentationDragIndicator(.visible)

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
                                    guard let idx = settings.reminders.firstIndex(where: { $0.id == id }) else { return }
                                    settings.reminders[idx].secondsBeforeEnd = newValue
                                }
                            }
                        ),
                        maxSeconds: settingsStore.settings.durationSeconds
                    )
                    .presentationDetents([.fraction(0.35), .medium])
                    .presentationDragIndicator(.visible)
                }
            }
        }
    }

    private func reminderText(for rule: ReminderRule) -> String {
        guard rule.sound != .dora else { return "" }
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

    private func soundPreviewAccessibilityLabel(for rule: ReminderRule) -> String {
        let format = settingsStore.settings.language.localizedString(forKey: "accessibility.settings.previewSound")
        let reminderName = settingsStore.settings.language.localizedString(forKey: rule.localizationKey)
        return String(
            format: format,
            locale: Locale(identifier: settingsStore.settings.language.localeIdentifier),
            reminderName
        )
    }
    
    private func oneLineRow(
        left: LocalizedStringKey,
        middle: String,
        accessibilityValue: String,
        showSpeaker: Bool,
        isEditable: Bool,
        speakerAccessibilityLabel: String,
        onSpeaker: @escaping () -> Void,
        onTap: @escaping () -> Void
    ) -> some View {
        HStack(spacing: 12) {
            Button(action: onTap) {
                HStack(spacing: 12) {
                    Text(left)
                    Spacer()
                    Text(middle)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }
            }
            .buttonStyle(.plain)
            .disabled(!isEditable)
            .accessibilityLabel(left)
            .accessibilityValue(Text(accessibilityValue))
            .accessibilityHint(isEditable ? "accessibility.settings.editHint" : "")

            if showSpeaker {
                Button(action: onSpeaker) {
                    Image(systemName: "speaker.wave.2.fill")
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Text(speakerAccessibilityLabel))
                .accessibilityHint("accessibility.settings.previewSoundHint")
            }
        }
    }
}
