//
//  EventToBatchQueueBridge.swift
//  
//
//  Created by Vyacheslav Beltyukov on 13/04/2023.
//

import Foundation
import PaltaAnalyticsPrivateModel

final class EventToBatchQueueBridge {
    private let eventQueue: EventQueue
    private let batchQueue: BatchQueue
    private let batchComposer: BatchComposer
    private let batchStorage: BatchStorage
    private let logger: Logger
    
    init(
        eventQueue: EventQueue,
        batchQueue: BatchQueue,
        batchComposer: BatchComposer,
        batchStorage: BatchStorage,
        logger: Logger
    ) {
        self.eventQueue = eventQueue
        self.batchQueue = batchQueue
        self.batchComposer = batchComposer
        self.batchStorage = batchStorage
        self.logger = logger
        
        setup()
    }
    
    private func setup() {
        eventQueue.sendHandler = { [weak self] events, contextId, telemetry, triggerType in
            self?.onFlush(events: events, contextId: contextId, triggerType: triggerType, telemetry: telemetry)
            return true
        }
        
        loadBatches()
    }
    
    private func loadBatches() {
        do {
            let batches = try batchStorage.loadBatches()
            batches.forEach(batchQueue.addBatch)
        } catch {
            logger.log(.error, "Error loading batches: \(error)")
        }
    }
    
    private func onFlush(events: [UUID: BatchEvent], contextId: UUID, triggerType: TriggerType, telemetry: Telemetry) {
        do {
            let batch = try batchComposer.makeBatch(
                of: Array(events.values),
                with: contextId,
                triggerType: triggerType,
                telemetry: telemetry
            )
            
            try batchStorage.saveBatch(batch, with: events.keys)
            batchQueue.addBatch(batch)
        } catch {
            logger.log(.error, "Error saving batch: \(error)")
        }
    }
}
