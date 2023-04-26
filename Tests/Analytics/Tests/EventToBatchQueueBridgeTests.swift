//
//  File.swift
//  
//
//  Created by Vyacheslav Beltyukov on 13/04/2023.
//

import XCTest
@testable import PaltaAnalytics
import PaltaAnalyticsPrivateModel

final class EventToBatchQueueBridgeTests: XCTestCase {
    private var storageMock: BatchStorageMock!
    private var eventQueueMock: EventQueueCoreMock!
    private var batchQueueMock: BatchQueueMock!
    private var batchComposerMock: BatchComposerMock!
    
    private var bridge: EventToBatchQueueBridge!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        storageMock = .init()
        eventQueueMock = .init()
        batchQueueMock = .init()
        batchComposerMock = .init()
        
        reinitBridge()
    }
    
    func testSetupHandlers() {
        XCTAssertNotNil(eventQueueMock.sendHandler)
    }
    
    func testBatchesLoaded() {
        let batch1 = Batch.mock()
        let batch2 = Batch.mock()
        let batch3 = Batch.mock()
        
        storageMock.batchesToLoad = [batch1, batch2, batch3]
        
        reinitBridge()
        
        XCTAssertEqual(
            Set(batchQueueMock.addedBatches),
            [batch1, batch2, batch3]
        )
    }
    
    func testFlush() {
        let events = [
            UUID(): BatchEvent.mock(),
            UUID(): BatchEvent.mock(),
            UUID(): BatchEvent.mock(),
            UUID(): BatchEvent.mock(),
            UUID(): BatchEvent.mock()
        ]
        
        let contextId = UUID()
        
        XCTAssertEqual(eventQueueMock.sendHandler?(events, contextId, .mock(), .context), true)
        
        XCTAssertEqual(batchComposerMock.contextId, contextId)
        XCTAssertEqual(Set(batchComposerMock.events ?? []), Set(events.values))
        
        XCTAssertNotNil(storageMock.savedBatch)
        XCTAssertEqual(Set(storageMock.eventIds), Set(events.keys))
        
        XCTAssertEqual(batchQueueMock.addedBatches.count, 1)
    }
    
    private func reinitBridge() {
        bridge = EventToBatchQueueBridge(
            eventQueue: eventQueueMock,
            batchQueue: batchQueueMock,
            batchComposer: batchComposerMock,
            batchStorage: storageMock
        )
    }
}
