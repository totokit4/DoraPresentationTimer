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
    
    init(viewModel: TimerViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                timeSection
                timerButtonsSection
                pickersSection
            }
            .onAppear {
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
}

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TimerView(viewModel: TimerViewModel())
            TimerView(viewModel: TimerViewModel()).previewInterfaceOrientation(.landscapeLeft)
        }
    }
}
