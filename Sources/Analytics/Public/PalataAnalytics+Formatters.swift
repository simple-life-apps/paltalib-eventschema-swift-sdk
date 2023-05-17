//
//  PalataAnalytics+Formatters.swift
//  
//
//  Created by Vyacheslav Beltyukov on 17/05/2023.
//

import Foundation

public extension PaltaAnalytics {
    enum Formatters {
        public static let dateFormatter = DateFormatter().do {
            $0.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        }
        
        public static let decimalFormatter = NSDecimalNumber
    }
}
