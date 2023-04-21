//
//  BatchSenderMock.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 29/06/2022.
//

import Foundation
import PaltaAnalyticsPrivateModel
@testable import PaltaAnalytics

final class BatchSenderMock: BatchSender {
    var batch: Batch?
    var result: Result<(), BatchSendError>?
    var completion: ((Result<(), BatchSendError>) -> Void)?
    
    func sendBatch(_ batch: Batch, completion: @escaping (Result<(), BatchSendError>) -> Void) {
        self.batch = batch
        
        if let result = result {
            completion(result)
        } else {
            self.completion = completion
        }
    }
    
    func feedCompletion(_ result: Result<(), BatchSendError>) {
        let completion = self.completion
        self.completion = nil
        completion?(result)
    }
}
