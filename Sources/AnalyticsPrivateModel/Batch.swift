//
//  Batch.swift
//  PaltaAnalyticsPrivateModel
//
//  Created by Vyacheslav Beltyukov on 13/01/2023.
//

import Foundation

public extension Batch {
    var batchId: UUID {
        guard let batchId = UUID(uuidString: common.batchID) else {
            assertionFailure()
            return UUID(uuid: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0))
        }
        
        return batchId
    }
    
    init(common: BatchCommon, context: Data, events: [Event]) {
        self.common = common
        self.context = context
        self.events = events
    }
    
    init(data: Data) throws {
        try self.init(serializedData: data)
    }
    
    func serialize() throws -> Data {
        try serializedData()
    }
}
