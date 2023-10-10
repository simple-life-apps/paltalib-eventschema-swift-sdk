//
//  ProxyLogger.swift
//  
//
//  Created by Vyacheslav Beltyukov on 27/09/2023.
//

import Foundation

final class ProxyLogger: PaltaAnalyticsLogger {
    var realLogger: PaltaAnalyticsLogger?
    
    func log(_ message: PaltaAnalytics.LogMessage) {
        realLogger?.log(message)
    }
}
