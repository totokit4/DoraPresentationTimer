//
//  SoundTestView.swift
//  DoraPresentationTimer
//
//  Created by saki iwamoto on 2026/01/31.
//

import SwiftUI

/// サウンドテスト画面
struct SoundTestView: View {
    private let soundPlayer = SoundPlayer()
    
    var body: some View {
        VStack(spacing: 24) {
            soundButton(.clappers1)
            soundButton(.clappers2)
            soundButton(.dora)
        }
        .padding()
        .navigationTitle("Sound Test")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func soundButton(_ type: SoundType) -> some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            soundPlayer.play(type)
        } label: {
            Text(type.buttonTitle)
                .font(.title2)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
        }
        .background(Color.brown)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
