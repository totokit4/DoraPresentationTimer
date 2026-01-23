//
//  TimerEngine.swift
//  DoraPresentationTimer
//
//  Created by saki iwamoto on 2026/01/23.
//

import Combine
import Foundation

protocol TimerTicking {
    /// イベントが流れてくるPublisher
    var tick: AnyPublisher<Void, Never> { get }
}

struct TimerEngine: TimerTicking {
    let tick: AnyPublisher<Void, Never>

    init(interval: TimeInterval = 1.0) {
        // Timer.publishはConnectablePublisher（connectメソッドを呼ばれて初めてイベントを発生させる）
        self.tick = Timer.publish(every: interval, on: .main, in: .common)
            .autoconnect() // 普通のpublisherのような振る舞いをさせる
            .map { _ in () }
            .eraseToAnyPublisher()
    }
}
