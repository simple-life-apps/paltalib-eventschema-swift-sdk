//
//  StackMock.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 24/06/2022.
//

import Foundation
import PaltaAnalytics
import PaltaAnalyticsModel

extension Stack {
    static let mock = Stack(
        context: BatchContextMock.self,
        eventHeader: EventHeaderMock.self,
        sessionStartEventPayloadProvider: { Data() }
    )
}
