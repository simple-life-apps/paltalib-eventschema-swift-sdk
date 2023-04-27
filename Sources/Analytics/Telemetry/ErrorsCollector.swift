//
//  ErrorsCollector.swift
//  
//
//  Created by Vyacheslav Beltyukov on 27/04/2023.
//

import Foundation

protocol ErrorsCollector {
    func logError(_ message: String)
}

protocol ErrorsProvider {
    func getErrors() -> [String]
}

final class ErrorsCollectorImpl {
    private var errors: [String] = []
    
    private let lock: NSLocking
    
    init(lock: NSLocking) {
        self.lock = lock
    }
}

extension ErrorsCollectorImpl: ErrorsCollector {
    func logError(_ message: String) {
        lock.lock()
        defer { lock.unlock() }
        
        let spaceLeft = 50_000 - errors.reduce(0, { $0 + $1.count })
        
        guard errors.count < 50, spaceLeft > 0 else {
            return
        }
        
        let maxLength = min(spaceLeft, 8_000)
        
        errors.append(String(message.prefix(maxLength)))
    }
}

extension ErrorsCollectorImpl: ErrorsProvider {
    func getErrors() -> [String] {
        lock.lock()
        defer { lock.unlock() }
        
        let result = errors
        errors = []
        
        return result
    }
}
