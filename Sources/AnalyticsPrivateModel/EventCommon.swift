//
//  EventCommon.swift
//  PaltaAnalyticsPrivateModel
//
//  Created by Vyacheslav Beltyukov on 13/01/2023.
//

import Foundation

public extension EventCommon {
    init(timestamp: Int, sessionId: Int, sequenceNumber: Int) {
        self.eventTs = Int64(timestamp)
        self.sessionID = Int64(sessionId)
        self.sessionEventSeqNum = Int64(sequenceNumber)
    }
}
