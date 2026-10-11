//
//  DoraPresentationTimerApp.swift
//  DoraPresentationTimer
//
//  Created by totokit4_saki on 2022/11/06.
//

import SwiftUI

@main
struct DoraPresentationTimerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    let model = AppModel.shared

    var body: some Scene {
        WindowGroup {
            TimerView(viewModel: model.timerViewModel)
                .environment(model.settingsStore)
                .environment(
                    \.locale,
                    Locale(
                        identifier: model.settingsStore.settings.language
                            .localeIdentifier
                    )
                )
                .preferredColorScheme(
                    model.settingsStore.settings.colorMode.colorScheme
                )
                .modifier(ExternalDisplayAccessory())
        }
    }
}
