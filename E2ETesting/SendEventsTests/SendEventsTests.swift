//
//  SendEventsTests.swift
//  SendEventsTests
//
//  Created by Vyacheslav Beltyukov on 10/08/2023.
//

import XCTest
import PaltaCore
import PaltaEvents
import PaltaAnalytics

final class SendEventsTests: XCTestCase {
    struct Run {
        let time: Date
        let name: String
        let eventProperties: [String: Any]
        let headerProperties: [String: Any]
        let contextProperties: [String: Any]
    }
    
    private var runs: [Run] = []
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        PaltaAnalytics.shared.setAPIKey(
            "704c3db5ab2d45ef90c8eeb45d9c8cff",
            and: URL(string: "https://telemetry.mobilesdk.paltabrain.com")
        )
    }
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        
        let timesStr = runs
            .map { "\(Int($0.time.timeIntervalSince1970.rounded()))" }
            .joined(separator: " ")
        addAttachment(with: "times", and: timesStr)
        
        let namesStr = runs
            .map { $0.name }
            .joined(separator: " ")
        addAttachment(with: "names", and: namesStr)
        
        try addJSONAttachment(with: "event-properties") {
            $0.eventProperties
        }
        
        try addJSONAttachment(with: "header-properties") {
            $0.headerProperties
        }
        
        try addJSONAttachment(with: "context-properties") {
            $0.contextProperties
        }
    }

    func testAllCases() throws {
        edgeCase()
    }
    
    private func edgeCase() {
        let event = EdgeCaseEvent(
            propBoolean: true,
            propEnum: .skip,
            propInteger: 349,
            propString: "String for E2E testing"
        )
        
        let time = Date()
        
        PaltaAnalytics.shared.log(event)
        
        runs.append(
            Run(
                time: time,
                name: "EdgeCase",
                eventProperties: [
                    "prop_boolean": true,
                    "prop_enum": "RESULT_SKIP",
                    "prop_integer": 349,
                    "prop_string": "String for E2E testing"
                ],
                headerProperties: [:],
                contextProperties: [:]
            )
        )
        
        waitForFlush()
    }
    
    private func waitForFlush() {
        let expectation = self.expectation(description: "Wait for flush \(UUID())")
        expectation.isInverted = true
        wait(for: [expectation], timeout: 35)
    }
    
    private func addJSONAttachment(with name: String, _ contentExtractor: (Run) -> [String: Any]) throws {
        let encoder = JSONEncoder()
        let string = try runs
            .map {
                try String(data: encoder.encode(CodableDictionary(contentExtractor($0))), encoding: .utf8)!
            }
            .map { "\"\($0.replacing("\"", with: "\\\""))\"" }
            .joined(separator: " ")
        addAttachment(with: name, and: string)
    }
    
    private func addAttachment(with name: String, and content: String) {
        let att = XCTAttachment(string: content)
        att.lifetime = .keepAlways
        att.name = name
        add(att)
    }
}
