//
//  BatchStorage.swift
//  PaltaAnalytics
//
//  Created by Vyacheslav Beltyukov on 06/06/2022.
//

import Foundation
import PaltaAnalyticsPrivateModel

protocol BatchStorage {
    func loadBatch() throws -> Batch?
    func saveBatch<IDS: Collection>(_ batch: Batch, with eventIds: IDS) throws where IDS.Element == UUID
    func removeBatch() throws
}
