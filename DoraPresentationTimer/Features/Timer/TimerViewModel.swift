//
//  TimerViewModel.swift
//  DoraPresentationTimer
//
//  Created by totokit4_saki on 2022/11/06.
//

import Foundation
import Combine
import UIKit

final class TimerViewModel: ObservableObject {
    /// 残り秒
    @Published private(set) var remainingSeconds: Int = 0
    /// タイマーが稼働中か
    @Published private(set) var isTimerRunning: Bool = false
    
    private let ticker: TimerTicking
    private let soundPlayer: SoundPlaying
    
    private var cancellable: AnyCancellable?
    private let settingsStore: SettingsStore
    private var settingsCancellable: AnyCancellable?
    
    /// タイマーの初期値
    private var initCount: Int = 0
    
    init(
        settingsStore: SettingsStore,
        ticker: TimerTicking = TimerEngine(),
        soundPlayer: SoundPlaying = SoundPlayer()
    ) {
        self.settingsStore = settingsStore
        self.ticker = ticker
        self.soundPlayer = soundPlayer
        
        let settings = settingsStore.settings
        self.initCount = settings.durationSeconds
        self.remainingSeconds = settings.durationSeconds
        
        // 設定変更を監視して、停止中なら反映
        self.settingsCancellable = settingsStore.$settings
            .sink { [weak self] settings in
                guard let self else { return }
                guard !self.isTimerRunning else { return }
                
                self.initCount = settings.durationSeconds
                self.remainingSeconds = settings.durationSeconds
            }
    }
    
    deinit {
        UIApplication.shared.isIdleTimerDisabled = false
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
        // タイマー中はスリープさせない
        UIApplication.shared.isIdleTimerDisabled = true
        
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
        UIApplication.shared.isIdleTimerDisabled = false
        
        cancellable?.cancel()
        cancellable = nil
    }
    
    func resetCount() {
        stopTimer() // 念のため（実行中はdisabledでも安全側に倒す）
        
        guard initCount > 0 else {
            remainingSeconds = 0
            return
        }
        
        if remainingSeconds == initCount {
            // 2回目：クリア
            remainingSeconds = 0
        } else {
            // 1回目：初期値へ
            remainingSeconds = initCount
        }
    }
    
    private func handleTick() {
        guard isTimerRunning else { return }
        guard remainingSeconds > 0 else { return }
        
        // Viewへの反映
        remainingSeconds -= 1
        
        // 音を鳴らすかチェック
        if let event = TimerRules.event(remainingSeconds: remainingSeconds,
                                        durationSeconds: initCount,
                                        reminders: settingsStore.settings.reminders) {
            switch event {
            case .playSound(let sound):
                soundPlayer.play(sound)
                
            case .finished:
                soundPlayer.play(.dora)
                stopTimer()
                // 初期値に戻す
                resetCount()
            }
        }
    }
}
