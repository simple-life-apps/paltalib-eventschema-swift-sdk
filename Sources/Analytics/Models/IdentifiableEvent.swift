//
//  IdentifiableEvent.swift
//  PaltaAnalytics
//
//  Created by Vyacheslav Beltyukov on 20/06/2022.
//

import Foundation
import PaltaAnalyticsPrivateModel

struct IdentifiableEvent {
    let id: UUID
    let event: BatchEvent
}
