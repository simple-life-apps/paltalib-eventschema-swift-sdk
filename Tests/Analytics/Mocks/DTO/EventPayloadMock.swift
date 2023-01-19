//
//  EventPayloadMock.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 28/06/2022.
//

import Foundation
import PaltaAnalytics
import PaltaAnalyticsModel

struct EventPayloadMock: SessionStartEventPayload, Equatable {
    let data: Data = .mock()
    
    func serialized() throws -> Data {
        data
    }
}
