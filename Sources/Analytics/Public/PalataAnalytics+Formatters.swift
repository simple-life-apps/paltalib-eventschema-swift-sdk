//
//  PalataAnalytics+Formatters.swift
//  
//
//  Created by Vyacheslav Beltyukov on 17/05/2023.
//

import Foundation

public extension PaltaAnalytics {
    enum Formatters {
        public static let timestampFormatter = TimestampFormatter()
        
        public static let decimalFormatter = NumberFormatter().do {
            $0.decimalSeparator = "."
            $0.maximumSignificantDigits = 10
            $0.maximumFractionDigits = 10
            $0.generatesDecimalNumbers = true
        }
    }
    
    final class TimestampFormatter {
        private let df = Foundation.DateFormatter().do {
            $0.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
            $0.timeZone = TimeZone(secondsFromGMT: 0)
        }
        
        public func string(from timestamp: Int64) -> String {
            let date = Date(timeIntervalSince1970: Double(timestamp) / 1000)
            return df.string(from: date)
        }
    }
}
