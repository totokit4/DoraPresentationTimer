//
//  ContentView.swift
//  DoraPresentationTimer
//
//  Created by totokit4_saki on 2022/11/06.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject private var viewModel: ContentViewModel
    @State private var selectedHour = 0
    @State private var selectedMinute = 0
    @State private var selectedSecond = 10
    
    init(viewModel: ContentViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            timeSection
            buttonsSection
            pickersSection
        }
    }
}

private extension ContentView {
    var timeSection: some View {
        Text("\(viewModel.count / (60 * 60)):\(String(format: "%02d", viewModel.count / 60)):\(String(format: "%02d", viewModel.count % 60))")
            .font(.system(size: 500))
            .minimumScaleFactor(0.2)
    }

    // TODO: ボタンのサイズ大きくする
    var buttonsSection: some View {
        HStack {
            Button(action: {
                let count = selectedHour * 60 * 60  + selectedMinute * 60 + selectedSecond
                self.viewModel.startTimer(second: count)
            }){
                Text("Start")
                    .font(.largeTitle)
                    .foregroundColor(Color.white)
            }
            .disabled(viewModel.isTimerRunning)
            .padding(.all)
            .background(viewModel.isTimerRunning ? Color(UIColor.lightGray) : Color.orange)

            Button(action: {
                self.viewModel.stopTimer()
            }){
                Text("Pause")
                    .font(.largeTitle)
                    .foregroundColor(Color.white)
            }
            .disabled(!viewModel.isTimerRunning)
            .padding(.all)
            .background(viewModel.isTimerRunning ? Color.orange : Color(UIColor.lightGray))

            Button(action: {
                self.viewModel.resetCount()
            }){
                Text("Reset")
                    .font(.largeTitle)
                    .foregroundColor(Color.white)
            }
            .padding(.all)
            .background(Color.orange)
        }
    }

    var pickersSection: some View {
        HStack {
            picker(time: 24, selection: $selectedHour)
            picker(time: 60, selection: $selectedMinute)
            picker(time: 60, selection: $selectedSecond)
        }
    }

    func picker(time: Int, selection: Binding<Int>) -> some View {
        Picker(selection: selection, label: EmptyView()) {
            ForEach(0 ..< time, id: \.self) {
                Text("\($0)")
            }
        }.pickerStyle(WheelPickerStyle())
            .onReceive([selection].publisher.first()) { (value) in
                print("hour: \(value)")
            }
            .clipped()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView(viewModel: ContentViewModel())
            ContentView(viewModel: ContentViewModel()).previewInterfaceOrientation(.landscapeLeft)
        }
    }
}
