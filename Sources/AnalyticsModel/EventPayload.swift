//
//  EventPayload.swift
//  PaltaAnalyticsModel
//
//  Created by Vyacheslav Beltyukov on 06/06/2022.
//

import Foundation

public protocol EventPayload {
    func serialized() throws -> Data
}

public protocol SessionStartEventPayload: EventPayload {
    init()
}
