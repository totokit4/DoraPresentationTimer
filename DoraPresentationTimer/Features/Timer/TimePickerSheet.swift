//
//  TimePickerSheet.swift
//  DoraPresentationTimer
//
//  Created by saki iwamoto on 2026/01/31.
//

import SwiftUI

struct TimePickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedMinute: Int
    @Binding var selectedSecond: Int
    let isTimerRunning: Bool

    var body: some View {
        NavigationStack {
            HStack(spacing: 24) {
                LabeledWheelPicker(title: "分", value: $selectedMinute)
                LabeledWheelPicker(title: "秒", value: $selectedSecond)
            }
            .padding()
            .disabled(isTimerRunning)
            .navigationTitle("Set Time")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}

private struct LabeledWheelPicker: View {
    let title: String
    @Binding var value: Int
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.default)
                .foregroundStyle(.secondary)
            
            Picker(selection: $value, label: EmptyView()) {
                ForEach(0..<60, id: \.self) { Text("\($0)") }
            }
            .pickerStyle(.wheel)
            .clipped()
        }
    }
}
