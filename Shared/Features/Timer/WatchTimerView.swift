//
//  WatchTimerView.swift
//  DoraPresentationTimer
//
//  Created by OpenAI on 2026/08/15.
//

import SwiftUI

struct WatchTimerView: View {
    @EnvironmentObject private var settingsStore: SettingsStore
    @ObservedObject private var viewModel: TimerViewModel

    @State private var selectedMinute = 0
    @State private var selectedSecond = 0
    @State private var isPickerPresented = false

    init(viewModel: TimerViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 6) {
                timeButton
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                controls
            }
            .padding(.horizontal, 4)
            .padding(.bottom, 2)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink {
                        WatchSettingsView()
                    } label: {
                        Image(systemName: "gearshape")
                            .font(.caption)
                            .frame(width: 28, height: 28)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("settings.title")
                }
            }
            .sheet(isPresented: $isPickerPresented) {
                TimePickerSheet(
                    title: "sheet.setTime",
                    totalSeconds: Binding(
                        get: { selectedMinute * 60 + selectedSecond },
                        set: { total in
                            selectedMinute = total / 60
                            selectedSecond = total % 60
                        }
                    ),
                    isTimerRunning: viewModel.isTimerRunning
                )
            }
            .onChange(of: selectedMinute) {
                viewModel.setInitialTime(minutes: selectedMinute, seconds: selectedSecond)
            }
            .onChange(of: selectedSecond) {
                viewModel.setInitialTime(minutes: selectedMinute, seconds: selectedSecond)
            }
        }
        .onAppear {
            syncSelectedTimeFromViewModel()
        }
    }

    private var timeButton: some View {
        Button {
            guard !viewModel.isTimerRunning else { return }
            syncSelectedTimeFromViewModel()
            isPickerPresented = true
        } label: {
            GeometryReader { proxy in
                let size = min(proxy.size.width * 0.54, proxy.size.height * 0.76)

                Text(viewModel.remainingSeconds.formattedAsMMSS)
                    .font(.system(size: size, weight: .semibold, design: .rounded))
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.45)
                    .foregroundStyle(timeColor)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .buttonStyle(.plain)
        .disabled(viewModel.isTimerRunning)
        .accessibilityLabel("accessibility.timer.remainingTime")
        .accessibilityValue(Text(viewModel.remainingSeconds.formattedForAccessibility(language: settingsStore.settings.language)))
        .accessibilityHint(viewModel.isTimerRunning ? "accessibility.timer.runningHint" : "accessibility.timer.setTimeHint")
    }

    private var controls: some View {
        HStack(spacing: 10) {
            Button {
                viewModel.resetCount()
            } label: {
                Image(systemName: "arrow.counterclockwise")
                    .font(.title3)
                    .frame(width: 40, height: 40)
            }
            .buttonStyle(.bordered)
            .tint(.gray)
            .disabled(viewModel.isTimerRunning)
            .opacity(viewModel.isTimerRunning ? 0.45 : 1.0)
            .accessibilityLabel("timer.reset")
            .accessibilityHint("accessibility.timer.resetHint")

            Button {
                if viewModel.isTimerRunning {
                    viewModel.stopTimer()
                } else {
                    viewModel.startTimer()
                }
            } label: {
                Image(systemName: viewModel.isTimerRunning ? "pause.fill" : "play.fill")
                    .font(.title3)
                    .frame(width: 52, height: 40)
            }
            .buttonStyle(.borderedProminent)
            .tint(viewModel.isTimerRunning ? .gray : .orange)
            .disabled(isStartDisabled)
            .accessibilityLabel(LocalizedStringKey(viewModel.isTimerRunning ? "timer.pause" : "timer.start"))
            .accessibilityHint(viewModel.isTimerRunning ? "accessibility.timer.pauseHint" : "accessibility.timer.startHint")
        }
        .frame(height: 42)
    }

    private var isStartDisabled: Bool {
        !viewModel.isTimerRunning && viewModel.remainingSeconds == 0
    }

    private var timeColor: Color {
        viewModel.remainingSeconds <= 10 && viewModel.isTimerRunning ? .red : .primary
    }

    private func syncSelectedTimeFromViewModel() {
        let total = max(0, viewModel.remainingSeconds)
        selectedMinute = total / 60
        selectedSecond = total % 60
    }
}

#Preview {
    let settingsStore = SettingsStore()

    WatchTimerView(viewModel: TimerViewModel(settingsStore: settingsStore))
        .environmentObject(settingsStore)
}
