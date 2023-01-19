//
//  EventComposerMock.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 29/06/2022.
//

import Foundation
import PaltaAnalyticsPrivateModel
@testable import PaltaAnalytics

final class EventComposerMock: EventComposer {
    var shouldFailSerialize = false
    var shouldFailDeserialize = false
    
    var timestamp: Int?
    
    func composeEvent(
        with header: Data?,
        and payload: Data,
        timestamp: Int?
    ) -> BatchEvent {
        self.timestamp = timestamp
        
        // TODO: How simulate errors?
        return BatchEvent()
    }
}
