//
//  MarqueeWarningText.swift
//  DoraPresentationTimer
//

import SwiftUI

/// 流れる警告メッセージの種類
enum MarqueeWarningMessage: Equatable, Identifiable {
    case oneMinuteBefore
    case thirtySecondsBefore

    var id: Self { self }

    var text: String {
        switch self {
        case .oneMinuteBefore:
            return "残り時間わずか　ペンライトを振れ!!"
        case .thirtySecondsBefore:
            return "時間切れ直前!! ペンライトを激しく振れ!!"
        }
    }

    static func resolve(
        remainingSeconds: Int,
        isTimerRunning: Bool
    ) -> MarqueeWarningMessage? {
        guard isTimerRunning else { return nil }

        switch remainingSeconds {
        case 1...30:
            return .thirtySecondsBefore
        case 31...60:
            return .oneMinuteBefore
        default:
            return nil
        }
    }
}

/// 右から左へ流れる警告テキスト
struct MarqueeWarningText: View {
    @Environment(SettingsStore.self) private var settingsStore

    /// 1周（右端から出て左端へ抜けきるまで）にかかる秒数。
    static let defaultDuration: TimeInterval = 5.0

    let text: String
    var duration: TimeInterval = defaultDuration
    /// 文字サイズ。外部ディスプレイでは画面に合わせて大きくする
    var fontSize: CGFloat = 30
    /// 行の高さ。外部ディスプレイでは fontSize に合わせて大きくする
    var height: CGFloat = 44

    var body: some View {
        GeometryReader { geo in
            MarqueeWarningTextLine(
                text: text,
                duration: duration,
                color: settingsStore.settings.penlightColor.color,
                fontSize: fontSize,
                containerWidth: geo.size.width
            )
        }
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .clipped()
        .allowsHitTesting(false)
    }
}

private struct MarqueeWarningTextLine: View {
    let text: String
    let duration: TimeInterval
    let color: Color
    let fontSize: CGFloat
    let containerWidth: CGFloat

    @State private var startDate = Date()
    @State private var textWidth: CGFloat = 0

    var body: some View {
        TimelineView(.animation) { timeline in
            Text(text)
                .font(.custom("DotGothic16-Regular", size: fontSize))
                .foregroundStyle(color)
                .shadow(color: .black.opacity(0.3), radius: 2, x: 1, y: 1)
                .lineLimit(1)
                .fixedSize()
                .background {
                    GeometryReader { textGeo in
                        Color.clear
                            .onAppear {
                                updateTextWidth(textGeo.size.width)
                            }
                            .onChange(of: textGeo.size.width) {
                                updateTextWidth(textGeo.size.width)
                            }
                        }
                }
                .offset(x: offset(at: timeline.date))
        }
    }

    private func updateTextWidth(_ width: CGFloat) {
        guard textWidth != width else { return }

        textWidth = width
    }

    private func offset(at date: Date) -> CGFloat {
        // 右端から出て、文字の末尾が左端へ抜けきるまでの距離
        let travelDistance = containerWidth + textWidth

        guard containerWidth > 0, textWidth > 0, duration > 0 else {
            return containerWidth
        }

        let elapsed = date.timeIntervalSince(startDate)
        let progress = elapsed.truncatingRemainder(dividingBy: duration) / duration

        return containerWidth - travelDistance * progress
    }
}

/// 流れる文字の色
enum PenlightColor: String, Codable, CaseIterable, Equatable, Identifiable {
    case blue
    case cyan
    case green
    case indigo
    case mint
    case orange
    case pink
    case purple
    case red
    case yellow

    var id: Self { self }

    var displayName: String {
        switch self {
        case .blue: return "Blue"
        case .cyan: return "Cyan"
        case .green: return "Green"
        case .indigo: return "Indigo"
        case .mint: return "Mint"
        case .orange: return "Orange"
        case .pink: return "Pink"
        case .purple: return "Purple"
        case .red: return "Red"
        case .yellow: return "Yellow"
        }
    }

    var color: Color {
        switch self {
        case .blue: return .blue
        case .cyan: return .cyan
        case .green: return .green
        case .indigo: return .indigo
        case .mint: return .mint
        case .orange: return .orange
        case .pink: return .pink
        case .purple: return .purple
        case .red: return .red
        case .yellow: return .yellow
        }
    }
}
