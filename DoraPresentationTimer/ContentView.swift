//
//  ContentView.swift
//  DoraPresentationTimer
//
//  Created by totokit4_saki on 2022/11/06.
//

import SwiftUI
import Combine

struct ContentView: View {
    @ObservedObject private var viewModel: ContentViewModel
    @State private var selectedMinute = 0
    @State private var selectedSecond = 0
    @State private var cancellable: AnyCancellable?
    
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
        Text("\(String(format: "%02d", selectedMinute)):\(String(format: "%02d", selectedSecond))")
            .font(.system(size: 500))
            .minimumScaleFactor(0.2)
    }

    // TODO: ボタンのサイズ大きくする
    var buttonsSection: some View {
        HStack {
            Button(action: {
                let count = selectedMinute * 60 + selectedSecond
                self.viewModel.startTimer(second: count)

                self.cancellable = self.viewModel.$count
                    .sink { count in
                        selectedMinute = count / 60
                        selectedSecond = count % 60
                    }
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
            picker(selection: $selectedMinute)
            picker(selection: $selectedSecond)
        }
    }

    func picker(selection: Binding<Int>) -> some View {
        Picker(selection: selection, label: EmptyView()) {
            ForEach(0 ..< 60, id: \.self) {
                Text("\($0)")
            }
        }.pickerStyle(WheelPickerStyle())
            .onReceive([selection].publisher.first()) { (value) in
                print("\(value)")
            }
            .clipped()
            .disabled(viewModel.isTimerRunning)
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
