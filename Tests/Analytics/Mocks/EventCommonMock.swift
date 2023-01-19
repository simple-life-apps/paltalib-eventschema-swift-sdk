//
//  EventCommonMock.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 03/09/2022.
//

import Foundation
import PaltaAnalyticsPrivateModel

extension EventCommon {
    static func mock(timestamp: Int) -> EventCommon {
        EventCommon(
            timestamp: timestamp,
            sessionId: .random(in: 0...Int.max),
            sequenceNumber: .random(in: 0...Int.max)
        )
    }
}
