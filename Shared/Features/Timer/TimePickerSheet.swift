//
//  TimePickerSheet.swift
//  DoraPresentationTimer
//
//  Created by saki iwamoto on 2026/01/31.
//

import SwiftUI

struct TimePickerSheet: View {
    @Environment(\.dismiss) private var dismiss

    let title: LocalizedStringKey
    @Binding var totalSeconds: Int
    let isTimerRunning: Bool

    @State private var minute: Int = 0
    @State private var second: Int = 0

    init(
        title: LocalizedStringKey,
        totalSeconds: Binding<Int>,
        isTimerRunning: Bool
    ) {
        self.title = title
        self._totalSeconds = totalSeconds
        self.isTimerRunning = isTimerRunning
    }

    var body: some View {
        NavigationStack {
            HStack(spacing: 24) {
                labeledPicker(title: "time.minute", value: $minute)
                labeledPicker(title: "time.second", value: $second)
            }
            .padding()
            .disabled(isTimerRunning)
            .navigationTitle(Text(title))
            .timerPickerTitleDisplayMode()
            .timerPickerCloseToolbar { dismiss() }
        }
        .onAppear {
            minute = max(0, totalSeconds / 60)
            second = max(0, totalSeconds % 60)
        }
        .onChange(of: minute) { sync() }
        .onChange(of: second) { sync() }
    }

    private func sync() {
        totalSeconds = max(0, minute * 60 + second)
    }

    private func labeledPicker(title: LocalizedStringKey, value: Binding<Int>) -> some View {
        VStack(spacing: 8) {
            Text(title).foregroundStyle(.secondary)
            Picker(title, selection: value) {
                ForEach(0..<60, id: \.self) { Text("\($0)") }
            }
            .pickerStyle(.wheel)
            .clipped()
        }
    }
}

struct ReminderTimePickerSheet: View {
    @Environment(\.dismiss) private var dismiss

    let title: LocalizedStringKey
    @Binding var totalSeconds: Int?
    let maxSeconds: Int

    @State private var minute: Int?
    @State private var second: Int?

    private var normalizedMaxSeconds: Int {
        max(0, maxSeconds)
    }

    private var maxMinute: Int {
        normalizedMaxSeconds / 60
    }

    private var maxSecondForSelectedMinute: Int {
        guard let minute else {
            return min(59, normalizedMaxSeconds)
        }

        return minute == maxMinute ? normalizedMaxSeconds % 60 : 59
    }

    private var minuteValues: [Int] {
        guard maxMinute > 0 else { return [] }
        return Array(0...maxMinute)
    }

    private var secondValues: [Int] {
        guard maxSecondForSelectedMinute > 0 else { return [] }
        return Array(0...maxSecondForSelectedMinute)
    }

    var body: some View {
        NavigationStack {
            HStack(spacing: 24) {
                labeledPicker(title: "time.minute", value: $minute, values: minuteValues)
                labeledPicker(title: "time.second", value: $second, values: secondValues)
            }
            .padding()
            .navigationTitle(Text(title))
            .timerPickerTitleDisplayMode()
            .timerPickerCloseToolbar { dismiss() }
        }
        .onAppear {
            applyInitialValue()
        }
        .onChange(of: minute) { sync() }
        .onChange(of: second) { sync() }
    }

    private func applyInitialValue() {
        guard let totalSeconds, totalSeconds > 0 else {
            minute = nil
            second = nil
            return
        }

        let clamped = min(totalSeconds, normalizedMaxSeconds)
        guard clamped > 0 else {
            minute = nil
            second = nil
            self.totalSeconds = nil
            return
        }

        let initialMinute = clamped / 60
        let initialSecond = clamped % 60
        minute = initialMinute == 0 ? nil : initialMinute
        second = initialSecond == 0 ? nil : initialSecond
        self.totalSeconds = clamped
    }

    private func sync() {
        guard minute != nil || second != nil else {
            totalSeconds = nil
            return
        }

        let clampedSecond: Int?
        if let second, second > maxSecondForSelectedMinute {
            clampedSecond = maxSecondForSelectedMinute > 0 ? maxSecondForSelectedMinute : nil
            self.second = clampedSecond
        } else {
            clampedSecond = second
        }

        let total = min(max(0, (minute ?? 0) * 60 + (clampedSecond ?? 0)), normalizedMaxSeconds)
        totalSeconds = total == 0 ? nil : total
    }

    private func labeledPicker(title: LocalizedStringKey, value: Binding<Int?>, values: [Int]) -> some View {
        VStack(spacing: 8) {
            Text(title).foregroundStyle(.secondary)
            Picker(title, selection: value) {
                Text(" ").tag(Int?.none).accessibilityLabel("settings.reminder.unset")
                ForEach(values, id: \.self) { Text("\($0)").tag(Optional($0)) }
            }
            .pickerStyle(.wheel)
            .clipped()
        }
    }
}

extension View {
    @ViewBuilder
    func timerPickerTitleDisplayMode() -> some View {
        #if os(watchOS)
        self
        #else
        self.navigationBarTitleDisplayMode(.inline)
        #endif
    }

    @ViewBuilder
    func timerPickerCloseToolbar(_ action: @escaping () -> Void) -> some View {
        #if os(watchOS)
        self
        #else
        self.toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("button.close", action: action)
            }
        }
        #endif
    }

}
