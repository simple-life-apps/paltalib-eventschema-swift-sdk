//
//  BatchMock.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 15/06/2022.
//

import Foundation
import PaltaAnalytics
import PaltaAnalyticsPrivateModel

extension Batch {
    static func mock() -> Batch {
        var batch = Batch()
        batch.common.batchID = UUID().uuidString
        return batch
    }
}
