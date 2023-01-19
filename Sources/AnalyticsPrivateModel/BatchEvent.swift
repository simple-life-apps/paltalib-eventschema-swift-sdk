//
//  BatchEvent.swift
//  PaltaAnalyticsPrivateModel
//
//  Created by Vyacheslav Beltyukov on 13/01/2023.
//

import Foundation

public typealias BatchEvent = Event

public extension BatchEvent {
    var timestamp: Int {
        Int(common.eventTs)
    }

    init(common: EventCommon, header: Data?, payload: Data) {
        self.common = common
        
        if let header = header {
            self.header = header
        }
        
        self.payload = payload
    }
    
    init(data: Data) throws {
        try self.init(serializedData: data)
    }
    
    func serialize() throws -> Data {
        try serializedData()
    }
}

extension BatchEvent: Hashable {
    
}
