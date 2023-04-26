//
//  BatchSendTaskMock.swift
//  
//
//  Created by Vyacheslav Beltyukov on 25/04/2023.
//

import Foundation
import PaltaCore
import PaltaAnalyticsPrivateModel
@testable import PaltaAnalytics

final class BatchSendTaskMock: BatchSendTask {
    var batch: Batch = .mock()
    
    var errorReported: CategorisedNetworkError?
    var timeIntervalToReturn: TimeInterval?
    
    func nextRetryInterval(after error: CategorisedNetworkError) -> TimeInterval? {
        errorReported = error
        return timeIntervalToReturn
    }
}
