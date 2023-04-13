//
//  BatchQueueMock.swift
//  
//
//  Created by Vyacheslav Beltyukov on 13/04/2023.
//

@testable import PaltaAnalytics
import PaltaAnalyticsPrivateModel

final class BatchQueueMock: BatchQueue {
    var addedBatches: [PaltaAnalyticsPrivateModel.Batch] = []
    var batchesToPop: [PaltaAnalyticsPrivateModel.Batch] = []
    
    var isEmpty: Bool = false
    
    var onNewBatch: (() -> Void)?
    
    func addBatch(_ batch: PaltaAnalyticsPrivateModel.Batch) {
        addedBatches.append(batch)
    }
    
    func popBatch() -> PaltaAnalyticsPrivateModel.Batch? {
        batchesToPop.popLast()
    }
}
