//
//  BatchComposer.swift
//  PaltaAnalytics
//
//  Created by Vyacheslav Beltyukov on 06/06/2022.
//

import Foundation
import PaltaAnalyticsPrivateModel

protocol BatchComposer {
    func makeBatch(of events: [BatchEvent], with contextId: UUID, triggerType: TriggerType, telemetry: Telemetry) throws -> Batch
}

final class BatchComposerImpl: BatchComposer {
    private var lastBatchFormed: Int?
    
    private let numberFormatter = NumberFormatter().do {
        $0.maximumFractionDigits = 2000
        $0.maximumSignificantDigits = 2000
        $0.numberStyle = .decimal
        $0.usesGroupingSeparator = false
    }
    
    private let uuidGenerator: UUIDGenerator
    private let contextProvider: ContextProvider
    private let userInfoProvider: UserPropertiesProvider
    private let deviceInfoProvider: DeviceInfoProvider
    private let networkInfoProvider: NetworkInfoProvider
    
    init(
        uuidGenerator: UUIDGenerator,
        contextProvider: ContextProvider,
        userInfoProvider: UserPropertiesProvider,
        deviceInfoProvider: DeviceInfoProvider,
        networkInfoProvider: NetworkInfoProvider
    ) {
        self.uuidGenerator = uuidGenerator
        self.contextProvider = contextProvider
        self.userInfoProvider = userInfoProvider
        self.deviceInfoProvider = deviceInfoProvider
        self.networkInfoProvider = networkInfoProvider
    }
    
    func makeBatch(of events: [BatchEvent], with contextId: UUID, triggerType: TriggerType, telemetry: Telemetry) throws -> Batch {
        let common = BatchCommon(
            instanceId: userInfoProvider.instanceId,
            batchId: uuidGenerator.generateUUID(),
            countryCode: deviceInfoProvider.country ?? "",
            locale: .current,
            utcOffset: Int64(deviceInfoProvider.timezoneOffsetSeconds)
        )
        
        let sortedEvents = events.sorted(by: { $0.timestamp < $1.timestamp })
        
        var batch = try Batch(
            common: common,
            context: contextProvider.context(with: contextId).serialize(),
            events: sortedEvents
        )
        
        batch.telemetry.triggerType = triggerType.rawValue
        batch.telemetry.storageErrors = telemetry.storageErrors
        batch.telemetry.serializationErrors = telemetry.serializationErrors
        batch.telemetry.eventsDropped = Int64(telemetry.eventsDroppedSinceLastBatch)
        batch.telemetry.eventsReportingSpeed = numberFormatter.string(from: telemetry.reportingSpeed as NSNumber) ?? ""
        
        if let networkInfo = networkInfoProvider.getRecentNetworkInfo() {
            batch.telemetry.prevConnectionSpeed = numberFormatter.string(from: networkInfo.speed as NSNumber) ?? ""
            batch.telemetry.prevRequestTime = Int64(networkInfo.time)
        }
        
        if let lastBatchFormed = lastBatchFormed {
            batch.telemetry.timeSinceLastBatch = Int64(currentTimestamp() - lastBatchFormed)
        }
        
        lastBatchFormed = currentTimestamp()
        
        return batch
    }
}
