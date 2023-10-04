//
//  PaltaAnalytics+Logging.swift
//  
//
//  Created by Vyacheslav Beltyukov on 27/09/2023.
//

import Foundation
import os

extension PaltaAnalytics {
    /// Tells Palta SDK what and how to output to the log.
    public enum LoggingPolicy {
        /// Write all messages to std out with default logger
        case all
        /// Write nothing
        case none
        /// Write selected messages to std out with default logger
        case selectedTypes(LogMessageType)
        /// Use your own custom logger
        case custom(PaltaAnalyticsLogger)
    }
    
    public static var loggingPolicy: LoggingPolicy {
        get {
            _loggingPolicy
        }
        set {
            _loggingPolicy = newValue
            _shared?.assembly?.eventQueueAssembly.update(with: _loggingPolicy)
        }
    }

    static var _loggingPolicy: LoggingPolicy = .all
}

extension PaltaAnalytics {
    /// Determines an origin of log message, for example event sent or error occured.
    public struct LogMessageType: OptionSet {
        public typealias RawValue = Int
        
        /// A message is logged due to error occured
        public static let error = LogMessageType(rawValue: 1)
        /// A message is logged to warn developer
        public static let warning = LogMessageType(rawValue: 1 << 1)
        /// A message is logged when regular lifecycle event occures, for example initializtion is complete or batch is sent.
        public static let lifecycle = LogMessageType(rawValue: 1 << 2)
        /// A message is logged when new event is reported to the SDK.
        public static let event = LogMessageType(rawValue: 1 << 3)
        /// A message is logged when context was changed
        public static let contextChange = LogMessageType(rawValue: 1 << 4)
        
        public static let all: LogMessageType = [.error, .warning, .lifecycle, .event, .contextChange]
        public static let excludingUsage: LogMessageType = [.error, .warning, .lifecycle,]
        
        public let rawValue: RawValue
        
        public init(rawValue: RawValue) {
            self.rawValue = rawValue
        }
    }
}

public protocol PaltaAnalyticsLogger {
    func log(_ type: PaltaAnalytics.LogMessageType, _ message: String)
}

extension PaltaAnalytics {
    public final class DefaultLogger: PaltaAnalyticsLogger {
        public let messageTypes: LogMessageType
        
        public init(messageTypes: LogMessageType) {
            self.messageTypes = messageTypes
        }
        
        public func log(_ type: PaltaAnalytics.LogMessageType, _ message: String) {
            guard messageTypes.contains(type) else {
                return
            }
            
            let prefix: String
            let logLevel: os.OSLogType
            
            switch type {
            case .error:
                prefix = "🚨🚨🚨 Palta Analytics error: "
                logLevel = .error
            case .warning:
                prefix = "⚠️ Palta Analytics warning: "
                logLevel = .default
            case .lifecycle:
                prefix = "PaltaAnalytics: "
                logLevel = .default
            case .event:
                prefix = "⬆️⬆️⬆️ New analytics event was reported:\n\n"
                logLevel = .info
            case .contextChange:
                prefix = "🔄🔄🔄 Analytics context was updated:\n\n"
                logLevel = .info
            default:
                assertionFailure()
                return
            }
            
            let finalMessage = prefix + message
            print(finalMessage)
            os_log(logLevel, "%@", finalMessage as NSString)
        }
    }
}

typealias Logger = PaltaAnalyticsLogger
typealias DefaultLogger = PaltaAnalytics.DefaultLogger
