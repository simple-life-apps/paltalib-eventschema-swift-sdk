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
            "0037c694a811422a88e2a3c5a90510e3",
            and: URL(string: "https://telemetry.mobilesdk.dev.paltabrain.com")
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
        
        let encoder = JSONEncoder()
        
        let evPropStr = try runs
            .map {
                try String(data: encoder.encode(CodableDictionary($0.eventProperties)), encoding: .utf8)!
            }
            .map { "\"\($0.replacing("\"", with: "\\\""))\"" }
            .joined(separator: " ")
        addAttachment(with: "event-properties", and: evPropStr)
        
        let hPropStr = try runs
            .map {
                try String(data: encoder.encode(CodableDictionary($0.headerProperties)), encoding: .utf8)!
            }
            .map { "\"\($0.replacing("\"", with: "\\\""))\"" }
            .joined(separator: " ")
        addAttachment(with: "header-properties", and: hPropStr)
        
        let cPropStr = try runs
            .map {
                try String(data: encoder.encode(CodableDictionary($0.contextProperties)), encoding: .utf8)!
            }
            .map { "\"\($0.replacing("\"", with: "\\\""))\"" }
            .joined(separator: " ")
        addAttachment(with: "context-properties", and: cPropStr)
    }

    func testAllCases() throws {
        testEdgeCase()
    }
    
    private func testEdgeCase() {
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
    }
    
    private func addAttachment(with name: String, and content: String) {
        let att = XCTAttachment(string: content)
        att.lifetime = .keepAlways
        att.name = name
        add(att)
    }
}
