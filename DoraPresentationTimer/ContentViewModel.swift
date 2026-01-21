//
//  ContentViewModel.swift
//  DoraPresentationTimer
//
//  Created by totokit4_saki on 2022/11/06.
//

import Foundation
import Combine

final class ContentViewModel: ObservableObject {
    /// 残り秒
    @Published private(set) var remainingSeconds: Int = 0
    /// タイマーが稼働中か
    @Published private(set) var isTimerRunning: Bool = false
    
    /// タイマーの初期値
    private var initCount: Int = 0
    
    private var cancellable: AnyCancellable?
    
    func setInitialTime(minutes: Int, seconds: Int) {
        // 秒に変換
        let total = max(0, minutes * 60 + seconds)
        initCount = total
        
        // タイマーが稼働中は何もしない
        if !isTimerRunning {
            remainingSeconds = total
        }
    }
    
    func startTimer() {
        guard initCount > 0 else { return }
        
        isTimerRunning = true
        remainingSeconds = initCount
        
        let soundViewModel = SoundPlayModel()
        
        // 1秒ごとに更新する
        cancellable = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                
                // 残り秒数を1減らす
                self.remainingSeconds -= 1
                
                switch self.remainingSeconds {
                case 3 * 60:
                    if self.initCount > 3 * 60 {
                        soundViewModel.playSound(type: .clappers1)
                    }
                case 1 * 60:
                    if self.initCount > 1 * 60 {
                        soundViewModel.playSound(type: .clappers2)
                    }
                case 0:
                    soundViewModel.playSound(type: .dora)
                    self.resetCount()
                default:
                    break
                }
            }
    }
    
    func stopTimer() {
        isTimerRunning = false
        cancellable?.cancel()
        cancellable = nil
    }
    
    func resetCount() {
        stopTimer()
        // 初期値に戻す
        remainingSeconds = initCount
    }
}
