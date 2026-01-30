//
//  TimerViewModel.swift
//  DoraPresentationTimer
//
//  Created by totokit4_saki on 2022/11/06.
//

import Foundation
import Combine

final class TimerViewModel: ObservableObject {
    /// 残り秒
    @Published private(set) var remainingSeconds: Int = 0
    /// タイマーが稼働中か
    @Published private(set) var isTimerRunning: Bool = false
    
    private let ticker: TimerTicking
    private let sound: SoundPlaying
    
    private var cancellable: AnyCancellable?
    /// タイマーの初期値
    private var initCount: Int = 0
    
    init(ticker: TimerTicking = TimerEngine(), sound: SoundPlaying = SoundPlayer()) {
        self.ticker = ticker
        self.sound = sound
    }
    
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
        // 連打対策
        guard initCount > 0 else { return }
        guard !isTimerRunning else { return }
        
        isTimerRunning = true
        remainingSeconds = initCount
        
        cancellable = ticker.tick
            .sink { [weak self] in
                guard let self else { return }
                // 残時間を更新
                self.handleTick()
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
    
    private func handleTick() {
        guard isTimerRunning else { return }
        guard remainingSeconds > 0 else { return }
        
        // Viewへの反映
        remainingSeconds -= 1
        
        // 音を鳴らすかチェック
        if let event = TimerRules.event(remainingSeconds: remainingSeconds,
                                        durationSeconds: initCount) {
            switch event {
            case .playSound(let soundType):
                sound.play(soundType)
            case .finished:
                sound.play(.dora)
                stopTimer()
                // 初期値に戻す
                resetCount()
            }
        }
    }
}
