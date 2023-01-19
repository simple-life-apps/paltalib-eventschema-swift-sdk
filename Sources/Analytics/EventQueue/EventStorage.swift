//
//  EventStorage.swift
//  PaltaAnalytics
//
//  Created by Vyacheslav Beltyukov on 06/06/2022.
//

import Foundation
import PaltaAnalyticsModel

protocol EventStorage {
    func storeEvent(_ event: StorableEvent)
    func removeEvent(with id: UUID)

    func loadEvents(_ completion: @escaping ([StorableEvent]) -> Void)
}
