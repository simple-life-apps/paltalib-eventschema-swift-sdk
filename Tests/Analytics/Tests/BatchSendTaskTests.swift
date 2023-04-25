//
//  BatchSendTaskTests.swift
//  
//
//  Created by Vyacheslav Beltyukov on 25/04/2023.
//

import Foundation
import XCTest
import PaltaCore
@testable import PaltaAnalytics

final class BatchSendTaskTests: XCTestCase {
    func testNoRetryOnUnauthorized() {
        let task = BatchSendTaskImpl(batch: .mock())
        
        XCTAssertNil(task.nextRetryInterval(after: .unauthorised(403)))
        XCTAssertNil(task.nextRetryInterval(after: .unauthorised(401)))
    }
    
    func testNoRetryOnUnauthorizedAfterOtherError() {
        let task = BatchSendTaskImpl(batch: .mock())
        
        _ = task.nextRetryInterval(after: .notConfigured)
        _ = task.nextRetryInterval(after: .noInternet)
        XCTAssertNil(task.nextRetryInterval(after: .unauthorised(401)))
    }
    
    func testRetryOnOtherErrors() {
        let task = BatchSendTaskImpl(batch: .mock())
        
        XCTAssertNotNil(task.nextRetryInterval(after: .noInternet))
        XCTAssertNotNil(task.nextRetryInterval(after: .timeout))
        XCTAssertNotNil(task.nextRetryInterval(after: .dnsError(.dnsLookupFailed)))
        XCTAssertNotNil(task.nextRetryInterval(after: .sslError(.clientCertificateRejected)))
        XCTAssertNotNil(task.nextRetryInterval(after: .requiresHttps))
        XCTAssertNotNil(task.nextRetryInterval(after: .cantConnectToHost))
        XCTAssertNotNil(task.nextRetryInterval(after: .otherNetworkError(.unknown)))
        XCTAssertNotNil(task.nextRetryInterval(after: .decodingError))
        XCTAssertNotNil(task.nextRetryInterval(after: .notConfigured))
        XCTAssertNotNil(task.nextRetryInterval(after: .badResponse))
        XCTAssertNotNil(task.nextRetryInterval(after: .badRequest))
        XCTAssertNotNil(task.nextRetryInterval(after: .serverError(500)))
        XCTAssertNotNil(task.nextRetryInterval(after: .clientError(418)))
        XCTAssertNotNil(task.nextRetryInterval(after: .unknown))
    }
    
    func testExpanentialBackoff() {
        let task = BatchSendTaskImpl(batch: .mock())
        
        XCTAssertEqual(task.nextRetryInterval(after: .badResponse) ?? -1, 0.2, accuracy: 0.11)
        XCTAssertEqual(task.nextRetryInterval(after: .badResponse) ?? -1, 0.4, accuracy: 0.11)
        XCTAssertEqual(task.nextRetryInterval(after: .badResponse) ?? -1, 0.8, accuracy: 0.11)
        XCTAssertEqual(task.nextRetryInterval(after: .badResponse) ?? -1, 1.6, accuracy: 0.11)
        XCTAssertEqual(task.nextRetryInterval(after: .badResponse) ?? -1, 3.2, accuracy: 0.11)
        XCTAssertEqual(task.nextRetryInterval(after: .badResponse) ?? -1, 6.4, accuracy: 0.11)
        XCTAssertEqual(task.nextRetryInterval(after: .badResponse) ?? -1, 12.8, accuracy: 0.11)
    }
    
    func testMaxRetryInterval() {
        let task = BatchSendTaskImpl(batch: .mock())
        
        for _ in 0...1000 {
            _ = task.nextRetryInterval(after: .badResponse)
        }
        
        XCTAssertEqual(task.nextRetryInterval(after: .badResponse) ?? -1, 300, accuracy: 0.11)
    }
}
