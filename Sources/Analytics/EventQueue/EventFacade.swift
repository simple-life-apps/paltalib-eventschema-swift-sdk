//
//  EventFacade.swift
//  PaltaAnalytics
//
//  Created by Vyacheslav Beltyukov on 07/06/2022.
//

import Foundation
import PaltaAnalyticsModel

protocol EventFacade {
    func logEvent<E: Event>(_ incomingEvent: E)
}

final class EventFacadeImpl: EventFacade {
    private let stack: Stack
    private let core: EventQueue
    private let storage: EventStorage
    private let eventComposer: EventComposer
    private let sessionManager: SessionManager
    private let contextProvider: CurrentContextProvider
    private let backgroundNotifier: BackgroundNotifier
    private let errorLogger: ErrorsCollector
    private let logger: Logger

    init(
        stack: Stack,
        core: EventQueue,
        storage: EventStorage,
        eventComposer: EventComposer,
        sessionManager: SessionManager,
        contextProvider: CurrentContextProvider,
        backgroundNotifier: BackgroundNotifier,
        errorLogger: ErrorsCollector,
        logger: Logger
    ) {
        self.stack = stack
        self.core = core
        self.storage = storage
        self.eventComposer = eventComposer
        self.sessionManager = sessionManager
        self.contextProvider = contextProvider
        self.backgroundNotifier = backgroundNotifier
        self.errorLogger = errorLogger
        self.logger = logger

        setupCore(core, liveQueue: false)
        startSessionManager()
        subscribeForBackgroundNotifications()
    }
    
    func logEvent<E: Event>(_ incomingEvent: E) {
        do {
            logger.log(.event(incomingEvent))
            logEvent(
                with: try incomingEvent.header?.serialized(),
                and: try incomingEvent.payload.serialized(),
                timestamp: nil,
                skipRefreshSession: false
            )
        } catch {
            logger.log(.error(error, "Failed to serialize event due to error: \(error)"))
            errorLogger.logError(error.localizedDescription)
        }
    }
    
    private func logEvent(
        with header: Data?,
        and payload: Data,
        timestamp: Int?,
        skipRefreshSession: Bool
    ) {
        if !skipRefreshSession {
            sessionManager.refreshSession(with: currentTimestamp())
        }

        let event = eventComposer.composeEvent(
            with: header,
            and: payload,
            timestamp: timestamp
        )
        
        let storableEvent = StorableEvent(
            event: IdentifiableEvent(id: UUID(), event: event),
            contextId: contextProvider.currentContextId
        )
        
        storage.storeEvent(storableEvent)
        core.addEvent(storableEvent)
    }

    private func setupCore(_ core: EventQueue, liveQueue: Bool) {
        core.removeHandler = { [weak self] in
            guard let self = self else { return }

            $0.forEach {
                self.storage.removeEvent(with: $0.event.id)
            }
        }

        guard !liveQueue else {
            return
        }

        storage.loadEvents { [core] events in
            core.addEvents(events)
        }
    }

    private func startSessionManager() {        
        sessionManager.start()
    }
    
    private func subscribeForBackgroundNotifications() {
        backgroundNotifier.addListener { [weak self] in
            self?.core.forceFlush()
        }
    }
    
    private func prepareLogMessage(for event: any Event) -> String {
        let name = event.name
        let propertiesInitialString = String(
            data: (try? JSONSerialization.data(
                withJSONObject: event.asJSON(withContext: true),
                options: [.prettyPrinted, .sortedKeys]
            )) ?? Data(),
            encoding: .utf8
        ) ?? ""
        let propertiesFormattedString = propertiesInitialString
            .components(separatedBy: "\n")
            .map { "    \($0)" }
            .joined(separator: "\n")
        
        return "\(name)(\n\(propertiesFormattedString)\n)"
    }
}

