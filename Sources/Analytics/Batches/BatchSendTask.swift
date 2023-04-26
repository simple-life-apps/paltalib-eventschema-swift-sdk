//
//  BatchSendTask.swift
//  
//
//  Created by Vyacheslav Beltyukov on 25/04/2023.
//

import Foundation
import PaltaCore
import PaltaAnalyticsPrivateModel

protocol BatchSendTask: AnyObject {
    var batch: Batch { get }
    
    func nextRetryInterval(after error: CategorisedNetworkError) -> TimeInterval?
}

final class BatchSendTaskImpl: BatchSendTask {
    let batch: Batch
    
    private var errors: [CategorisedNetworkError] = []
    
    init(batch: Batch, errors: [CategorisedNetworkError] = []) {
        self.batch = batch
        self.errors = errors
    }
    
    func nextRetryInterval(after error: CategorisedNetworkError) -> TimeInterval? {
        errors.append(error)
        
        if case .unauthorised = error {
            return nil
        }
        
        return min(
            pow(2, Double(errors.count)) * 0.1 + .random(in: 0...0.1),
            300
        )
    }
}
