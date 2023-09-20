//
//  EventMock.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 15/07/2022.
//

import Foundation
import PaltaAnalyticsModel

final class EventMock: Event {
    
    typealias Header = EventHeaderMock
    typealias Payload = EventPayloadMock
    typealias EventType = Int
    
    var name: String {
        "Mock"
    }
    
    var header: EventHeaderMock? {
        EventHeaderMock()
    }
    
    var payload: EventPayloadMock {
        EventPayloadMock()
    }
    
    var type: Int {
        0
    }
    
    func asJSON() -> [String : Any] {
        [:]
    }
    
    func asJSON(withContext: Bool) -> [String : Any] {
        [:]
    }
}
