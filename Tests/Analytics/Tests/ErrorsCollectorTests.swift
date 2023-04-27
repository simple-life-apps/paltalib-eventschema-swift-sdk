//
//  File.swift
//  
//
//  Created by Vyacheslav Beltyukov on 27/04/2023.
//

import Foundation
import XCTest
@testable import PaltaAnalytics

final class ErrorsCollectorTests: XCTestCase {
    private var lock: NSLock!
    private var collector: ErrorsCollectorImpl!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        lock = NSLock()
        collector = ErrorsCollectorImpl(lock: lock)
    }
    
    func testAddAndCollect() {
        let message1 = UUID().uuidString
        let message2 = UUID().uuidString
        
        collector.logError(message1)
        collector.logError(message2)
        
        XCTAssertEqual(collector.getErrors(), [message1, message2])
    }
    
    func testMaxMessageLength() {
        let string = String((1...8000).map { _ in Character(.init(UInt8.random(in: 0...255))) })
        let longString = string + string
        
        collector.logError(longString)
        XCTAssertEqual(collector.getErrors(), [string])
    }
    
    func testMaxMessagesCount() {
        for _ in 1...100 {
            collector.logError(UUID().uuidString)
        }
        
        XCTAssertEqual(collector.getErrors().count, 50)
    }
    
    func testMaxLength() {
        let string = String((1...5500).map { _ in Character(.init(UInt8.random(in: 0...255))) })
        
        
        for _ in 1...50 {
            collector.logError(string)
        }
        
        XCTAssertEqual(collector.getErrors().joined().count, 50_000)
    }
    
    func testLocking() {
        let getCompleted = expectation(description: "Get completed")
        let getNotCompleted = expectation(description: "Get not completed")
        getNotCompleted.isInverted = true
        
        lock.lock()
        
        DispatchQueue.global().async { [collector] in
            _ = collector?.getErrors()
            
            getCompleted.fulfill()
            getNotCompleted.fulfill()
        }
        
        wait(for: [getNotCompleted], timeout: 0.5)
        
        lock.unlock()
        
        wait(for: [getCompleted], timeout: 0.5)
    }
}
