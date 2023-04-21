//
//  BatchSendController2Tests.swift
//  
//
//  Created by Vyacheslav Beltyukov on 13/04/2023.
//

import Foundation
import XCTest
import PaltaAnalyticsPrivateModel
@testable import PaltaAnalytics

final class BatchSendController2Tests: XCTestCase {
    private var queueMock: BatchQueueMock!
    private var storageMock: BatchStorageMock!
    private var senderMock: BatchSenderMock!
    private var timerMock: TimerMock!
    
    private var controller: BatchSendController2!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        queueMock = .init()
        storageMock = .init()
        senderMock = .init()
        timerMock = .init()
        
        reinit()
    }
    
    func testSuccessfulSend() {
        let batch: Batch = .mock()
        queueMock.batchesToPop = [batch]
        senderMock.result = .success(())
        
        queueMock.onNewBatch?()
        
        XCTAssertEqual(senderMock.batch, batch)
        XCTAssertEqual(storageMock.batchRemovedId, batch.batchId)
    }
    
    func testSequentalSend() {
        let batch1: Batch = .mock()
        queueMock.batchesToPop = [batch1]
        senderMock.result = .success(())
        
        queueMock.onNewBatch?()
        
        XCTAssertEqual(senderMock.batch, batch1)
        XCTAssertEqual(storageMock.batchRemovedId, batch1.batchId)
        
        let batch2: Batch = .mock()
        queueMock.batchesToPop = [batch2]
        senderMock.result = .success(())
        
        queueMock.onNewBatch?()
        
        XCTAssertEqual(senderMock.batch, batch2)
        XCTAssertEqual(storageMock.batchRemovedId, batch2.batchId)
    }
    
    func testUnknownError() {
        let batch: Batch = .mock()
        queueMock.batchesToPop = [.mock(), batch]
        
        queueMock.onNewBatch?()
        
        senderMock.feedCompletion( .failure(.unknown))
        senderMock.feedCompletion(.success(()))
        
        XCTAssertNotNil(storageMock.batchRemovedId)
        XCTAssertNotEqual(storageMock.batchRemovedId, batch.batchId)
        XCTAssert(queueMock.batchesToPop.isEmpty)
    }
    
    func testServerError() {
        let batch: Batch = .mock()
        queueMock.batchesToPop = [.mock(), batch]
        
        senderMock.result = .failure(.serverError)
        
        queueMock.onNewBatch?()

        XCTAssertNil(storageMock.batchRemovedId)
        XCTAssertFalse(queueMock.batchesToPop.isEmpty)
        
        storageMock.batchRemovedId = nil
        
        senderMock.result = .success(())
        timerMock.fireAndWait()

        XCTAssertNotNil(storageMock.batchRemovedId)
    }
    
    func testNoInternet() {
        let batch: Batch = .mock()
        queueMock.batchesToPop = [.mock(), batch]
        
        senderMock.result = .failure(.noInternet)
        
        queueMock.onNewBatch?()

        XCTAssertNil(storageMock.batchRemovedId)
        XCTAssertFalse(queueMock.batchesToPop.isEmpty)
        
        storageMock.batchRemovedId = nil
        
        senderMock.result = .success(())
        timerMock.fireAndWait()

        XCTAssertNotNil(storageMock.batchRemovedId)
    }
    
    func testTimeoutError() {
        let batch: Batch = .mock()
        queueMock.batchesToPop = [.mock(), batch]
        
        senderMock.result = .failure(.timeout)
        
        queueMock.onNewBatch?()

        XCTAssertNil(storageMock.batchRemovedId)
        XCTAssertFalse(queueMock.batchesToPop.isEmpty)
        
        storageMock.batchRemovedId = nil
        
        senderMock.result = .success(())
        timerMock.fireAndWait()

        XCTAssertNotNil(storageMock.batchRemovedId)
    }
    
    func testURLError() {
        let batch: Batch = .mock()
        queueMock.batchesToPop = [batch]
        
        queueMock.onNewBatch?()
        
        senderMock.feedCompletion(.failure(.networkError(URLError(.backgroundSessionRequiresSharedContainer, userInfo: [:]))))
        
        XCTAssertNotNil(timerMock.passedInterval)
        
        timerMock.fireAndWait()
        
        senderMock.feedCompletion(.success(()))

        XCTAssertEqual(storageMock.batchRemovedId, batch.batchId)
        XCTAssert(queueMock.batchesToPop.isEmpty)
    }
    
    func testNotConfiguredError() {
        let batch: Batch = .mock()
        queueMock.batchesToPop = [.mock(), batch]
        
        senderMock.result = .failure(.notConfigured)
        
        queueMock.onNewBatch?()

        XCTAssertNil(storageMock.batchRemovedId)
        XCTAssertFalse(queueMock.batchesToPop.isEmpty)
        
        storageMock.batchRemovedId = nil
        
        senderMock.result = .success(())
        timerMock.fireAndWait()

        XCTAssertNotNil(storageMock.batchRemovedId)
    }
    
    func testMaxRetry() {
        let batch: Batch = .mock()
        queueMock.batchesToPop = [.mock(), batch]
        
        senderMock.result = .failure(.notConfigured)
        
        var retryCount = 0
        
        senderMock.result = .failure(.notConfigured)
        
        queueMock.onNewBatch?()
        
        repeat {
            timerMock.passedInterval = nil
            timerMock.fireAndWait()
            retryCount += 1
            
            if retryCount > 10 {
                XCTAssert(false)
            }
        } while timerMock.passedInterval != nil
        
        XCTAssertEqual(retryCount, 10)
        
        XCTAssertNotNil(storageMock.batchRemovedId)
    }
    
    func testSendOldBatch() {
        let batch: Batch = .mock()
        queueMock.batchesToPop = [batch]
        senderMock.result = .success(())
        
        reinit()
        
        XCTAssertEqual(senderMock.batch, batch)
        XCTAssertEqual(storageMock.batchRemovedId, batch.batchId)
    }
    
    private func reinit() {
        controller = BatchSendController2(
            batchQueue: queueMock,
            batchStorage: storageMock,
            batchSender: senderMock,
            timer: timerMock
        )
    }
}
