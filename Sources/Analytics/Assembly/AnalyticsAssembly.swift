//
//  AnalyticsAssembly.swift
//  PaltaAnalytics
//
//  Created by Vyacheslav Beltyukov on 29/06/2022.
//

import Foundation
import PaltaCore
import PaltaAnalyticsModel

final class AnalyticsAssembly {
    let coreAssembly: CoreAssembly
    let analyticsCoreAssembly: AnalyticsCoreAssembly
    let eventQueueAssembly: EventQueueAssembly
    
    init(
        coreAssembly: CoreAssembly,
        analyticsCoreAssembly: AnalyticsCoreAssembly,
        eventQueueAssembly: EventQueueAssembly
    ) {
        self.coreAssembly = coreAssembly
        self.analyticsCoreAssembly = analyticsCoreAssembly
        self.eventQueueAssembly = eventQueueAssembly
    }
}

extension AnalyticsAssembly {
    convenience init(stack: Stack, loggingPolicy: PaltaAnalytics.LoggingPolicy) throws {
        let coreAssembly = CoreAssembly()
        let analyticsCoreAssembly = AnalyticsCoreAssembly(coreAssembly: coreAssembly)
        let eventQueueAssembly = try EventQueueAssembly(
            stack: stack,
            coreAssembly: coreAssembly,
            analyticsCoreAssembly: analyticsCoreAssembly,
            loggingPolicy: loggingPolicy
        )
        
        self.init(
            coreAssembly: coreAssembly,
            analyticsCoreAssembly: analyticsCoreAssembly,
            eventQueueAssembly: eventQueueAssembly
        )
    }
}
