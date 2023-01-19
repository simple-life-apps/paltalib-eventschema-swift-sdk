//
//  EventComposerTests.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 28/06/2022.
//

import Foundation
import XCTest
@testable import PaltaAnalytics

final class EventComposerTests: XCTestCase {
    private var sessionIdProvider: SessionManagerMock!
    private var composer: EventComposerImpl!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        sessionIdProvider = .init()
        composer = EventComposerImpl(sessionProvider: sessionIdProvider)
    }
    
    func testComposeEvent() {
        mockedTimestamp = 999
        sessionIdProvider.sessionId = 888
        
        let header: Data = .mock()
        let payload: Data = .mock()
        
        let event = composer.composeEvent(
            with: header,
            and: payload,
            timestamp: nil
        )
        
        XCTAssertEqual(event.common.eventTs, 999)
        XCTAssertEqual(event.common.sessionID, 888)
        XCTAssertEqual(event.header, header)
        XCTAssertEqual(event.payload, payload)
    }
    
    func testComposeEventWithTimestamp() {
        mockedTimestamp = 999
        sessionIdProvider.sessionId = 888
        
        let header: Data = .mock()
        let payload: Data = .mock()
        
        let event = composer.composeEvent(
            with: header,
            and: payload,
            timestamp: 105
        )
        
        XCTAssertEqual(event.common.eventTs, 105)
        XCTAssertEqual(event.common.sessionID, 888)
        XCTAssertEqual(event.header, header)
        XCTAssertEqual(event.payload, payload)
    }
    
    func testHeaderNil() {
        mockedTimestamp = 999
        sessionIdProvider.sessionId = 888
        
        let payload: Data = .mock()
        
        let event = composer.composeEvent(
            with: nil,
            and: payload,
            timestamp: 105
        )
        
        XCTAssertEqual(event.common.eventTs, 105)
        XCTAssertEqual(event.common.sessionID, 888)
        XCTAssertEqual(event.header, Data())
        XCTAssertEqual(event.payload, payload)
    }
}
