//
//  SoundPlayer.swift
//  DoraPresentationTimer
//
//  Created by saki iwamoto on 2026/01/22.
//

import AVFoundation
#if os(iOS)
import UIKit
#elseif os(watchOS)
import WatchKit
#endif

@MainActor
protocol SoundPlaying {
    func play(_ type: SoundType)
}

@MainActor
protocol FeedbackPerforming {
    func performButtonFeedback()
}

enum SoundType: String, Codable, CaseIterable {
    case clappers1
    case clappers2
    case dora
    
    var fileName: String {
        switch self {
        case .clappers1: return "Clappers1"
        case .clappers2: return "Clappers2"
        case .dora: return "Dora"
        }
    }

    #if os(watchOS)
    var hapticType: WKHapticType {
        switch self {
        case .clappers1, .clappers2:
            return .notification
        case .dora:
            return .stop
        }
    }
    #endif
}

final class SoundPlayer: SoundPlaying {
    private var player: AVAudioPlayer?
    
    func play(_ type: SoundType) {
        #if os(watchOS)
        WKInterfaceDevice.current().play(type.hapticType)
        #endif

        guard let url = Bundle.main.url(forResource: type.fileName, withExtension: "mp3") else {
            return
        }

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()

            guard player?.play() == true else {
                return
            }
        } catch {
            #if !os(watchOS)
            print("error")
            #endif
        }
    }
}

final class FeedbackPerformer: FeedbackPerforming {
    func performButtonFeedback() {
        #if os(iOS)
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
        #elseif os(watchOS)
        WKInterfaceDevice.current().play(.click)
        #endif
    }
}
