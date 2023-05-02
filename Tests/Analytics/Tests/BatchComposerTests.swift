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
    private var networkInfoProvider: NetworkInfoProviderMock!
    
    private var composer: BatchComposerImpl!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        uuidGenerator = .init()
        contextProvider = .init()
        userInfoProvider = .init()
        deviceInfoProvider = .init()
        networkInfoProvider = .init()
        
        composer = BatchComposerImpl(
            uuidGenerator: uuidGenerator,
            contextProvider: contextProvider,
            userInfoProvider: userInfoProvider,
            deviceInfoProvider: deviceInfoProvider,
            networkInfoProvider: networkInfoProvider
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
        
        let batch = try composer.makeBatch(of: events, with: contextId, triggerType: .minimise, telemetry: .mock())
        
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
        
        let batch = try composer.makeBatch(of: events, with: contextId, triggerType: .count, telemetry: .mock())
        
        XCTAssertEqual(
            batch.events.map { $0.timestamp },
            [2, 7, 34, 55]
        )
    }
    
    func testTriggerTypes() throws {
        uuidGenerator.uuids = Array(repeating: .init(), count: 100)
        contextProvider.context = BatchContextMock()

        try XCTAssertEqual(
            composer.makeBatch(of: [], with: UUID(), triggerType: .count, telemetry: .mock()).telemetry.triggerType,
            "count"
        )
        
        try XCTAssertEqual(
            composer.makeBatch(of: [], with: UUID(), triggerType: .timer, telemetry: .mock()).telemetry.triggerType,
            "timer"
        )
        
        try XCTAssertEqual(
            composer.makeBatch(of: [], with: UUID(), triggerType: .context, telemetry: .mock()).telemetry.triggerType,
            "context"
        )
        
        try XCTAssertEqual(
            composer.makeBatch(of: [], with: UUID(), triggerType: .minimise, telemetry: .mock()).telemetry.triggerType,
            "minimise"
        )
    }
    
    func testTelemetryPassed() throws {
        uuidGenerator.uuids = Array(repeating: .init(), count: 100)
        contextProvider.context = BatchContextMock()
        
        let storeErrors = [UUID().uuidString, UUID().uuidString, String(Array(repeating: "C", count: 100_000))]
        let serErrors = [UUID().uuidString, UUID().uuidString, String(Array(repeating: "C", count: 100_000))]
        
        let telemetry = Telemetry(
            eventsDroppedSinceLastBatch: 558,
            reportingSpeed: 0.0000000000000000000098,
            storageErrors: storeErrors,
            serializationErrors: serErrors
        )
        
        let batch = try composer.makeBatch(of: [], with: UUID(), triggerType: .count, telemetry: telemetry)
        
        XCTAssertEqual(batch.telemetry.storageErrors, storeErrors)
        XCTAssertEqual(batch.telemetry.serializationErrors, serErrors)
        XCTAssertEqual(batch.telemetry.eventsDropped, 558)
        XCTAssertEqual(batch.telemetry.eventsReportingSpeed, "0.0000000000000000000098")
    }
    
    func testNetworkInfoPresent() throws {
        uuidGenerator.uuids = Array(repeating: .init(), count: 100)
        contextProvider.context = BatchContextMock()
        networkInfoProvider.result = NetworkInfo(time: 1088, speed: 120400000000000000.6)
        
        let batch = try composer.makeBatch(of: [], with: UUID(), triggerType: .count, telemetry: .mock())
        
        XCTAssertEqual(batch.telemetry.prevRequestTime, 1088)
        XCTAssertEqual(batch.telemetry.prevConnectionSpeed, "120400000000000000")
    }
    
    func testNetworkInfoMissing() throws {
        uuidGenerator.uuids = Array(repeating: .init(), count: 100)
        contextProvider.context = BatchContextMock()
        
        let batch = try composer.makeBatch(of: [], with: UUID(), triggerType: .count, telemetry: .mock())
        
        XCTAssertFalse(batch.telemetry.hasPrevRequestTime)
        XCTAssertFalse(batch.telemetry.hasPrevConnectionSpeed)
    }
}
