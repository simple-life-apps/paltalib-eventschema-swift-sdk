//
//  BatchSenderTests.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 15/06/2022.
//

import Foundation
import XCTest
import PaltaCore
import PaltaAnalyticsPrivateModel
@testable import PaltaAnalytics

final class BatchSenderTests: XCTestCase {
    private var httpMock: HTTPClientMock!
    private var networkInfoLoggerMock: NetworkInfoLoggerMock!
    
    private var sender: BatchSenderImpl!
    
    private let apiToken = "MOCK_API_TOKEN"
    private let url = URL(string: "fake://url.com")
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        mockedTimestamp = 25
        
        httpMock = .init()
        networkInfoLoggerMock = .init()
        
        sender = BatchSenderImpl(httpClient: httpMock, networkInfoLogger: networkInfoLoggerMock)
        
        sender.apiToken = apiToken
        sender.baseURL = url
    }
    
    func testTokenPassed() {
        XCTAssertEqual(httpMock.mandatoryHeaders, ["X-API-Key": apiToken])
    }
    
    func testSuccess() {
        let successCalled = expectation(description: "Success called")
        let batch = Batch()
        
        httpMock.result = .success(EmptyResponse())
        
        sender.sendBatch(batch, errorCodes: [505, 707]) { result in
            guard case .success = result else {
                return
            }
            
            successCalled.fulfill()
        }
        
        let request = httpMock.request as? BatchSendRequest
        
        XCTAssertNotNil(request)
        XCTAssertEqual(request?.time, 25)
        XCTAssertEqual(request?.host, url)
        XCTAssertEqual(request?.errorCodes, [505, 707])
        XCTAssertEqual(request?.data, try batch.serialize())
        
        wait(for: [successCalled], timeout: 0.1)
    }
    
    func testFailNoInternet() {
        let failCalled = expectation(description: "Fail called")
        let batch = Batch()
        
        httpMock.result = .failure(NetworkErrorWithoutResponse.urlError(URLError(.notConnectedToInternet)))
        
        sender.sendBatch(batch, errorCodes: []) { result in
            guard case .failure(let error) = result, case .noInternet = error else {
                return
            }
            
            failCalled.fulfill()
        }
        
        wait(for: [failCalled], timeout: 0.1)
    }
    
    func testFailTimeout() {
        let failCalled = expectation(description: "Fail called")
        let batch = Batch()
        
        httpMock.result = .failure(NetworkErrorWithoutResponse.urlError(URLError(.timedOut)))
        
        sender.sendBatch(batch, errorCodes: []) { result in
            guard case .failure(let error) = result, case .timeout = error else {
                return
            }
            
            failCalled.fulfill()
        }
        
        wait(for: [failCalled], timeout: 0.1)
    }
    
    func testFailServerError() {
        let failCalled = expectation(description: "Fail called")
        let batch = Batch()
        
        httpMock.result = .failure(NetworkErrorWithoutResponse.invalidStatusCode(502, nil))
        
        sender.sendBatch(batch, errorCodes: []) { result in
            guard case .failure(let error) = result, case .serverError = error else {
                return
            }
            
            failCalled.fulfill()
        }
        
        wait(for: [failCalled], timeout: 0.1)
    }
    
    func testFailClientError() {
        let failCalled = expectation(description: "Fail called")
        let batch = Batch()
        
        httpMock.result = .failure(NetworkErrorWithoutResponse.invalidStatusCode(418, nil))
        
        sender.sendBatch(batch, errorCodes: []) { result in
            guard case .failure(let error) = result, case .clientError(418) = error else {
                return
            }
            
            failCalled.fulfill()
        }
        
        wait(for: [failCalled], timeout: 0.1)
    }
    
    func testFailOtherError() {
        let failCalled = expectation(description: "Fail called")
        let batch = Batch()
        
        httpMock.result = .failure(NetworkErrorWithoutResponse.other(NSError(domain: "", code: 0)))
        
        sender.sendBatch(batch, errorCodes: []) { result in
            guard case .failure(let error) = result, case .unknown = error else {
                return
            }
            
            failCalled.fulfill()
        }
        
        wait(for: [failCalled], timeout: 0.1)
    }
    
    func testNetworkMeasured() {
        let successCalled = expectation(description: "Success called")
        let batch = Batch()
        let urlRequest = URLRequest(url: URL(string: "https://mock.mock")!)
        let data = Data((0...10).map { _ in UInt8.random(in: 0...200) })
        
        httpMock.urlRequest = urlRequest
        httpMock.response = (nil, data)
        httpMock.result = .success(EmptyResponse())
        
        sender.sendBatch(batch, errorCodes: []) { result in
            guard case .success = result else {
                return
            }
            
            successCalled.fulfill()
        }
        
        wait(for: [successCalled], timeout: 0.1)
        
        XCTAssert(networkInfoLoggerMock.trace.stopped)
        XCTAssertEqual(networkInfoLoggerMock.request, urlRequest)
        XCTAssertEqual(networkInfoLoggerMock.trace.data, data)
    }
}
