//
//  SoundPlayer.swift
//  DoraPresentationTimer
//
//  Created by saki iwamoto on 2026/01/22.
//

import AVFoundation
import UIKit

protocol SoundPlaying {
    func play(_ type: SoundType)
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
}

final class SoundPlayer: SoundPlaying {
    private var player: AVAudioPlayer?
    
    func play(_ type: SoundType) {
        guard let asset = NSDataAsset(name: type.fileName) else { return }
        do {
            player = try AVAudioPlayer(data: asset.data, fileTypeHint: "mp3")
            player?.play()
        } catch {
            print("error")
        }
    }
}

