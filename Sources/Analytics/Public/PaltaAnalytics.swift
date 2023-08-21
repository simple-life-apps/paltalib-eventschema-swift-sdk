//
//  PaltaAnalytics.swift
//  PaltaAnalytics
//
//  Created by Vyacheslav Beltyukov on 29/06/2022.
//

import Foundation
import PaltaAnalyticsWiring
import PaltaAnalyticsModel

public class PaltaAnalytics {
    private static var stack: Stack?
    private static let lock = NSRecursiveLock()
    
    private static let initiated: Void = {
        PBWiringLauncher.wire()
    }()

    public static func initiate(with stack: Stack) {
        guard self.stack == nil else {
            print("PaltaLib: Analytics: Attempt to double initiate. First stack is used")
            return
        }

        self.stack = stack
    }
    
    public static var shared: PaltaAnalytics {
        lock.lock()
        defer { lock.unlock() }

        if let configuredInstance = _shared {
            return configuredInstance
        }
        
        // Use instead of dispatch once
        _ = initiated
        
        guard let stack = stack else {
            fatalError("Attempt to access PaltaAnalytics without setting up")
        }
        
        let assembly: AnalyticsAssembly?
        
        do {
            assembly = try AnalyticsAssembly(stack: stack)
        } catch {
            print("PaltaLib: Analytics: Failed to initialize instance. No events are tracked!")
            assembly = nil
        }
        
        let shared = PaltaAnalytics(assembly: assembly)
        _shared = shared
        
        return shared
    }
    
    private static var _shared: PaltaAnalytics?
    
    let assembly: AnalyticsAssembly?
    
    init(assembly: AnalyticsAssembly?) {
        self.assembly = assembly
    }
    
    #if E2E_TESTING
    
    static func dropInstance() {
        _shared = nil
    }
    
    #endif
}
