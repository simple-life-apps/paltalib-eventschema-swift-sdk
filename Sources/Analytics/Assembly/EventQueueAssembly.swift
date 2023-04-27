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
    let eventToBatchQueueBridge: EventToBatchQueueBridge
    
    init(
        eventQueue: EventFacadeImpl,
        eventQueueCore: EventQueueImpl,
        batchSendController: BatchSendController,
        batchSender: BatchSenderImpl,
        contextModifier: ContextModifier,
        eventToBatchQueueBridge: EventToBatchQueueBridge
    ) {
        self.eventQueue = eventQueue
        self.eventQueueCore = eventQueueCore
        self.batchSendController = batchSendController
        self.batchSender = batchSender
        self.contextModifier = contextModifier
        self.eventToBatchQueueBridge = eventToBatchQueueBridge
    }
}

extension EventQueueAssembly {
    convenience init(
        stack: Stack,
        coreAssembly: CoreAssembly,
        analyticsCoreAssembly: AnalyticsCoreAssembly
    ) throws {
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
        
        // Core
        
        let core = EventQueueImpl(timer: TimerImpl())
        
        let eventComposer = EventComposerImpl(
            sessionProvider: analyticsCoreAssembly.sessionManager
        )
        
        // Storages
        
        let contextStorage = ContextStorageImpl(
            folderURL: workingUrl,
            stack: stack,
            fileManager: .default
        )
        
        let sqliteStorage = try SQLiteStorage(errorsLogger: storeErrorsLogger, folderURL: workingUrl)
        
        // Context
        
        let currentContextManager = CurrentContextManager(stack: stack, storage: contextStorage)
        
        // Batches
        
        let batchComposer = BatchComposerImpl(
            uuidGenerator: UUIDGeneratorImpl(),
            contextProvider: contextStorage,
            userInfoProvider: analyticsCoreAssembly.userPropertiesKeeper,
            deviceInfoProvider: analyticsCoreAssembly.deviceInfoProvider
        )
        
        let batchSender = BatchSenderImpl(
            httpClient: coreAssembly.httpClient
        )
        
        let batchQueue = BatchQueueImpl()
        
        let sendController = BatchSendController(
            batchQueue: batchQueue,
            batchStorage: sqliteStorage,
            batchSender: batchSender,
            timer: TimerImpl(),
            taskProvider: { BatchSendTaskImpl(batch: $0) }
        )
        
        let eventToBatchQueueBridge = EventToBatchQueueBridge(
            eventQueue: core,
            batchQueue: BatchQueueImpl(),
            batchComposer: batchComposer,
            batchStorage: sqliteStorage
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
            errorLogger: serializationErrorsLogger
        )
        
        self.init(
            eventQueue: eventQueue,
            eventQueueCore: core,
            batchSendController: sendController,
            batchSender: batchSender,
            contextModifier: currentContextManager,
            eventToBatchQueueBridge: eventToBatchQueueBridge
        )
    }
}
