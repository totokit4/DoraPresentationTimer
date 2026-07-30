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
    
    var body: some View {
        List {
            Section("section.timer") {
                oneLineRow(
                    left: String(localized: "settings.duration"),
                    middle: settingsStore.settings.durationSeconds.formattedAsMMSS,
                    showSpeaker: false,
                    onSpeaker: {},
                    onTap: { editTarget = .duration }
                )
            }

            Section("section.reminders") {
                ForEach(settingsStore.settings.reminders) { r in
                    let middleText = r.sound == .dora ? "" : String(
                        format: NSLocalizedString("settings.reminder.secondsBeforeEnd", comment: ""),
                        r.secondsBeforeEnd ?? 0
                    )
                    
                    oneLineRow(
                        left: r.localizedLabel,
                        middle: middleText,
                        showSpeaker: true,
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
                        Text(mode.displayName).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
            }
        }
        .navigationTitle("settings.title")
        .sheet(item: $editTarget) { target in
            switch target {
            case .duration:
                TimePickerSheet(
                    title: String(localized: "sheet.setDuration"),
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
                        title: rule.localizedLabel,
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
        guard let secondsBeforeEnd = rule.secondsBeforeEnd else { return "未設定" }
        return "終了\(secondsBeforeEnd)秒前"
    }
    
    private func oneLineRow(
        left: String,
        middle: String,
        showSpeaker: Bool,
        onSpeaker: @escaping () -> Void,
        onTap: @escaping () -> Void
    ) -> some View {
        HStack(spacing: 12) {
            Text(left)
            Spacer()
            Text(middle)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .monospacedDigit()
            if showSpeaker {
                Button(action: onSpeaker) {
                    Image(systemName: "speaker.wave.2.fill")
                }
                .buttonStyle(.plain)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
    }
}
