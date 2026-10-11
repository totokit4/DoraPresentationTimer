//
//  ExternalDisplayAccessory.swift
//  DoraPresentationTimer
//

import SwiftUI

/// iOS 27 以降の外部ディスプレイ表示。
///
/// iOS 27 からは、外部ディスプレイに出す内容を Scene Accessory として宣言し、
/// 接続されたときにシステムがそれを表示する。iOS 26 以前は `ExternalDisplaySceneDelegate` が担当する。
struct ExternalDisplayAccessory: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 27.0, *) {
            let model = AppModel.shared

            content.sceneAccessory {
                ExternalNonInteractiveAccessory {
                    ExternalDisplayView(viewModel: model.timerViewModel)
                        .environment(model.settingsStore)
                }
                .onAvailabilityChange { isAvailable in
                    model.isExternalDisplayConnected = isAvailable
                }
            }
        } else {
            content
        }
    }
}
