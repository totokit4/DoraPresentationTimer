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

    @State private var isAnimating = false
    @State private var textWidth: CGFloat = 0

    var body: some View {
        GeometryReader { geo in
            Text(text)
                .font(.custom("DotGothic16-Regular", size: 30))
                .foregroundStyle(settingsStore.settings.penlightColor.color)
                .shadow(color: .black.opacity(0.3), radius: 2, x: 1, y: 1)
                .lineLimit(1)
                .fixedSize()
                .background {
                    GeometryReader { textGeo in
                        Color.clear
                            .onAppear {
                                textWidth = textGeo.size.width
                            }
                    }
                }
                .offset(x: isAnimating ? -textWidth : geo.size.width)
                .onAppear {
                    restartAnimation()
                }
                .onChange(of: geo.size.width) {
                    restartAnimation()
                }
                .onChange(of: textWidth) {
                    restartAnimation()
                }
                .onDisappear {
                    isAnimating = false
                }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 44)
        .clipped()
        .allowsHitTesting(false)
    }

    private func restartAnimation() {
        isAnimating = false

        DispatchQueue.main.async {
            withAnimation(
                .linear(duration: duration)
                    .repeatForever(autoreverses: false)
            ) {
                isAnimating = true
            }
        }
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
