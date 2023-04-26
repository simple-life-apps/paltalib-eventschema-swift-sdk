//
//  BatchComposerMock.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 29/06/2022.
//

import Foundation
import PaltaAnalyticsPrivateModel
@testable import PaltaAnalytics

final class BatchComposerMock: BatchComposer {
    var events: [BatchEvent]?
    var contextId: UUID?
    var triggerType: TriggerType?
    
    func makeBatch(of events: [BatchEvent], with contextId: UUID, triggerType: TriggerType) -> Batch {
        self.events = events
        self.contextId = contextId
        self.triggerType = triggerType
        
        return Batch()
    }
}
