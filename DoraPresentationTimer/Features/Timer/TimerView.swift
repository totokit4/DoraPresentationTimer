//
//  TimerView.swift
//  DoraPresentationTimer
//
//  Created by totokit4_saki on 2022/11/06.
//

import SwiftUI

/// タイマー画面
struct TimerView: View {
    @ObservedObject private var viewModel: TimerViewModel
    
    @State private var selectedMinute: Int = 0
    @State private var selectedSecond: Int = 0
    
    @State private var isPickerPresented = false
    
    init(viewModel: TimerViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                timeSection()
                    .frame(maxHeight: .infinity) // なるべく大きくとる
                timerButtonsSection
            }
            .sheet(isPresented: $isPickerPresented) {
                TimePickerSheet(
                    selectedMinute: $selectedMinute,
                    selectedSecond: $selectedSecond,
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
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        SoundTestView()
                    } label: {
                        Image(systemName: "speaker.wave.2")
                    }
                }
            }
        }
        .onAppear {
            viewModel.setInitialTime(minutes: selectedMinute, seconds: selectedSecond)
        }
    }
}

private extension TimerView {
    private func timeSection() -> some View {
        Button {
            guard !viewModel.isTimerRunning else { return }
            isPickerPresented = true
        } label: {
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                let fontSize = min(w * 0.7, h * 0.9)
                
                Text(viewModel.remainingSeconds.formattedAsMMSS)
                    .font(.system(size: fontSize, weight: .regular))
                    .lineLimit(1)
                    .minimumScaleFactor(0.1)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
        }
        .buttonStyle(.plain)
    }

    var timerButtonsSection: some View {
        VStack(spacing: 12) {
            primaryButton
            resetButton
        }
        .padding(.horizontal, 24)
    }
    
    /// Start/Pauseボタン
    var primaryButton: some View {
        Button {
            if viewModel.isTimerRunning {
                viewModel.stopTimer()
            } else {
                viewModel.startTimer()
            }
        } label: {
            Text(viewModel.isTimerRunning ? "Pause" : "Start")
                .font(.largeTitle)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
        }
        .background(viewModel.isTimerRunning ? Color(UIColor.lightGray) : Color.orange)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    /// リセットボタン
    var resetButton: some View {
        Button {
            viewModel.resetCount()
        } label: {
            Label("Reset", systemImage: "arrow.counterclockwise")
                .font(.title3)
        }
        .buttonStyle(.plain)
        .foregroundStyle(.secondary)
        .opacity(viewModel.isTimerRunning ? 0.4 : 1.0) // 実行中は目立たなくする
        .disabled(viewModel.isTimerRunning) // 実行中は無効にする
    }
}

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TimerView(viewModel: TimerViewModel())
            TimerView(viewModel: TimerViewModel()).previewInterfaceOrientation(.landscapeLeft)
        }
    }
}
