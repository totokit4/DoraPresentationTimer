//
//  AppModel.swift
//  DoraPresentationTimer
//

import Observation

/// メインシーンと外部ディスプレイシーンで共有する状態。
///
/// 外部ディスプレイのシーンは UIKit の SceneDelegate から組み立てるため、
/// SwiftUI の `@State` では届かない。シングルトンにして両方から同じ実体を参照する。
@MainActor
@Observable
final class AppModel {
    static let shared = AppModel()

    let settingsStore: SettingsStore
    let timerViewModel: TimerViewModel

    /// 外部ディスプレイが接続されているか
    var isExternalDisplayConnected = false

    private init() {
        let settingsStore = SettingsStore()
        self.settingsStore = settingsStore
        self.timerViewModel = TimerViewModel(settingsStore: settingsStore)
    }
}
