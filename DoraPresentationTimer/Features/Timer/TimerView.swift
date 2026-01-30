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
        HStack {
            Button(action: {
                viewModel.startTimer()
            }) {
                Text("Start")
                    .font(.largeTitle)
                    .foregroundColor(.white)
            }
            .disabled(viewModel.isTimerRunning)
            .padding(.all)
            .background(viewModel.isTimerRunning ? Color(UIColor.lightGray) : Color.orange)
            
            Button(action: {
                viewModel.stopTimer()
            }) {
                Text("Pause")
                    .font(.largeTitle)
                    .foregroundColor(.white)
            }
            .disabled(!viewModel.isTimerRunning)
            .padding(.all)
            .background(viewModel.isTimerRunning ? Color.orange : Color(UIColor.lightGray))
            
            Button(action: {
                viewModel.resetCount()
            }) {
                Text("Reset")
                    .font(.largeTitle)
                    .foregroundColor(.white)
            }
            .padding(.all)
            .background(Color.orange)
        }
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
    
    var soundTestButtonsSection: some View {
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
