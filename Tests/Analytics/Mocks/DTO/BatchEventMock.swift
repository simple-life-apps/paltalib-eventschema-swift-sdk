//
//  BatchEventMock.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 16/06/2022.
//

import Foundation
import PaltaAnalytics
import PaltaAnalyticsModel
import PaltaAnalyticsPrivateModel

extension BatchEvent {
    static func mock(timestamp: Int? = nil) -> BatchEvent {
        var event = BatchEvent(timestamp: timestamp ?? .random(in: 0...1_000_000_000))
        event.payload = .mock()
        return event
    }
    
    init(timestamp: Int) {
        self.init()
        
        self.common.eventTs = Int64(timestamp)
    }
}
