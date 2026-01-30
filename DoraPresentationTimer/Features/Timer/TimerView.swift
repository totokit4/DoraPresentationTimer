//
//  TimerView.swift
//  DoraPresentationTimer
//
//  Created by totokit4_saki on 2022/11/06.
//

import SwiftUI

struct TimerView: View {
    @ObservedObject private var viewModel: TimerViewModel
    
    @State private var selectedMinute: Int = 0
    @State private var selectedSecond: Int = 0
    
    private let soundPlayer = SoundPlayer()
    
    init(viewModel: TimerViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            timeSection
            timerButtonsSection
            pickersSection
            soundTestButtonsSection
        }
        .onAppear {
            viewModel.setInitialTime(minutes: selectedMinute, seconds: selectedSecond)
        }
    }
}

private extension TimerView {
    var timeSection: some View {
        Text(viewModel.remainingSeconds.formattedAsMMSS)
            .font(.system(size: 300))
            .minimumScaleFactor(0.1)
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
    
    var pickersSection: some View {
        HStack {
            picker(selection: $selectedMinute)
                .onChange(of: selectedMinute) {
                    viewModel.setInitialTime(minutes: selectedMinute, seconds: selectedSecond)
                }
            
            picker(selection: $selectedSecond)
                .onChange(of: selectedSecond) {
                    viewModel.setInitialTime(minutes: selectedMinute, seconds: selectedSecond)
                }
        }
    }
    
    private func picker(selection: Binding<Int>) -> some View {
        Picker(selection: selection, label: EmptyView()) {
            ForEach(0 ..< 60, id: \.self) {
                Text("\($0)")
            }
        }
        .pickerStyle(.wheel)
        .clipped()
        .disabled(viewModel.isTimerRunning)
    }
    
    private var soundTestButtonsSection: some View {
        VStack {
            Text("SoundTest")
                .font(.largeTitle)
                .foregroundColor(.brown)
            HStack {
                soundTestButton(type: .clappers1)
                soundTestButton(type: .clappers2)
                soundTestButton(type: .dora)
            }
        }
    }
    
    private func soundTestButton(type: SoundType) -> some View {
        Button(action: {
            soundPlayer.play(type)
        }) {
            Text(type.buttonTitle)
                .font(.largeTitle)
                .foregroundColor(.white)
        }
        .padding(.all)
        .background(Color.brown)
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

private extension Int {
    var formattedAsMMSS: String {
        let m = self / 60
        let s = self % 60
        return String(format: "%02d:%02d", m, s)
    }
}
