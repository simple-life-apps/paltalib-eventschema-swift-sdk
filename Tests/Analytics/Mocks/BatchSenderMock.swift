//
//  BatchSenderMock.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 29/06/2022.
//

import Foundation
import PaltaCore
import PaltaAnalyticsPrivateModel
@testable import PaltaAnalytics

final class BatchSenderMock: BatchSender {
    var batch: Batch?
    var result: Result<(), CategorisedNetworkError>?
    var completion: ((Result<(), CategorisedNetworkError>) -> Void)?
    
    func sendBatch(_ batch: Batch, completion: @escaping (Result<(), CategorisedNetworkError>) -> Void) {
        self.batch = batch
        
        if let result = result {
            completion(result)
        } else {
            self.completion = completion
        }
    }
    
    func feedCompletion(_ result: Result<(), CategorisedNetworkError>) {
        let completion = self.completion
        self.completion = nil
        completion?(result)
    }
}
