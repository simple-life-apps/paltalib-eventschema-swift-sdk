//
//  BatchComposerTests.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 27/06/2022.
//

import Foundation
import XCTest
import PaltaAnalyticsPrivateModel
@testable import PaltaAnalytics

final class BatchComposerTests: XCTestCase {
    private var uuidGenerator: UUIDGeneratorMock!
    private var contextProvider: ContextProviderMock!
    private var userInfoProvider: UserPropertiesKeeperMock!
    private var deviceInfoProvider: DeviceInfoProviderMock!
    
    private var composer: BatchComposerImpl!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        uuidGenerator = .init()
        contextProvider = .init()
        userInfoProvider = .init()
        deviceInfoProvider = .init()
        
        composer = BatchComposerImpl(
            uuidGenerator: uuidGenerator,
            contextProvider: contextProvider,
            userInfoProvider: userInfoProvider,
            deviceInfoProvider: deviceInfoProvider
        )
    }
    
    func testComposeBatch() throws {
        let events = [BatchEvent.mock(timestamp: 1), BatchEvent.mock(timestamp: 5)]
        let batchId = UUID()
        let contextId = UUID()
        let context = try BatchContextMock(
            data: Data(repeating: .random(in: 0...120), count: .random(in: 20...30))
        )
        
        contextProvider.context = context
        deviceInfoProvider.country = "GB"
        deviceInfoProvider.timezoneOffsetSeconds = 898
        uuidGenerator.uuids = [batchId]
        
        let batch = try composer.makeBatch(of: events, with: contextId, triggerType: .minimise)
        
        XCTAssertEqual(batch.context, try context.serialize())
        XCTAssertEqual(batch.events, events)
        XCTAssertEqual(batch.common.instanceID, userInfoProvider.instanceId.uuidString)
        XCTAssertEqual(batch.common.countryCode, "GB")
        XCTAssertEqual(batch.common.utcOffset, 898)
        XCTAssertEqual(batch.common.batchID, batchId.uuidString)
    }
    
    func testEventsSorted() throws {
        let events = [
            BatchEvent(timestamp: 7),
            BatchEvent(timestamp: 2),
            BatchEvent(timestamp: 55),
            BatchEvent(timestamp: 34)
        ]
        
        let contextId = UUID()
        let context = try BatchContextMock(
            data: Data(repeating: .random(in: 0...120), count: .random(in: 20...30))
        )
        
        contextProvider.context = context
        uuidGenerator.uuids = [UUID()]
        
        let batch = try composer.makeBatch(of: events, with: contextId, triggerType: .count)
        
        XCTAssertEqual(
            batch.events.map { $0.timestamp },
            [2, 7, 34, 55]
        )
    }
    
    func testTriggerTypes() throws {
        uuidGenerator.uuids = Array(repeating: .init(), count: 100)
        contextProvider.context = BatchContextMock()

        try XCTAssertEqual(
            composer.makeBatch(of: [], with: UUID(), triggerType: .count).telemetry.triggerType,
            "count"
        )
        
        try XCTAssertEqual(
            composer.makeBatch(of: [], with: UUID(), triggerType: .timer).telemetry.triggerType,
            "timer"
        )
        
        try XCTAssertEqual(
            composer.makeBatch(of: [], with: UUID(), triggerType: .context).telemetry.triggerType,
            "context"
        )
        
        try XCTAssertEqual(
            composer.makeBatch(of: [], with: UUID(), triggerType: .minimise).telemetry.triggerType,
            "minimise"
        )
    }
}
