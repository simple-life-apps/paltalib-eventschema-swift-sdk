//
//  PaltaAnalytics+Logging.swift
//  
//
//  Created by Vyacheslav Beltyukov on 27/09/2023.
//

import Foundation
import os
import PaltaAnalyticsModel

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

extension PaltaAnalytics {
    public enum LogMessage {
        case error(Error, String)
        case warning(String)
        case lifecycle(String)
        case event(any Event)
        case contextChange(any BatchContext)
        
        var type: LogMessageType {
            switch self {
            case .error:
                return .error
            case .warning:
                return .warning
            case .lifecycle:
                return .lifecycle
            case .event:
                return .event
            case .contextChange:
                return .contextChange
            }
        }
    }
}

public protocol PaltaAnalyticsLogger {
    func log(_ message: PaltaAnalytics.LogMessage)
}

extension PaltaAnalytics {
    public final class DefaultLogger: PaltaAnalyticsLogger {
        public let messageTypes: LogMessageType
        
        private let log = OSLog(subsystem: "PaltaAnalytics", category: "Analytics")
        
        public init(messageTypes: LogMessageType) {
            self.messageTypes = messageTypes
        }
        
        public func log(_ message: PaltaAnalytics.LogMessage) {
            guard messageTypes.contains(message.type) else {
                return
            }
            
            let finalMessage: String
            let logLevel: os.OSLogType
            
            switch message {
            case let .error(_, errorMessage):
                finalMessage = "🚨🚨🚨 Palta Analytics error: \(errorMessage)"
                logLevel = .error
            case let .warning(warning):
                finalMessage = "⚠️ Palta Analytics warning: \(warning)"
                logLevel = .default
            case let .lifecycle(message):
                finalMessage = "PaltaAnalytics: \(message)"
                logLevel = .default
            case let .event(event):
                finalMessage = "⬆️⬆️⬆️ New event! Event name: \(event.name). Properties: \(event.asJSON())"
                logLevel = .info
            case let .contextChange(context):
                finalMessage = "🔄🔄🔄 Analytics context was updated. New context: \(context.asJSON())"
                logLevel = .info
            }
            
            print(finalMessage)
            os_log(logLevel, log: log, "%{public}@", finalMessage as NSString)
        }
    }
}

typealias Logger = PaltaAnalyticsLogger
typealias DefaultLogger = PaltaAnalytics.DefaultLogger
