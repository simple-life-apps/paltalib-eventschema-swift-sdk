//
//  BatchStorageMock.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 29/06/2022.
//

import Foundation
import PaltaAnalyticsPrivateModel
@testable import PaltaAnalytics

final class BatchStorageMock: BatchStorage {
    var batchToLoad: Batch?
    var batchesToLoad: [Batch] = []
    var batchLoadError: Error?
    var savedBatch: Batch?
    var eventIds: Set<UUID> = []
    var batchRemoved = false
    var batchRemovedId: UUID?
    
    func loadBatch() throws -> Batch? {
        if let batchLoadError = batchLoadError {
            throw batchLoadError
        } else {
            return batchToLoad
        }
    }
    
    func loadBatches() throws -> [Batch] {
        if let batchLoadError = batchLoadError {
            throw batchLoadError
        } else {
            return batchesToLoad
        }
    }
    
    func saveBatch<IDS: Collection>(_ batch: Batch, with eventIds: IDS) throws where IDS.Element == UUID {
        savedBatch = batch
        self.eventIds = Set(eventIds)
    }
    
    func saveBatch(_ batch: Batch) throws {
        savedBatch = batch
    }
    
    func removeBatch() throws {
        batchRemoved = true
    }
    
    func removeBatch(_ batch: Batch) throws {
        batchRemovedId = batch.batchId
    }
}
