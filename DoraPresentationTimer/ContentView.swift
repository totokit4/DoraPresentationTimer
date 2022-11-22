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
            Text("\(viewModel.count / (60 * 60)):\(String(format: "%02d", viewModel.count / 60)):\(String(format: "%02d", viewModel.count % 60))")
                .font(.largeTitle)
                .padding(.bottom)
            
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

            HStack {
                Picker(selection: self.$selectedHour, label: EmptyView()) {
                    ForEach(0 ..< 24) {
                        Text("\($0)")
                    }
                }.pickerStyle(WheelPickerStyle())
                    .onReceive([self.selectedHour].publisher.first()) { (value) in
                        print("hour: \(value)")
                    }
                    .clipped()

                Picker(selection: self.$selectedMinute, label: EmptyView()) {
                    ForEach(0 ..< 60) {
                        Text("\($0)")
                    }
                }.pickerStyle(WheelPickerStyle())
                    .onReceive([self.selectedMinute].publisher.first()) { (value) in
                        print("minute: \(value)")
                    }.labelsHidden()
                    .clipped()

                Picker(selection: self.$selectedSecond, label: EmptyView()) {
                    ForEach(0 ..< 60) {
                        Text("\($0)")
                    }
                }.pickerStyle(WheelPickerStyle())
                    .onReceive([self.selectedSecond].publisher.first()) { (value) in
                        print("minute: \(value)")
                    }.labelsHidden()
                    .clipped()
            }
        }.padding(.top)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: ContentViewModel())
    }
}
