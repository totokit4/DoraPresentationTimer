//
//  ContentViewModel.swift
//  DoraPresentationTimer
//
//  Created by totokit4_saki on 2022/11/06.
//

import Foundation
import Combine

final class ContentViewModel: ObservableObject {
    @Published private(set) var count = 0
    @Published private(set) var isTimerRunning = false
    
    private var cancellable: AnyCancellable?
    
    func startTimer(second: Int) {
        isTimerRunning = true
        count = second
        
        cancellable = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                self.count -= 1
                if self.count == 0 {
                    self.stopTimer()
                    print("銅鑼を鳴らす")
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
}
