//
//  EventQueueAssembly.swift
//  PaltaAnalytics
//
//  Created by Vyacheslav Beltyukov on 15/06/2022.
//

import Foundation
import PaltaCore
import PaltaAnalyticsModel

final class EventQueueAssembly {
    let eventQueue: EventFacadeImpl
    let eventQueueCore: EventQueueImpl
    let batchSendController: BatchSendController
    let batchSender: BatchSenderImpl
    let contextModifier: ContextModifier
    let contextProvider: CurrentContextProvider
    let eventToBatchQueueBridge: EventToBatchQueueBridge
    let proxyLogger: ProxyLogger
    
    init(
        eventQueue: EventFacadeImpl,
        eventQueueCore: EventQueueImpl,
        batchSendController: BatchSendController,
        batchSender: BatchSenderImpl,
        contextModifier: ContextModifier,
        contextProvider: CurrentContextProvider,
        eventToBatchQueueBridge: EventToBatchQueueBridge,
        proxyLogger: ProxyLogger
    ) {
        self.eventQueue = eventQueue
        self.eventQueueCore = eventQueueCore
        self.batchSendController = batchSendController
        self.batchSender = batchSender
        self.contextModifier = contextModifier
        self.contextProvider = contextProvider
        self.eventToBatchQueueBridge = eventToBatchQueueBridge
        self.proxyLogger = proxyLogger
    }
}

extension EventQueueAssembly {
    convenience init(
        stack: Stack,
        coreAssembly: CoreAssembly,
        analyticsCoreAssembly: AnalyticsCoreAssembly,
        loggingPolicy: PaltaAnalytics.LoggingPolicy
    ) throws {
        let proxyLogger = ProxyLogger()
        proxyLogger.update(with: loggingPolicy)
        
        let workingUrl = try FileManager.default.url(
            for: .libraryDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
            .appendingPathComponent("PaltaDataPlatform")
            .appendingPathComponent("SchemaEvents")
        
        if !FileManager.default.fileExists(atPath: workingUrl.path) {
            try! FileManager.default.createDirectory(at: workingUrl, withIntermediateDirectories: true)
        }
        
        // Common
        
        let lock = NSRecursiveLock()
        
        // Telemetry
        
        let storeErrorsLogger = ErrorsCollectorImpl(lock: lock)
        let serializationErrorsLogger = ErrorsCollectorImpl(lock: lock)
        let networkInfoLogger = NetworkInfoLoggerImpl()
        
        // Core
        
        let core = EventQueueImpl(
            serializationErrorsProvider: serializationErrorsLogger,
            storageErrorsProvider: storeErrorsLogger,
            timer: TimerImpl(),
            lock: lock
        )
        
        let eventComposer = EventComposerImpl(
            sessionProvider: analyticsCoreAssembly.sessionManager
        )
        
        // Storages
        
        let contextStorage = ContextStorageImpl(
            folderURL: workingUrl,
            stack: stack,
            fileManager: .default
        )
        
        let sqliteStorage = try SQLiteStorage(errorsLogger: storeErrorsLogger, folderURL: workingUrl, logger: proxyLogger)
        
        // Context
        
        let currentContextManager = CurrentContextManager(stack: stack, storage: contextStorage, logger: proxyLogger)
        
        // Batches
        
        let batchComposer = BatchComposerImpl(
            uuidGenerator: UUIDGeneratorImpl(),
            contextProvider: contextStorage,
            userInfoProvider: analyticsCoreAssembly.userPropertiesKeeper,
            deviceInfoProvider: analyticsCoreAssembly.deviceInfoProvider,
            networkInfoProvider: networkInfoLogger,
            storageSpaceProvider: StorageSpaceProviderImpl(folderURL: workingUrl, fileManager: .default),
            logger: proxyLogger
        )
        
        let batchSender = BatchSenderImpl(
            httpClient: coreAssembly.httpClient,
            networkInfoLogger: networkInfoLogger
        )
        
        let batchQueue = BatchQueueImpl()
        
        let sendController = BatchSendController(
            batchQueue: batchQueue,
            batchStorage: sqliteStorage,
            batchSender: batchSender,
            timer: TimerImpl(),
            logger: proxyLogger,
            taskProvider: { BatchSendTaskImpl(batch: $0) }
        )
        
        let eventToBatchQueueBridge = EventToBatchQueueBridge(
            eventQueue: core,
            batchQueue: batchQueue,
            batchComposer: batchComposer,
            batchStorage: sqliteStorage,
            logger: proxyLogger
        )
        
        // EventQueue
        
        let eventQueue = EventFacadeImpl(
            stack: stack,
            core: core,
            storage: sqliteStorage,
            eventComposer: eventComposer,
            sessionManager: analyticsCoreAssembly.sessionManager,
            contextProvider: currentContextManager,
            backgroundNotifier: BackgroundNotifierImpl(notificationCenter: .default),
            errorLogger: serializationErrorsLogger,
            logger: proxyLogger
        )
        
        self.init(
            eventQueue: eventQueue,
            eventQueueCore: core,
            batchSendController: sendController,
            batchSender: batchSender,
            contextModifier: currentContextManager,
            contextProvider: currentContextManager,
            eventToBatchQueueBridge: eventToBatchQueueBridge,
            proxyLogger: proxyLogger
        )
    }
}

extension EventQueueAssembly {
    func update(with loggingPolicy: PaltaAnalytics.LoggingPolicy) {
        proxyLogger.update(with: loggingPolicy)
    }
}

private extension ProxyLogger {
    func update(with loggingPolicy: PaltaAnalytics.LoggingPolicy) {
        switch loggingPolicy {
        case .all:
            realLogger = PaltaAnalytics.DefaultLogger(messageTypes: .all)
        case .none:
            realLogger = nil
        case .selectedTypes(let types):
            realLogger = PaltaAnalytics.DefaultLogger(messageTypes: types)
        case .custom(let customLogger):
            realLogger = customLogger
        }
    }
}
