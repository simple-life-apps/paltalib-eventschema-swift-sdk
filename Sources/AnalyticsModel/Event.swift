//
//  Event.swift
//  PaltaAnalyticsModel
//
//  Created by Vyacheslav Beltyukov on 06/06/2022.
//

import Foundation

public protocol Event {
    associatedtype Header: EventHeader
    associatedtype Payload: EventPayload
    
    var header: Header? { get }
    var payload: Payload { get }
    
    func asJSON() -> [String: Any]
}
