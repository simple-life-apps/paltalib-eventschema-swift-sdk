//
//  UserPropertiesKeeperMock.swift
//  PaltaAnalytics
//
//  Created by Vyacheslav Beltyukov on 08.04.2022.
//

import Foundation
@testable import PaltaAnalytics

final class UserPropertiesKeeperMock: UserPropertiesKeeper {
    var userId: String?
    var deviceId: String?
    var instanceId: UUID = UUID()
}
