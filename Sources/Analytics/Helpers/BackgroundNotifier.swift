//
//  BackgroundNotifier.swift
//  PaltaAnalytics
//
//  Created by Vyacheslav Beltyukov on 29/09/2022.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif

protocol BackgroundNotifier {
    func addListener(_ listener: @escaping () -> Void)
}

final class BackgroundNotifierImpl: BackgroundNotifier {
    private let queue = OperationQueue().do {
        $0.underlyingQueue = .global()
        $0.maxConcurrentOperationCount = 1
    }
    
    private var listeners: [() -> Void] = []
    
    private var token: Any?
    
    init(notificationCenter: NotificationCenter) {
        #if canImport(UIKit)
        token = notificationCenter.addObserver(
            forName: UIApplication.didEnterBackgroundNotification,
            object: nil,
            queue: queue
        ) { [weak self] _ in
            self?.listeners.forEach { $0() }
        }
        #endif
    }
    
    func addListener(_ listener: @escaping () -> Void) {
        queue.addOperation {
            self.listeners.append(listener)
        }
    }
}
