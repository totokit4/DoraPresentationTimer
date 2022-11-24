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

        let soundViewModel = SoundPlayModel()
        cancellable = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .subscribe(on: DispatchQueue.global())
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.count -= 1
            })
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let initCount = self?.initCount else { return }

                switch self?.count {
                case 3 * 60:
                    if initCount > 3 * 60 {
                        soundViewModel.playSound(type: .clappers1)
                    }
                case 1 * 60:
                    if initCount > 1 * 60 {
                        soundViewModel.playSound(type: .clappers2)
                    }
                case 0:
                    soundViewModel.playSound(type: .dora)
                    self?.resetCount()
                default:
                    break
                }
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
