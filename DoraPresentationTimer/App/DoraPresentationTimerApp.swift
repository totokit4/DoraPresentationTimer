//
//  DoraPresentationTimerApp.swift
//  DoraPresentationTimer
//
//  Created by totokit4_saki on 2022/11/06.
//

import SwiftUI

@main
struct DoraPresentationTimerApp: App {
    @StateObject private var settingsStore = SettingsStore()

    var body: some Scene {
        WindowGroup {
            TimerView(viewModel: TimerViewModel(settingsStore: settingsStore)).environmentObject(settingsStore)
        }
    }
}
