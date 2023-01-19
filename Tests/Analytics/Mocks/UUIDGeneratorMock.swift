//
//  UUIDGeneratorMock.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 27/06/2022.
//

import Foundation
@testable import PaltaAnalytics

final class UUIDGeneratorMock: UUIDGenerator {
    var uuids: [UUID] = []
    
    func generateUUID() -> UUID {
        uuids.popLast()!
    }
}
