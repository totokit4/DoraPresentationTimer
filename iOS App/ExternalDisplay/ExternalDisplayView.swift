//
//  ExternalDisplayView.swift
//  DoraPresentationTimer
//

import SwiftUI

/// 外部ディスプレイに出す表示専用の画面。
///
/// 背景の上に、以下を重ねて出す。
/// - マーキー警告（iOSDCモードONかつ警告中のみ）
/// - 残り時間（「カウントダウンを表示」がONのときのみ）
///
/// 文字色はどちらもペンライトカラー（`MarqueeWarningText` と同じ）。
struct ExternalDisplayView: View {
    @Environment(SettingsStore.self) private var settingsStore

    let viewModel: TimerViewModel

    // MARK: - 表示調整用の定数
    //
    // いずれも画面サイズに対する比率。プロジェクターの解像度が変わっても見え方を揃える。

    /// マーキーの文字サイズ（画面高さに対する比率）
    private let marqueeFontHeightRatio: CGFloat = 0.10
    /// マーキーを出す位置（画面上端からの比率）
    private let marqueeTopInsetRatio: CGFloat = 0.05
    /// マーキーの行の高さ（文字サイズに対する倍率）。上下が欠けない程度に余裕を持たせる
    private let marqueeLineHeightRatio: CGFloat = 1.5

    var body: some View {
        GeometryReader { geo in
            ZStack {
                backgroundColor

                if settingsStore.settings.isExternalDisplayTimerVisible {
                    remainingTime(in: geo.size)
                }

                if settingsStore.settings.isIOSDCModeEnabled {
                    marquee(in: geo.size)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .ignoresSafeArea()
    }

    private var backgroundColor: Color {
        Color(hexString: settingsStore.settings.externalDisplayBackgroundColorHex)
            ?? Color(hexString: AppSettings.defaultExternalDisplayBackgroundColorHex)
            ?? .black
    }

    /// iOSDCモード時。警告が出ていない間は何も描かない（背景だけ）
    @ViewBuilder
    private func marquee(in size: CGSize) -> some View {
        if let message = MarqueeWarningMessage.resolve(
            remainingSeconds: viewModel.remainingSeconds,
            isTimerRunning: viewModel.isTimerRunning
        ) {
            let fontSize = size.height * marqueeFontHeightRatio

            MarqueeWarningText(
                text: message.text,
                fontSize: fontSize,
                height: fontSize * marqueeLineHeightRatio
            )
            .padding(.top, size.height * marqueeTopInsetRatio)
            .frame(maxHeight: .infinity, alignment: .top)
        }
    }

    private func remainingTime(in size: CGSize) -> some View {
        Text(viewModel.remainingSeconds.formattedAsMMSS)
            .font(.system(size: min(size.width * 0.7, size.height * 0.9), weight: .regular))
            .monospacedDigit() // 数字だけ等幅にする
            .foregroundStyle(settingsStore.settings.penlightColor.color)
            .lineLimit(1)
            .minimumScaleFactor(0.1)
            .padding(.horizontal, size.width * 0.05)
            .accessibilityLabel("accessibility.timer.remainingTime")
            .accessibilityValue(
                Text(viewModel.remainingSeconds.formattedForAccessibility(language: settingsStore.settings.language))
            )
    }
}

#Preview {
    let settingsStore = SettingsStore()

    ExternalDisplayView(viewModel: TimerViewModel(settingsStore: settingsStore))
        .environment(settingsStore)
}
