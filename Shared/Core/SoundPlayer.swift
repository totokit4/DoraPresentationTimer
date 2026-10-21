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

protocol SoundPlaying {
    func play(_ type: SoundType)
}

protocol FeedbackPerforming {
    func performButtonFeedback()
}

enum SoundType: String, Codable, CaseIterable {
    case clappers1
    case clappers2
    case dora
    case callBell1
    case callBell2
    case callBell3
    
    var fileName: String {
        switch self {
        case .clappers1: return "Clappers1"
        case .clappers2: return "Clappers2"
        case .dora: return "Dora"
        case .callBell1: return "CallBell1"
        case .callBell2: return "CallBell2"
        case .callBell3: return "CallBell3"
        }
    }

    #if os(watchOS)
    var hapticType: WKHapticType {
        switch self {
        case .clappers1, .clappers2, .callBell1, .callBell2:
            return .notification
        case .dora, .callBell3:
            return .stop
        }
    }
    #endif
}

final class SoundPlayer: SoundPlaying {
    private let playback = AudioPlayback()
    
    func play(_ type: SoundType) {
        #if os(watchOS)
        WKInterfaceDevice.current().play(type.hapticType)
        #endif

        guard let url = Bundle.main.url(forResource: type.fileName, withExtension: "mp3") else {
            return
        }

        Task {
            await playback.play(url)
        }
    }
}

// Keep player access and implicit audio session activation off the main actor.
private actor AudioPlayback {
    private var player: AVAudioPlayer?

    func play(_ url: URL) {
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
