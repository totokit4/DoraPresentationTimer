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

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settingsStore: SettingsStore
    @State private var editTarget: EditTarget?

    private let soundPlayer = SoundPlayer()

    var body: some View {
        List {
            Section("Timer") {
                oneLineRow(
                    left: "発表時間",
                    middle: settingsStore.settings.durationSeconds.formattedAsMMSS,
                    showSpeaker: false,
                    onSpeaker: {},
                    onTap: { editTarget = .duration }
                )
            }

            Section("Reminders") {
                ForEach(settingsStore.settings.reminders) { r in
                    oneLineRow(
                        left: r.label,
                        middle: r.secondsBeforeEnd == 0 ? "終了" : "終了\(r.secondsBeforeEnd)秒前",
                        showSpeaker: true,
                        onSpeaker: { soundPlayer.play(r.sound) },
                        onTap: {
                            guard r.secondsBeforeEnd != 0 else { return } 
                            editTarget = .reminder(r.id)
                        }
                    )
                }
            }
        }
        .navigationTitle("Settings")
        .sheet(item: $editTarget) { target in
            switch target {
            case .duration:
                TimePickerSheet(
                    title: "Set Duration",
                    totalSeconds: Binding(
                        get: { settingsStore.settings.durationSeconds },
                        set: { settingsStore.settings.durationSeconds = $0 }
                    ),
                    isTimerRunning: false
                )
                .presentationDetents([.fraction(0.35), .medium])
                .presentationDragIndicator(.visible)

            case .reminder(let id):
                if let idx = settingsStore.settings.reminders.firstIndex(where: { $0.id == id }) {
                    TimePickerSheet(
                        title: settingsStore.settings.reminders[idx].label,
                        totalSeconds: $settingsStore.settings.reminders[idx].secondsBeforeEnd,
                        isTimerRunning: false
                    )
                    .presentationDetents([.fraction(0.35), .medium])
                    .presentationDragIndicator(.visible)
                }
            }
        }
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
