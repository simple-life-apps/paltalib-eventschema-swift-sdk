//
//  BatchQueueTests.swift
//  
//
//  Created by Vyacheslav Beltyukov on 13/04/2023.
//

import XCTest
@testable import PaltaAnalytics
import PaltaAnalyticsPrivateModel

final class BatchQueueTests: XCTestCase {
    private var queue: BatchQueueImpl!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        queue = BatchQueueImpl()
    }
    
    func testAddPop() {
        var batch1 = Batch()
        batch1.common.batchID = UUID().uuidString
        
        var batch2 = Batch()
        batch2.common.batchID = UUID().uuidString
        
        queue.addBatch(batch1)
        queue.addBatch(batch2)
        
        XCTAssertEqual(queue.popBatch(), batch1)
        XCTAssertEqual(queue.popBatch(), batch2)
        XCTAssertNil(queue.popBatch())
    }
    
    func testIsEmptyTrue() {
        XCTAssert(queue.isEmpty)
    }
    
    func testIsEmptyFalse() {
        queue.addBatch(Batch())
        
        XCTAssertFalse(queue.isEmpty)
    }
    
    func testNotifyOnNewElement() {
        let notifyCalled = expectation(description: "Notify called")
        notifyCalled.expectedFulfillmentCount = 2
        queue.onNewBatch = notifyCalled.fulfill
        
        queue.addBatch(Batch())
        queue.addBatch(Batch())
        
        waitForExpectations(timeout: 0.1)
    }
    
    func testConcurrentInsertRead() {
        queue.addBatch(Batch())
        queue.addBatch(Batch())
        queue.addBatch(Batch())
        
        let readIterations: Set<Int> = [2, 4, 8]
        
        DispatchQueue.concurrentPerform(iterations: 10) { index in
            if readIterations.contains(index) {
                _ = queue.popBatch()
            } else {
                queue.addBatch(Batch())
            }
        }
        
        var batchesCount = 0
        while queue.popBatch() != nil {
            batchesCount += 1
        }
        
        XCTAssertEqual(batchesCount, 7)
    }
    
    func testAccessQueueOnNotify() {
        queue.onNewBatch = { [weak queue] in
            _ = queue?.popBatch()
        }
        
        queue.addBatch(Batch())
        
        XCTAssert(queue.isEmpty)
    }
}
