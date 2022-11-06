//
//  ContentView.swift
//  DoraPresentationTimer
//
//  Created by totokit4_saki on 2022/11/06.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject private var viewModel: ContentViewModel
    
    init(viewModel: ContentViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            Text("\(viewModel.count)")
                .font(.largeTitle)
                .padding(.bottom)
            
            HStack {
                Button(action: {
                    self.viewModel.startCounting()
                }){
                    Text("Start")
                        .font(.largeTitle)
                        .foregroundColor(Color.white)
                }
                .disabled(viewModel.isTimerRunning)
                .padding(.all)
                .background(viewModel.isTimerRunning ? Color(UIColor.lightGray) : Color.orange)
                
                Button(action: {
                    self.viewModel.stopCounting()
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
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: ContentViewModel())
    }
}
