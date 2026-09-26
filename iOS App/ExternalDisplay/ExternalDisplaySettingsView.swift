//
//  ExternalDisplaySettingsView.swift
//  DoraPresentationTimer
//

import SwiftUI

/// 外部ディスプレイの表示設定。タイマー画面の「接続中」ボタンから開く。
///
/// 会場でプロジェクターを見ながら調整する想定なので、設定画面ではなくここにまとめている。
struct ExternalDisplaySettingsView: View {
    @Environment(SettingsStore.self) private var settingsStore
    @Environment(\.dismiss) private var dismiss

    private var backgroundColorBinding: Binding<Color> {
        Binding(
            get: {
                Color(hexString: settingsStore.settings.externalDisplayBackgroundColorHex)
                    ?? Color(hexString: AppSettings.defaultExternalDisplayBackgroundColorHex)
                    ?? .black
            },
            set: { newValue in
                settingsStore.update { $0.externalDisplayBackgroundColorHex = newValue.hexString }
            }
        )
    }

    private var isTimerVisibleBinding: Binding<Bool> {
        Binding(
            get: { settingsStore.settings.isExternalDisplayTimerVisible },
            set: { newValue in
                settingsStore.update { $0.isExternalDisplayTimerVisible = newValue }
            }
        )
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ColorPicker(
                        "externalDisplay.backgroundColor",
                        selection: backgroundColorBinding,
                        supportsOpacity: false
                    )
                    Toggle("externalDisplay.showTimer", isOn: isTimerVisibleBinding)
                } footer: {
                    Text("externalDisplay.footer")
                }
            }
            .navigationTitle("externalDisplay.title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("button.close") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    ExternalDisplaySettingsView()
        .environment(SettingsStore())
}
