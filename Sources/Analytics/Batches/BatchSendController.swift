//
//  BatchSendController.swift
//  
//
//  Created by Vyacheslav Beltyukov on 13/04/2023.
//

import Foundation
import PaltaCore
import PaltaAnalyticsPrivateModel

final class BatchSendController {
    typealias BatchSendTaskProvider = (Batch) -> BatchSendTask
    
    private var isReady = false
    
    private let lock = NSRecursiveLock()
    
    private let batchQueue: BatchQueue
    private let batchStorage: BatchStorage
    private let batchSender: BatchSender
    private let timer: PaltaTimer
    
    private let taskProvider: BatchSendTaskProvider
    
    init(
        batchQueue: BatchQueue,
        batchStorage: BatchStorage,
        batchSender: BatchSender,
        timer: PaltaTimer,
        taskProvider: @escaping BatchSendTaskProvider
    ) {
        self.batchQueue = batchQueue
        self.batchStorage = batchStorage
        self.batchSender = batchSender
        self.timer = timer
        self.taskProvider = taskProvider
        
        setup()
    }
    
    func configurationFinished() {
        isReady = true
        sendNextBatch()
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
        send(taskProvider(batch))
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
    
    private func handle(_ error: CategorisedNetworkError, for task: BatchSendTask) {
        switch error {
        case .notConfigured:
            print("PaltaLib: Analytics: Batch send failed due to SDK misconfiguration")
            
        case .badRequest:
            print("PaltaLib: Analytics: Batch send failed due to serialization error")
            
        case .unknown:
            print("PaltaLib: Analytics: Batch send failed due to unknown error")
            
        default:
            // Expected error, do not log
            break
        }
        
        guard let interval = task.nextRetryInterval(after: error) else {
            completeBatchSend(task.batch)
            return
        }
        
        timer.scheduleTimer(timeInterval: interval, on: .global(qos: .background)) { [weak self] in
            self?.send(task)
        }
    }
    
    private func send(_ task: BatchSendTask) {
        batchSender.sendBatch(task.batch) { [weak self] result in
            switch result {
            case .success:
                self?.completeBatchSend(task.batch)
                
            case .failure(let error):
                self?.handle(error, for: task)
            }
        }
    }
}

