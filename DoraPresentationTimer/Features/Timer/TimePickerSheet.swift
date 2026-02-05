//
//  TimePickerSheet.swift
//  DoraPresentationTimer
//
//  Created by saki iwamoto on 2026/01/31.
//

import SwiftUI

struct TimePickerSheet: View {
    @Environment(\.dismiss) private var dismiss

    let title: String
    @Binding var totalSeconds: Int
    let isTimerRunning: Bool

    @State private var minute: Int = 0
    @State private var second: Int = 0

    var body: some View {
        NavigationStack {
            HStack(spacing: 24) {
                labeledPicker(title: "分", value: $minute)
                labeledPicker(title: "秒", value: $second)
            }
            .padding()
            .disabled(isTimerRunning)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { dismiss() }
                }
            }
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

    private func labeledPicker(title: String, value: Binding<Int>) -> some View {
        VStack(spacing: 8) {
            Text(title).foregroundStyle(.secondary)
            Picker(selection: value, label: EmptyView()) {
                ForEach(0..<60, id: \.self) { Text("\($0)") }
            }
            .pickerStyle(.wheel)
            .clipped()
        }
    }
}
