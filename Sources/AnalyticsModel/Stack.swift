//
//  Stack.swift
//  PaltaAnalyticsModel
//
//  Created by Vyacheslav Beltyukov on 27/06/2022.
//

import Foundation

public struct Stack {
    public typealias SessionStartEventPayloadProvider = () -> Data
    
    public let context: BatchContext.Type
    
    public let eventHeader: EventHeader.Type
    public let sessionStartEventPayloadProvider: SessionStartEventPayloadProvider
    
    public init(
        context: BatchContext.Type,
        eventHeader: EventHeader.Type,
        sessionStartEventPayloadProvider: @escaping SessionStartEventPayloadProvider
    ) {
        self.context = context
        self.eventHeader = eventHeader
        self.sessionStartEventPayloadProvider = sessionStartEventPayloadProvider
    }
}
