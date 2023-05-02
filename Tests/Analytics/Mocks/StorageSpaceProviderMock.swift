//
//  StorageSpaceProviderMock.swift
//  
//
//  Created by Vyacheslav Beltyukov on 02/05/2023.
//

import Foundation
@testable import PaltaAnalytics

final class StorageSpaceProviderMock: StorageSpaceProvider {
    var result: Double = 0
    var error: Error?
    
    func getStorageUsagePercentage() throws -> Double {
        if let error = error {
            throw error
        } else {
            return result
        }
    }
}
