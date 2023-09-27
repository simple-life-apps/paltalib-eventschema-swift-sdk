//
//  PaltaAnalytics+Logging.swift
//  
//
//  Created by Vyacheslav Beltyukov on 27/09/2023.
//

import Foundation

extension PaltaAnalytics {
    /// Tells Palta SDK what and how to output to the log.
    public enum LoggingPolicy {
        /// Write all messages to std out with default logger
        case all
        /// Write nothing
        case none
        /// Write selected messages to std out with default logger
        case selectedTypes(Set<MessageType>)
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
    public enum MessageType: CaseIterable {
        /// A message is logged due to error occured
        case error
        /// A message is logged to warn developer
        case warning
        /// A message is logged when regular lifecycle event occures, for example initializtion is complete or batch is sent.
        case lifecycle
        /// A message is logged when new event is reported to the SDK.
        case event
        /// A message is logged when context was changed
        case contextChange
    }
}

public protocol PaltaAnalyticsLogger {
    func log(_ type: PaltaAnalytics.MessageType, _ message: String)
}

extension PaltaAnalytics {
    public final class DefaultLogger: PaltaAnalyticsLogger {
        public let messageTypes: Set<MessageType>
        
        public init(messageTypes: Set<MessageType>) {
            self.messageTypes = messageTypes
        }
        
        public func log(_ type: PaltaAnalytics.MessageType, _ message: String) {
            guard messageTypes.contains(type) else {
                return
            }
            
            let prefix: String
            
            switch type {
            case .error:
                prefix = "🚨🚨🚨 Palta Analytics error: "
            case .warning:
                prefix = "⚠️ Palta Analytics warning: "
            case .lifecycle:
                prefix = "PaltaAnalytics: "
            case .event:
                prefix = "⬆️⬆️⬆️ New analytics event was reported:\n\n"
            case .contextChange:
                prefix = "🔄🔄🔄 Analytics context was updated:\n\n"
            }
            
            print(prefix + message)
        }
    }
}

typealias Logger = PaltaAnalyticsLogger
typealias DefaultLogger = PaltaAnalytics.DefaultLogger

extension Set where Element == PaltaAnalytics.MessageType {
    static let all = Set(PaltaAnalytics.MessageType.allCases)
}
