//
//  CurrentContextManager.swift
//  PaltaAnalytics
//
//  Created by Vyacheslav Beltyukov on 22/06/2022.
//

import Foundation
import PaltaAnalyticsModel

protocol ContextModifier {
    func editContext<Context: BatchContext>(_ editor: (inout Context) -> Void)
    func stripContexts(excluding contextIds: Set<UUID>)
}

protocol CurrentContextProvider {
    var context: BatchContext { get }
    var currentContextId: UUID { get }
}

final class CurrentContextManager: ContextModifier, CurrentContextProvider {
    var context: BatchContext {
        lock.lock()
        defer { lock.unlock() }
        
        if let context = _context {
            return context
        }
        
        let context = generateEmptyContext()
        _context = context
        return context
    }
    
    var currentContextId: UUID {
        lock.lock()
        defer { lock.unlock() }
        return _currentContextId
    }
    
    private var _currentContextId = UUID()
    
    private var _context: BatchContext?
    
    private let lock = NSRecursiveLock()
    
    private let stack: Stack
    private let storage: ContextStorage
    private let logger: Logger
    
    init(stack: Stack, storage: ContextStorage, logger: Logger) {
        self.stack = stack
        self.storage = storage
        self.logger = logger
    }
    
    func editContext<Context: BatchContext>(_ editor: (inout Context) -> Void) {
        lock.lock()
        var context = (_context ?? generateEmptyContext()) as! Context
        editor(&context)
        
        logger.log(
            .contextChange,
            "New context:\n\(prepareLogMessage(for: context))"
        )
        
        _currentContextId = UUID()
        do {
            try storage.saveContext(context, with: currentContextId)
        } catch {
            logger.log(.error, "Error saving context: \(context)")
        }
        
        _context = context
        lock.unlock()
    }
    
    func stripContexts(excluding contextIds: Set<UUID>) {
        do {
            try storage.stripContexts(excluding: contextIds)
        } catch {
            logger.log(.error, "Error stripping contexts: \(context)")
        }
    }
    
    private func generateEmptyContext() -> BatchContext {
        stack.context.init()
    }
    
    private func prepareLogMessage(for context: any BatchContext) -> String {
        String(
            data: (try? JSONSerialization.data(
                withJSONObject: context.asJSON(),
                options: [.prettyPrinted, .sortedKeys]
            )) ?? Data(),
            encoding: .utf8
        ) ?? ""
    }
}
