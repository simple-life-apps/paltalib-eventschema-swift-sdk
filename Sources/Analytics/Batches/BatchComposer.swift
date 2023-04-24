//
//  BatchComposer.swift
//  PaltaAnalytics
//
//  Created by Vyacheslav Beltyukov on 06/06/2022.
//

import Foundation
import PaltaAnalyticsPrivateModel

protocol BatchComposer {
    func makeBatch(of events: [BatchEvent], with contextId: UUID) throws -> Batch
}

final class BatchComposerImpl: BatchComposer {
    private let uuidGenerator: UUIDGenerator
    private let contextProvider: ContextProvider
    private let userInfoProvider: UserPropertiesProvider
    private let deviceInfoProvider: DeviceInfoProvider
    
    init(
        uuidGenerator: UUIDGenerator,
        contextProvider: ContextProvider,
        userInfoProvider: UserPropertiesProvider,
        deviceInfoProvider: DeviceInfoProvider
    ) {
        self.uuidGenerator = uuidGenerator
        self.contextProvider = contextProvider
        self.userInfoProvider = userInfoProvider
        self.deviceInfoProvider = deviceInfoProvider
    }
    
    func makeBatch(of events: [BatchEvent], with contextId: UUID) throws -> Batch {
        let common = BatchCommon(
            instanceId: userInfoProvider.instanceId,
            batchId: uuidGenerator.generateUUID(),
            countryCode: deviceInfoProvider.country ?? "",
            locale: .current,
            utcOffset: Int64(deviceInfoProvider.timezoneOffsetSeconds)
        )
        
        let sortedEvents = events.sorted(by: { $0.timestamp < $1.timestamp })
        
        let batch = try Batch(
            common: common,
            context: contextProvider.context(with: contextId).serialize(),
            events: sortedEvents
        )
        
        return batch
    }
}
