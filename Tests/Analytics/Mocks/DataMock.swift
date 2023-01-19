//
//  DataMock.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 15/01/2023.
//

import Foundation

extension Data {
    static func mock() -> Data {
        Data((1...20).map { _ in UInt8.random(in: UInt8.min...UInt8.max) })
    }
}
