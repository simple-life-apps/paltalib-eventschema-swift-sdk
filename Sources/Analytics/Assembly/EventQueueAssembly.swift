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
    let eventQueue: EventQueueImpl
    let eventQueueCore: EventQueueCoreImpl
    let batchSendController: BatchSendControllerImpl
    let batchSender: BatchSenderImpl
    let contextModifier: ContextModifier
    
    init(
        eventQueue: EventQueueImpl,
        eventQueueCore: EventQueueCoreImpl,
        batchSendController: BatchSendControllerImpl,
        batchSender: BatchSenderImpl,
        contextModifier: ContextModifier
    ) {
        self.eventQueue = eventQueue
        self.eventQueueCore = eventQueueCore
        self.batchSendController = batchSendController
        self.batchSender = batchSender
        self.contextModifier = contextModifier
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
        
        // Core
        
        let core = EventQueueCoreImpl(timer: TimerImpl())
        
        let eventComposer = EventComposerImpl(
            sessionProvider: analyticsCoreAssembly.sessionManager
        )
        
        // Storages
        
        let contextStorage = ContextStorageImpl(
            folderURL: workingUrl,
            stack: stack,
            fileManager: .default
        )
        
        let sqliteStorage = try SQLiteStorage(folderURL: workingUrl)
        
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
        
        let sendController = BatchSendControllerImpl(
            batchComposer: batchComposer,
            batchStorage: sqliteStorage,
            batchSender: batchSender,
            timer: TimerImpl()
        )
        
        // EventQueue
        
        let eventQueue = EventQueueImpl(
            stack: stack,
            core: core,
            storage: sqliteStorage,
            sendController: sendController,
            eventComposer: eventComposer,
            sessionManager: analyticsCoreAssembly.sessionManager,
            contextProvider: currentContextManager,
            backgroundNotifier: BackgroundNotifierImpl(notificationCenter: .default)
        )
        
        self.init(
            eventQueue: eventQueue,
            eventQueueCore: core,
            batchSendController: sendController,
            batchSender: batchSender,
            contextModifier: currentContextManager
        )
    }
}
