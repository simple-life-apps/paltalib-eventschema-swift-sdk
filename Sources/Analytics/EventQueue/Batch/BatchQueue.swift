//
//  BatchQueue.swift
//  
//
//  Created by Vyacheslav Beltyukov on 10/04/2023.
//

import Foundation
import PaltaAnalyticsPrivateModel

protocol BatchQueue {
    var isEmpty: Bool { get }
    var onNewBatch: (() -> Void)? { get set }
    
    func addBatch(_ batch: Batch)
    func popBatch() -> Batch?
}

final class BatchQueueImpl: BatchQueue {
    var isEmpty: Bool {
        queue.isEmpty
    }
    
    var onNewBatch: (() -> Void)?
    
    private var queue: [Batch] = []
    private let lock = NSRecursiveLock()
    
    func addBatch(_ batch: Batch) {
        lock.lock()
        let index = queue.firstIndex(where: { $0.maxTimestamp > batch.maxTimestamp }) ?? queue.count
        
        queue.insert(
            batch,
            at: index
        )
        
        onNewBatch?()
        lock.unlock()
    }
    
    func popBatch() -> Batch? {
        lock.lock()
        defer { lock.unlock() }
        
        return queue.isEmpty ? nil : queue.removeFirst()
    }
}
