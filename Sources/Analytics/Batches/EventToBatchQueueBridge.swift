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
    
    init(
        eventQueue: EventQueue,
        batchQueue: BatchQueue,
        batchComposer: BatchComposer,
        batchStorage: BatchStorage
    ) {
        self.eventQueue = eventQueue
        self.batchQueue = batchQueue
        self.batchComposer = batchComposer
        self.batchStorage = batchStorage
        
        setup()
    }
    
    private func setup() {
        eventQueue.sendHandler = { [weak self] events, contextId, _ in
            self?.onFlush(events: events, contextId: contextId)
            return true
        }
        
        loadBatches()
    }
    
    private func loadBatches() {
        do {
            let batches = try batchStorage.loadBatches()
            batches.forEach(batchQueue.addBatch)
        } catch {
            print("PaltaLib: Analytics: Error loading batches: \(error)")
        }
    }
    
    private func onFlush(events: [UUID: BatchEvent], contextId: UUID) {
        do {
            let batch = try batchComposer.makeBatch(of: Array(events.values), with: contextId)
            try batchStorage.saveBatch(batch, with: events.keys)
            batchQueue.addBatch(batch)
        } catch {
            print("PaltaLib: Analytics: Error saving batch: \(error)")
        }
    }
}
