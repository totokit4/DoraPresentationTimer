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
    @EnvironmentObject private var settingsStore: SettingsStore

    let text: String
    let duration: Double

    var body: some View {
        GeometryReader { geo in
            MarqueeWarningTextLine(
                text: text,
                duration: duration,
                color: settingsStore.settings.penlightColor.color,
                containerWidth: geo.size.width
            )
        }
        .frame(maxWidth: .infinity)
        .frame(height: 44)
        .clipped()
        .allowsHitTesting(false)
    }
}

private struct MarqueeWarningTextLine: View {
    let text: String
    let duration: Double
    let color: Color
    let containerWidth: CGFloat

    @State private var startDate = Date()
    @State private var textWidth: CGFloat = 0

    var body: some View {
        TimelineView(.animation) { timeline in
            Text(text)
                .font(.custom("DotGothic16-Regular", size: 30))
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
        guard containerWidth > 0, textWidth > 0, duration > 0 else {
            return containerWidth
        }

        let elapsed = date.timeIntervalSince(startDate)
        let progress = elapsed.truncatingRemainder(dividingBy: duration) / duration
        let travelDistance = containerWidth + textWidth

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
