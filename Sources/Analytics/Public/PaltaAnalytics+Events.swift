//
//  PaltaAnalytics2+Events.swift
//  PaltaAnalytics
//
//  Created by Vyacheslav Beltyukov on 30/06/2022.
//

import Foundation
import PaltaAnalyticsModel

public extension PaltaAnalytics {
    func log<E: Event>(_ event: E) {
        assembly?.eventQueueAssembly.eventQueue.logEvent(event)
    }
}
