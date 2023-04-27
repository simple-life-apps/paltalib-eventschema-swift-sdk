//
//  Telemetry.swift
//  PaltaAnalytics
//
//  Created by Vyacheslav Beltyukov on 25.04.2022.
//

import Foundation

struct Telemetry: Encodable, Equatable {
    let eventsDroppedSinceLastBatch: Int
    let reportingSpeed: Double
    let storageErrors: [String]
    let serializationErrors: [String]
}
