//
//  TelemetryMock.swift
//  PaltaAnalytics
//
//  Created by Vyacheslav Beltyukov on 25.04.2022.
//

import Foundation
@testable import PaltaAnalytics

extension Telemetry {
    static func mock() -> Telemetry {
        .init(eventsDroppedSinceLastBatch: 55, reportingSpeed: 0.2, storageErrors: [], serializationErrors: [])
    }
    
    static func randomMock() -> Telemetry {
        .init(
            eventsDroppedSinceLastBatch: .random(in: 0...2000),
            reportingSpeed: .random(in: 0...1000),
            storageErrors: [UUID().uuidString],
            serializationErrors: [UUID().uuidString]
        )
    }
}
