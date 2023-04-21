//
//  File.swift
//  
//
//  Created by Vyacheslav Beltyukov on 13/04/2023.
//

import Foundation
import PaltaAnalyticsPrivateModel

final class BatchSendController2 {
    private var isReady = true
    
    private let lock = NSRecursiveLock()
    
    private let batchQueue: BatchQueue
    private let batchStorage: BatchStorage
    private let batchSender: BatchSender
    private let timer: PaltaTimer
    
    init(
        batchQueue: BatchQueue,
        batchStorage: BatchStorage,
        batchSender: BatchSender,
        timer: PaltaTimer
    ) {
        self.batchQueue = batchQueue
        self.batchStorage = batchStorage
        self.batchSender = batchSender
        self.timer = timer
        
        setup()
    }
    
    private func setup() {
        batchQueue.onNewBatch = { [weak self] in
            self?.sendNextBatch()
        }
        
        sendNextBatch()
    }
    
    private func sendNextBatch() {
        lock.lock()
        defer { lock.unlock() }
        
        guard isReady, let batch = batchQueue.popBatch() else {
            return
        }
        
        isReady = false
        send(batch)
    }
    
    private func completeBatchSend(_ batch: Batch) {
        lock.lock()
        
        do {
            try batchStorage.removeBatch(batch)
        } catch {
            print("PaltaLib: Analytics: Failed to remove batch due to error: \(error)")
        }
        
        isReady = true
        sendNextBatch()
        lock.unlock()
    }
    
    private func handle(_ error: BatchSendError, for batch: Batch, retryCount: Int) {
        switch error {
        case .notConfigured:
            print("PaltaLib: Analytics: Batch send failed due to SDK misconfiguration")
            scheduleBatchSend(batch, retryCount: retryCount + 1)
            
        case .serializationError:
            print("PaltaLib: Analytics: Batch send failed due to serialization error")
            completeBatchSend(batch)
            
        case .networkError,.serverError, .noInternet, .timeout:
            scheduleBatchSend(batch, retryCount: retryCount + 1)
            
        case .unknown:
            print("PaltaLib: Analytics: Batch send failed due to unknown error")
            completeBatchSend(batch)
        }
    }
    
    private func send(_ batch: Batch, retryCount: Int = 0) {
        batchSender.sendBatch(batch) { [weak self] result in
            switch result {
            case .success:
                self?.completeBatchSend(batch)
                
            case .failure(let error):
                self?.handle(error, for: batch, retryCount: retryCount)
            }
        }
    }
    
    private func scheduleBatchSend(_ batch: Batch, retryCount: Int) {
        guard retryCount <= 10 else {
            completeBatchSend(batch)
            return
        }
        
        let interval = min(0.25 * pow(2, TimeInterval(retryCount)), 5 * 60)
        
        timer.scheduleTimer(timeInterval: interval, on: .global(qos: .background)) { [weak self] in
            self?.send(batch, retryCount: retryCount)
        }
    }
}

