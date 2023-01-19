//
//  EventComposer.swift
//  PaltaAnalytics
//
//  Created by Vyacheslav Beltyukov on 07/06/2022.
//

import Foundation
import PaltaAnalyticsPrivateModel

protocol EventComposer {
    func composeEvent(
        with header: Data?,
        and payload: Data,
        timestamp: Int?
    ) -> BatchEvent
}

final class EventComposerImpl: EventComposer {
    private let sessionProvider: SessionProvider
    
    init(sessionProvider: SessionProvider) {
        self.sessionProvider = sessionProvider
    }
    
    func composeEvent(
        with header: Data?,
        and payload: Data,
        timestamp: Int?
    ) -> BatchEvent {
        let common = EventCommon(
            timestamp: timestamp ?? currentTimestamp(),
            sessionId: sessionProvider.sessionId,
            sequenceNumber: sessionProvider.nextEventNumber()
        )
        
        return BatchEvent(common: common, header: header, payload: payload)
    }
}
