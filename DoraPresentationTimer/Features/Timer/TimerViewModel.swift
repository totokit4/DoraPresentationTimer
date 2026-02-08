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
    private let settingsStore: SettingsStore
    
    private var cancellables = Set<AnyCancellable>()   // 常時購読（設定など）
    private var tickCancellable: AnyCancellable?       // タイマー稼働中のみ
    
    private var sessionDurationSeconds: Int = 0
    private var sessionReminders: [ReminderRule] = []
    
    init(
        settingsStore: SettingsStore,
        ticker: TimerTicking = TimerEngine(),
        soundPlayer: SoundPlaying = SoundPlayer()
    ) {
        self.settingsStore = settingsStore
        self.ticker = ticker
        self.soundPlayer = soundPlayer
        
        applyDurationFromSettings(settingsStore.settings)
        
        // 設定変更を監視して、停止中なら反映
        settingsStore.$settings
            .sink { [weak self] settings in
                self?.applyDurationFromSettings(settings)
            }
            .store(in: &cancellables)
    }
    
    deinit {
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    func setInitialTime(minutes: Int, seconds: Int) {
        // タイマーが稼働中は何もしない
        guard !isTimerRunning else { return }
        // 秒に変換
        let total = max(0, minutes * 60 + seconds)
        
        settingsStore.update { $0.durationSeconds = total }
    }
    
    func startTimer() {
        guard !isTimerRunning else { return }
        
        let duration = max(0, sessionDurationSeconds)
        guard duration > 0 else { return }
        
        sessionDurationSeconds = duration
        remainingSeconds = duration
        
        // このセッションで使うremindersを固定
        sessionReminders = settingsStore.settings.reminders
        
        isTimerRunning = true
        // タイマー中はスリープさせない
        UIApplication.shared.isIdleTimerDisabled = true
        
        tickCancellable = ticker.tick
            .sink { [weak self] in
                guard let self else { return }
                // 残時間を更新
                self.handleTick()
            }
    }
    
    func stopTimer() {
        isTimerRunning = false
        UIApplication.shared.isIdleTimerDisabled = false
        
        tickCancellable?.cancel()
        tickCancellable = nil
        
        sessionReminders = [] 
    }
    
    func resetCount() {
        stopTimer() // 念のため（実行中はdisabledでも安全側に倒す）
        
        guard sessionDurationSeconds > 0 else {
            remainingSeconds = 0
            return
        }
        
        if remainingSeconds == sessionDurationSeconds {
            // 2回目：クリア(0:00)
            remainingSeconds = 0
            settingsStore.update { $0.durationSeconds = 0 }
        } else {
            // 1回目：初期値へ
            remainingSeconds = sessionDurationSeconds
        }
    }
    
    /// タイマー設定を反映
    private func applyDurationFromSettings(_ settings: AppSettings) {
        // タイマーが稼働中は何もしない
        guard !isTimerRunning else { return }
        
        sessionDurationSeconds = settings.durationSeconds
        remainingSeconds = settings.durationSeconds
    }
    
    private func handleTick() {
        guard isTimerRunning else { return }
        guard remainingSeconds > 0 else { return }
        
        // Viewへの反映
        remainingSeconds -= 1
        
        // 音を鳴らすかチェック
        if let event = TimerRules.event(
            remainingSeconds: remainingSeconds,
            durationSeconds: sessionDurationSeconds,
            reminders: sessionReminders // Storeではなく固定した方を見る
        ) {
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
