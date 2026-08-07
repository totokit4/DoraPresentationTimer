//
//  TimerView.swift
//  DoraPresentationTimer
//
//  Created by totokit4_saki on 2022/11/06.
//

import SwiftUI

/// タイマー画面
struct TimerView: View {
    @EnvironmentObject private var settingsStore: SettingsStore
    @ObservedObject private var viewModel: TimerViewModel
    
    @State private var selectedMinute: Int = 0
    @State private var selectedSecond: Int = 0
    
    @State private var isPickerPresented = false
    
    init(viewModel: TimerViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                VStack {
                    timeSection()
                        .frame(maxHeight: .infinity) // なるべく大きくとる
                    timerButtonsSection
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                if settingsStore.settings.isIOSDCModeEnabled,
                   let message = MarqueeWarningMessage.resolve(
                    remainingSeconds: viewModel.remainingSeconds,
                    isTimerRunning: viewModel.isTimerRunning
                ) {
                    MarqueeWarningText(text: message.text, duration: 5.0)
                        .id(message)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 16)
                        .zIndex(1)
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
                .presentationDetents([.fraction(0.35), .medium]) // ハーフモーダル
                .presentationDragIndicator(.visible)
            }
            .onChange(of: selectedMinute) {
                viewModel.setInitialTime(minutes: selectedMinute, seconds: selectedSecond)
            }
            .onChange(of: selectedSecond) {
                viewModel.setInitialTime(minutes: selectedMinute, seconds: selectedSecond)
            }
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Image(systemName: "gearshape")
                    }
                    .accessibilityLabel("settings.title")
                }
            }
        }
        .onAppear {
            syncSelectedTimeFromViewModel()
        }
    }
    
    /// TimePickerSheet の初期表示を、現在の残り時間に合わせる
    ///
    /// viewModel の値は変更せず、Picker用の selectedMinute / selectedSecond のみ更新する。
    private func syncSelectedTimeFromViewModel() {
        let total = max(0, viewModel.remainingSeconds)
        selectedMinute = total / 60
        selectedSecond = total % 60
    }
}

private extension TimerView {
    private func timeSection() -> some View {
        Button {
            guard !viewModel.isTimerRunning else { return }
            
            syncSelectedTimeFromViewModel()
            isPickerPresented = true
        } label: {
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                let fontSize = min(w * 0.7, h * 0.9)
                
                Text(viewModel.remainingSeconds.formattedAsMMSS)
                    .font(.system(size: fontSize, weight: .regular))
                    .monospacedDigit() // 数字だけ等幅にする
                    // iOSDCモードがONの時は残り時間はほぼ表示しない
                    .opacity(settingsStore.settings.isIOSDCModeEnabled ? 0.01 : 1.0)
                    .foregroundStyle(
                        // 残り10秒で赤くする
                        viewModel.remainingSeconds <= 10 && viewModel.isTimerRunning
                        ? Color.red.opacity(0.85)
                        : Color.primary
                    )
                    .lineLimit(1)
                    .minimumScaleFactor(0.1)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
        }
        .buttonStyle(.plain)
        .disabled(viewModel.isTimerRunning)
        .accessibilityLabel("accessibility.timer.remainingTime")
        .accessibilityValue(Text(viewModel.remainingSeconds.formattedForAccessibility(language: settingsStore.settings.language)))
        .accessibilityHint(viewModel.isTimerRunning ? "accessibility.timer.runningHint" : "accessibility.timer.setTimeHint")
    }
    
    var timerButtonsSection: some View {
        VStack(spacing: 12) {
            primaryButton
            resetButton
        }
        .padding(.horizontal, 24)
    }
    
    /// Start / Pause ボタン
    var primaryButton: some View {
        // 停止中かつ残り時間が0秒のときはStartボタンを無効化する
        let isStartDisabled = !viewModel.isTimerRunning && viewModel.remainingSeconds == 0
        
        return Button {
            if viewModel.isTimerRunning {
                viewModel.stopTimer()
            } else {
                viewModel.startTimer()
            }
        } label: {
            Text(LocalizedStringKey(viewModel.isTimerRunning ? "timer.pause" : "timer.start"))
                .font(.largeTitle)
                .foregroundStyle(primaryButtonForegroundColor(isStartDisabled: isStartDisabled))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
        }
        .disabled(isStartDisabled)
        .background(primaryButtonBackgroundColor(isStartDisabled: isStartDisabled))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .accessibilityHint(viewModel.isTimerRunning ? "accessibility.timer.pauseHint" : "accessibility.timer.startHint")
    }

    private func primaryButtonBackgroundColor(isStartDisabled: Bool) -> Color {
        if isStartDisabled {
            return Color(uiColor: .systemGray4)
        }

        return viewModel.isTimerRunning ? Color(uiColor: .systemGray5) : .orange
    }

    private func primaryButtonForegroundColor(isStartDisabled: Bool) -> Color {
        if isStartDisabled || viewModel.isTimerRunning {
            return .primary
        }

        return .white
    }
    
    /// リセットボタン
    var resetButton: some View {
        Button {
            viewModel.resetCount()
        } label: {
            Label("timer.reset", systemImage: "arrow.counterclockwise")
                .font(.title3)
        }
        .buttonStyle(.plain)
        .foregroundStyle(.secondary)
        .opacity(viewModel.isTimerRunning ? 0.4 : 1.0) // 実行中は目立たなくする
        .disabled(viewModel.isTimerRunning) // 実行中は無効にする
        .accessibilityHint("accessibility.timer.resetHint")
    }
}

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        let settingsStore = SettingsStore()
        
        Group {
            TimerView(viewModel: TimerViewModel(settingsStore: settingsStore))
                .environmentObject(settingsStore)
            
            TimerView(viewModel: TimerViewModel(settingsStore: settingsStore))
                .environmentObject(settingsStore)
                .previewInterfaceOrientation(.landscapeLeft)

            TimerView(viewModel: TimerViewModel(settingsStore: settingsStore))
                .environmentObject(settingsStore)
                .preferredColorScheme(.dark)
        }
    }
}
