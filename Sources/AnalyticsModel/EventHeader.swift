//
//  EventHeader.swift
//  PaltaAnalyticsModel
//
//  Created by Vyacheslav Beltyukov on 06/06/2022.
//

import Foundation

public protocol EventHeader {
    init()
    
    func serialized() throws -> Data
}
