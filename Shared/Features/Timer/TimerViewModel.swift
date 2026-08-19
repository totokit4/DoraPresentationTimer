//
//  TimerViewModel.swift
//  DoraPresentationTimer
//
//  Created by totokit4_saki on 2022/11/06.
//

import Foundation
import Combine
#if os(iOS)
import UIKit
#endif

final class TimerViewModel: ObservableObject {
    /// 残り秒
    @Published private(set) var remainingSeconds: Int = 0
    /// タイマーが稼働中か
    @Published private(set) var isTimerRunning: Bool = false
    
    private let ticker: TimerTicking
    private let soundPlayer: SoundPlaying
    private let settingsStore: SettingsStore
    private let notificationScheduler: NotificationScheduler
    
    private var cancellables = Set<AnyCancellable>()   // 常時購読（設定など）
    private var tickCancellable: AnyCancellable?       // タイマー稼働中のみ
    
    private var sessionDurationSeconds: Int = 0
    private var sessionReminders: [ReminderRule] = []
    private var timerEndDate: Date?
    
    init(
        settingsStore: SettingsStore,
        ticker: TimerTicking = TimerEngine(),
        soundPlayer: SoundPlaying = SoundPlayer(),
        notificationScheduler: NotificationScheduler = NotificationScheduler()
    ) {
        self.settingsStore = settingsStore
        self.ticker = ticker
        self.soundPlayer = soundPlayer
        self.notificationScheduler = notificationScheduler
        
        applyDurationFromSettings(settingsStore.settings)
        
        // 設定変更を監視して、停止中なら反映
        settingsStore.$settings
            .sink { [weak self] settings in
                self?.applyDurationFromSettings(settings)
            }
            .store(in: &cancellables)
    }
    
    deinit {
        setIdleTimerDisabled(false)
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
        
        // 0:00 からは開始できない
        if remainingSeconds == 0 {
            // 初回開始（or クリア状態）なら設定値から開始
            let duration = max(0, sessionDurationSeconds)
            guard duration > 0 else { return }
            
            sessionDurationSeconds = duration
            remainingSeconds = duration
        } else {
            // 再開：remainingSeconds は触らない
            // sessionDurationSeconds が未セットなら補完
            if sessionDurationSeconds == 0 {
                sessionDurationSeconds = max(0, settingsStore.settings.durationSeconds)
            }
        }
        
        // このセッションで使うremindersを固定
        sessionReminders = settingsStore.settings.reminders
        timerEndDate = Date().addingTimeInterval(TimeInterval(remainingSeconds))

        isTimerRunning = true
        // タイマー中はスリープさせない
        setIdleTimerDisabled(true)
        notificationScheduler.schedule(
            reminders: sessionReminders,
            remainingSeconds: remainingSeconds,
            durationSeconds: sessionDurationSeconds,
            settings: settingsStore.settings,
            shouldSchedule: { [weak self] in self?.isTimerRunning == true }
        )
        
        tickCancellable = ticker.tick
            .sink { [weak self] in
                guard let self else { return }
                // 残時間を更新
                self.handleTick()
            }
    }
    
    func stopTimer() {
        isTimerRunning = false
        setIdleTimerDisabled(false)
        
        tickCancellable?.cancel()
        tickCancellable = nil
        
        timerEndDate = nil
        sessionReminders = [] 
        notificationScheduler.cancel()
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
        guard let timerEndDate else { return }

        let updatedRemainingSeconds = max(0, Int(ceil(timerEndDate.timeIntervalSinceNow)))
        guard updatedRemainingSeconds != remainingSeconds else { return }

        // Viewへの反映。終了予定時刻から逆算することで、watchOSで画面が消えても再開時に正しい残り時間へ戻す。
        remainingSeconds = updatedRemainingSeconds
        
        // 音を鳴らすかチェック
        if let event = TimerRules.event(
            remainingSeconds: remainingSeconds,
            durationSeconds: sessionDurationSeconds,
            reminders: sessionReminders // Storeではなく固定した方を見る
        ) {
            switch event {
            case .playSound(let sound):
                // iOSDCモードがONであればリマインダーの音は鳴らさない
                guard !settingsStore.settings.isIOSDCModeEnabled else { return }
                soundPlayer.play(sound)
                announceReminder(for: sound)
                
            case .finished:
                soundPlayer.play(.dora)
                announce(settingsStore.settings.language.localizedString(forKey: "accessibility.timer.finished"))
                stopTimer()
                // 初期値に戻す
                resetCount()
            }
        }

        if remainingSeconds == 0 {
            stopTimer()
            resetCount()
        }
    }

    private func announceReminder(for sound: SoundType) {
        guard let rule = sessionReminders.first(where: { $0.sound == sound }) else { return }
        announce(settingsStore.settings.language.localizedString(forKey: rule.localizationKey))
    }

    private func announce(_ message: String) {
        #if os(iOS)
        UIAccessibility.post(notification: .announcement, argument: message)
        #endif
    }

    private func setIdleTimerDisabled(_ isDisabled: Bool) {
        #if os(iOS)
        UIApplication.shared.isIdleTimerDisabled = isDisabled
        #endif
    }
}
