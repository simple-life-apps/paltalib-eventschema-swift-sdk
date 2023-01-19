//
//  BatchCommon.swift
//  PaltaAnalyticsPrivateModel
//
//  Created by Vyacheslav Beltyukov on 13/01/2023.
//

import Foundation

public extension BatchCommon {
    init(
        instanceId: UUID,
        batchId: UUID,
        countryCode: String,
        locale: Locale,
        utcOffset: Int64
    ) {
        self.instanceID = instanceId.uuidString
        self.batchID = batchId.uuidString
        self.countryCode = countryCode
        self.locale = locale.identifier
        self.utcOffset = utcOffset
    }
}
