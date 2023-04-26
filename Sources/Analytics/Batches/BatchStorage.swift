//
//  BatchStorage.swift
//  PaltaAnalytics
//
//  Created by Vyacheslav Beltyukov on 06/06/2022.
//

import Foundation
import PaltaAnalyticsPrivateModel

protocol BatchStorage {
    func loadBatches() throws -> [Batch]
    func saveBatch<IDS: Collection>(_ batch: Batch, with eventIds: IDS) throws where IDS.Element == UUID
    func removeBatch(_ batch: Batch) throws
    
    func addErrorCode(_ errorCode: Int, for batch: Batch) throws
    func getErrorCodes(for batch: Batch) throws -> [Int]
}
