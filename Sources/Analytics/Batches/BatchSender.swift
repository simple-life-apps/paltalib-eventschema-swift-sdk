//
//  BatchSender.swift
//  PaltaAnalytics
//
//  Created by Vyacheslav Beltyukov on 02/06/2022.
//

import Foundation
import CoreData
import PaltaCore
import PaltaAnalyticsPrivateModel

protocol BatchSender {
    func sendBatch(_ batch: Batch, errorCodes: [Int], completion: @escaping (Result<(), CategorisedNetworkError>) -> Void)
}

final class BatchSenderImpl: BatchSender {
    var apiToken: String? {
        didSet {
            httpClient.mandatoryHeaders["X-API-Key"] = apiToken ?? ""
        }
    }
    
    var baseURL: URL?
    
    private let httpClient: HTTPClient
    private let networkInfoLogger: NetworkInfoLogger
    
    init(httpClient: HTTPClient, networkInfoLogger: NetworkInfoLogger) {
        self.httpClient = httpClient
        self.networkInfoLogger = networkInfoLogger
    }
    
    func sendBatch(_ batch: Batch, errorCodes: [Int], completion: @escaping (Result<(), CategorisedNetworkError>) -> Void) {
        let data: Data
        
        do {
            data = try batch.serialize()
        } catch {
            completion(.failure(.badRequest))
            return
        }
        
        let request = BatchSendRequest(
            host: baseURL,
            time: currentTimestamp(),
            errorCodes: errorCodes,
            data: data
        )
        
        let errorHandler = ErrorHandler(completion: completion)
        var trace: NetworkTrace?
        
        httpClient.perform(
            request,
            requestMiddleware: { [networkInfoLogger] in trace = networkInfoLogger.newTrace(for: $0) },
            responseMiddleware: { _, data in trace?.finish(with: data) }
        ) { (result: Result<EmptyResponse, NetworkErrorWithoutResponse>) in
            switch result {
            case .success:
                completion(.success(()))
                
            case .failure(let error):
                errorHandler.handle(error)
            }
        }
    }
}

private struct ErrorHandler {
    let completion: (Result<Void, CategorisedNetworkError>) -> Void
    
    func handle(_ error: NetworkErrorWithoutResponse) {
        completion(.failure(CategorisedNetworkError(error)))
    }
}
