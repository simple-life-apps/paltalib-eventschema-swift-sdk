//
//  BatchSendControllerTests.swift
//  
//
//  Created by Vyacheslav Beltyukov on 13/04/2023.
//

import Foundation
import XCTest
import PaltaAnalyticsPrivateModel
@testable import PaltaAnalytics

final class BatchSendControllerTests: XCTestCase {
    private var queueMock: BatchQueueMock!
    private var storageMock: BatchStorageMock!
    private var senderMock: BatchSenderMock!
    private var timerMock: TimerMock!
    private var taskMock: BatchSendTaskMock!
    
    private var controller: BatchSendController!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        queueMock = .init()
        storageMock = .init()
        senderMock = .init()
        timerMock = .init()
        taskMock = .init()
        
        reinit()
    }
    
    func testSuccessfulSend() {
        controller.configurationFinished()
        
        let batch: Batch = .mock()
        taskMock.batch = batch
        queueMock.batchesToPop = [batch]
        senderMock.result = .success(())
        
        queueMock.onNewBatch?()
        
        XCTAssertEqual(senderMock.batch, batch)
        XCTAssertEqual(storageMock.batchRemovedId, batch.batchId)
    }
    
    func testSequentalSend() {
        controller.configurationFinished()
        
        let batch1: Batch = .mock()
        taskMock.batch = batch1
        queueMock.batchesToPop = [batch1]
        senderMock.result = .success(())
        
        queueMock.onNewBatch?()
        
        XCTAssertEqual(senderMock.batch, batch1)
        XCTAssertEqual(storageMock.batchRemovedId, batch1.batchId)
        
        let batch2: Batch = .mock()
        taskMock.batch = batch2
        queueMock.batchesToPop = [batch2]
        senderMock.result = .success(())
        
        queueMock.onNewBatch?()
        
        XCTAssertEqual(senderMock.batch, batch2)
        XCTAssertEqual(storageMock.batchRemovedId, batch2.batchId)
    }
    
    func testNonRetriableError() {
        controller.configurationFinished()
        
        let batch: Batch = .mock()
        taskMock.batch = batch
        queueMock.batchesToPop = [.mock(), batch]
        
        taskMock.batch = batch
        taskMock.timeIntervalToReturn = nil
        
        queueMock.onNewBatch?()
        
        senderMock.feedCompletion( .failure(.unknown))
        
        XCTAssertEqual(taskMock.errorReported, .unknown)
        XCTAssertNotNil(storageMock.batchRemovedId)
        XCTAssertEqual(storageMock.batchRemovedId, batch.batchId)
        XCTAssert(queueMock.batchesToPop.isEmpty)
    }
    
    func testRetry() {
        controller.configurationFinished()
        
        let batch: Batch = .mock()
        queueMock.batchesToPop = [.mock(), batch]
        
        taskMock.batch = batch
        taskMock.timeIntervalToReturn = 5.78
        
        queueMock.onNewBatch?()
        
        senderMock.feedCompletion( .failure(.unknown))
        
        XCTAssertEqual(taskMock.errorReported, .unknown)
        XCTAssertEqual(timerMock.passedInterval, 5.78)
        
        senderMock.batch = nil
        timerMock.fireAndWait()
        XCTAssertEqual(senderMock.batch, batch)
    }
    
    func testSendOldBatch() {
        let batch: Batch = .mock()
        taskMock.batch = batch
        queueMock.batchesToPop = [batch]
        senderMock.result = .success(())
        
        reinit()
        controller.configurationFinished()
        
        XCTAssertEqual(senderMock.batch, batch)
        XCTAssertEqual(storageMock.batchRemovedId, batch.batchId)
    }
    
    func testNoSendUnconfigured() {
        let batch: Batch = .mock()
        taskMock.batch = batch
        queueMock.batchesToPop = [batch]
        senderMock.result = .success(())
        
        queueMock.onNewBatch?()
        
        XCTAssertNil(senderMock.batch)
        XCTAssertNil(storageMock.batchRemovedId)
    }
    
    private func reinit() {
        controller = BatchSendController(
            batchQueue: queueMock,
            batchStorage: storageMock,
            batchSender: senderMock,
            timer: timerMock,
            taskProvider: { [taskMock] _ in return taskMock! }
        )
    }
}
