//
//  NetworkInfoLoggerTests.swift
//  
//
//  Created by Vyacheslav Beltyukov on 02/05/2023.
//

import Foundation
import XCTest
@testable import PaltaAnalytics

final class NetworkInfoLoggerTests: XCTestCase {
    var logger: NetworkInfoLoggerImpl!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        logger = NetworkInfoLoggerImpl()
    }
    
    func testEmpty() {
        XCTAssertNil(logger.getRecentNetworkInfo())
    }
    
    func testLogOnce() {
        var urlRequest = URLRequest(url: URL(string: "https://example.com")!)
        urlRequest.httpBody = Data(count: 5000)
        
        mockedTimestamp = 0
        let trace = logger.newTrace(for: urlRequest)
        
        mockedTimestamp = 1000
        trace.finish(with: Data())
        
        let networkInfo = logger.getRecentNetworkInfo()
        XCTAssertEqual(networkInfo?.speed, 5)
        XCTAssertEqual(networkInfo?.time, 1000)
    }
    
    func testAverage() {
        // Trace 1
        var urlRequest1 = URLRequest(url: URL(string: "https://example.com")!)
        urlRequest1.httpBody = Data(count: 5000)
        mockedTimestamp = 0
        let trace1 = logger.newTrace(for: urlRequest1)
        mockedTimestamp = 1000
        trace1.finish(with: Data())
        
        // Trace 2
        var urlRequest2 = URLRequest(url: URL(string: "https://example.com")!)
        urlRequest2.httpBody = Data(count: 5000)
        mockedTimestamp = 1500
        let trace2 = logger.newTrace(for: urlRequest2)
        mockedTimestamp = 2000
        trace2.finish(with: Data())
        
        // Trace 3
        var urlRequest3 = URLRequest(url: URL(string: "https://example.com")!)
        urlRequest3.httpBody = Data(count: 4000)
        mockedTimestamp = 2500
        let trace3 = logger.newTrace(for: urlRequest3)
        mockedTimestamp = 4000
        trace3.finish(with: Data())
        
        // Trace 4
        var urlRequest4 = URLRequest(url: URL(string: "https://example.com")!)
        urlRequest4.httpBody = Data(count: 10000)
        mockedTimestamp = 5000
        let trace4 = logger.newTrace(for: urlRequest4)
        mockedTimestamp = 8000
        trace4.finish(with: Data())
        
        let networkInfo = logger.getRecentNetworkInfo()
        XCTAssertEqual(networkInfo?.speed, 4)
        XCTAssertEqual(networkInfo?.time, 1500)
    }
    
    func testStatsDropped() {
        // Trace 1
        var urlRequest1 = URLRequest(url: URL(string: "https://example.com")!)
        urlRequest1.httpBody = Data(count: 5000)
        mockedTimestamp = 0
        let trace1 = logger.newTrace(for: urlRequest1)
        mockedTimestamp = 1000
        trace1.finish(with: Data())
        
        // Trace 2
        var urlRequest2 = URLRequest(url: URL(string: "https://example.com")!)
        urlRequest2.httpBody = Data(count: 5000)
        mockedTimestamp = 1500
        let trace2 = logger.newTrace(for: urlRequest2)
        mockedTimestamp = 2000
        trace2.finish(with: Data())
        
        _ = logger.getRecentNetworkInfo()
        
        XCTAssertNil(logger.getRecentNetworkInfo())
    }
}
