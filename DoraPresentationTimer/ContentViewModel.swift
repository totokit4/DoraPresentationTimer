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
    private var initCount = 0
    
    func startTimer(second: Int) {
        guard second > 0 else { return }

        isTimerRunning = true
        initCount = second
        count = second
        
        cancellable = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .subscribe(on: DispatchQueue.global())
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.count -= 1
            })
            .filter { [weak self] _ in
                self?.count == 0
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.playSound()
                self?.resetCount()
            }
    }
    
    func stopTimer() {
        isTimerRunning = false
        cancellable?.cancel()
    }
    
    func resetCount() {
        stopTimer()
        count = initCount
    }
}
