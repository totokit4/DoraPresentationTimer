//
//  SoundPlayModel.swift
//  DoraPresentationTimer
//
//  Created by totokit4_saki on 2022/11/24.
//

import Foundation
import AVFoundation
import UIKit
var player: AVAudioPlayer?

class SoundPlayModel{
    enum SoundType {
        case clappers1
        case clappers2
        case dora

        var buttonTitle: String {
            switch self {
            case .clappers1:
                return "3分前"
            case .clappers2:
                return "1分前"
            case .dora:
                return "終了"
            }
        }

        var fileName: String {
            switch self {
            case .clappers1:
                return "Clappers1"
            case .clappers2:
                return "Clappers2"
            case .dora:
                return "Dora"
            }
        }
    }

    func playSound(type: SoundType) {
        guard let soundFile = NSDataAsset(name: type.fileName) else { return }
        do {
            player = try AVAudioPlayer(data:soundFile.data, fileTypeHint:"mp3")
            player?.play()
        } catch {
            print("error")
        }
    }
}
