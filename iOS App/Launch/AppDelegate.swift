//
//  AppDelegate.swift
//  DoraPresentationTimer
//

import UIKit

final class AppDelegate: UIResponder, UIApplicationDelegate {
    /// Info.plist の UIApplicationSceneManifest に定義した構成を、シーンの役割に応じて返す。
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        if connectingSceneSession.role == .windowExternalDisplayNonInteractive {
            return UISceneConfiguration(
                name: "External Configuration",
                sessionRole: connectingSceneSession.role
            )
        }

        return UISceneConfiguration(
            name: "Default Configuration",
            sessionRole: connectingSceneSession.role
        )
    }
}
