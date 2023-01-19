//
//  StorableEventTests.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 20/06/2022.
//

import Foundation
import XCTest
import PaltaAnalyticsPrivateModel
@testable import PaltaAnalytics

final class StorableEventTests: XCTestCase {
    func testSerializeDeserialize() throws {
        let eventId = UUID()
        let contextId = UUID()
        let eventMock = BatchEvent.mock()
        
        let originalEvent = StorableEvent(
            event: .init(id: eventId, event: eventMock),
            contextId: contextId
        )
        
        let data = try originalEvent.serialize()
        
        let recoveredEvent = try StorableEvent(data: data)
        
        XCTAssertEqual(recoveredEvent.event.id, eventId)
        XCTAssertEqual(recoveredEvent.contextId, contextId)
        XCTAssertEqual(recoveredEvent.event.event, eventMock)
    }
    
    func testCorruptedJSON() {
        let jsonData = "{\"wrong\": \"key\"}".data(using: .utf8)!
        
        XCTAssertThrowsError(try StorableEvent(data: jsonData)) {
            XCTAssert($0 is DecodingError)
        }
    }
    
    func testFailProtobuf() {
        // TODO: How emulate error?
//        let mockEvent = BatchEventMock(shouldFailSerialize: true)
//
//        XCTAssertThrowsError(
//            try StorableEvent(
//                event: .init(id: .init(), event: mockEvent),
//                contextId: .init()
//            ).serialize()
//        )
    }
}
