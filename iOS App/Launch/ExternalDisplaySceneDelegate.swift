//
//  ExternalDisplaySceneDelegate.swift
//  DoraPresentationTimer
//

import SwiftUI
import UIKit

/// (iOS 26 以前) 外部ディスプレイに `ExternalDisplayView` を表示する。
/// Info.plist の `UIWindowSceneSessionRoleExternalDisplayNonInteractive`（External Configuration）から生成される。
final class ExternalDisplaySceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        // iOS 27 以降は Scene Accessory（ExternalDisplayAccessory）が表示を担当するので、二重に出さない
        if #available(iOS 27.0, *) { return }
        guard let windowScene = scene as? UIWindowScene else { return }

        let model = AppModel.shared
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = ExternalDisplayViewController(
            rootView: ExternalDisplayView(viewModel: model.timerViewModel)
                .environment(model.settingsStore)
        )
        window.makeKeyAndVisible()

        self.window = window
        model.isExternalDisplayConnected = true
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        if #available(iOS 27.0, *) { return }

        window = nil
        AppModel.shared.isExternalDisplayConnected = false
    }
}
