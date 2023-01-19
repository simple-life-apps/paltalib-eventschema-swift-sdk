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
        .init(eventsInBatch: 55, batchLoad: 0.8, eventsDroppedSinceLastBatch: 78)
    }
}
