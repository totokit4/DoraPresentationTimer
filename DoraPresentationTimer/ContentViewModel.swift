//
//  ContentViewModel.swift
//  DoraPresentationTimer
//
//  Created by totokit4_saki on 2022/11/06.
//

import Foundation
import AVFoundation
import Combine
import UIKit

final class ContentViewModel: ObservableObject {
    @Published private(set) var count = 0
    @Published private(set) var isTimerRunning = false
    
    private var cancellable: AnyCancellable?
    private var player: AVAudioPlayer?
    
    func startTimer(second: Int) {
        isTimerRunning = true
        count = second
        
        cancellable = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                self.count -= 1
                if self.count == 0 {
                    self.stopTimer()
                    self.playSound()
                }
            }
    }
    
    func stopTimer() {
        isTimerRunning = false
        cancellable?.cancel()
    }
    
    func resetCount() {
        stopTimer()
        // TODO: カウントをもとに戻す
    }
    
    private func playSound(){
        guard let soundFile = NSDataAsset(name: "Dora") else { return }
        do {
            player = try AVAudioPlayer(data:soundFile.data, fileTypeHint:"mp3")
            player?.play()
        } catch {
            print("error")
        }
    }
}
