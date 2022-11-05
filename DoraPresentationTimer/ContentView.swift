//
//  ContentView.swift
//  DoraPresentationTimer
//
//  Created by totokit4_saki on 2022/11/06.
//

import SwiftUI

struct ContentView: View {
    
    @State var RemainingTimeText = "XX:XX"
    @State var isStartable = true
    
    var body: some View {
        VStack {
            Text(RemainingTimeText)
                .font(.largeTitle)
                .padding(.bottom)
            
            HStack {
                Button(action: {
                    self.RemainingTimeText = "Start !"
                    self.isStartable.toggle()
                    // TODO: タイマー開始
                }){
                    Text("Start")
                        .font(.largeTitle)
                        .foregroundColor(Color.white)
                }
                .disabled(!isStartable)
                .padding(.all)
                .background(isStartable ? Color.orange : Color(UIColor.lightGray))
                
                Button(action: {
                    self.RemainingTimeText = "Stop !"
                    self.isStartable.toggle()
                    // TODO: タイマー停止
                }){
                    Text("Pause")
                        .font(.largeTitle)
                        .foregroundColor(Color.white)
                }
                .disabled(isStartable)
                .padding(.all)
                .background(isStartable ? Color(UIColor.lightGray) : Color.orange)
                
                Button(action: {
                    self.RemainingTimeText = "XX:XX"
                    self.isStartable = true
                    // TODO: タイマーリセット
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
        ContentView()
    }
}
