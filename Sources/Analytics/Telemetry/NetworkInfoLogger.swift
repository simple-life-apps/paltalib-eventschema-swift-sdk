//
//  NetworkInfoLogger.swift
//  
//
//  Created by Vyacheslav Beltyukov on 01/05/2023.
//

import Foundation

protocol NetworkTrace {
    func finish(with responseData: Data?)
}

protocol NetworkInfoLogger {
    func newTrace(for request: URLRequest) -> NetworkTrace
}

protocol NetworkInfoProvider {
    func getRecentNetworkInfo() -> NetwokInfo?
}

private final class NetworkTraceImpl: NetworkTrace {
    var finished: Bool = false
    let startTime: Int
    let request: URLRequest
    let logger: NetworkInfoLoggerImpl
    
    init(startTime: Int, request: URLRequest, logger: NetworkInfoLoggerImpl) {
        self.startTime = startTime
        self.request = request
        self.logger = logger
    }
    
    func finish(with responseData: Data?) {
        let time = currentTimestamp() - startTime
        logger.lock.lock()
        
        guard !finished else {
            return
        }
        
        finished = true
        
        logger.logTrace(size: request.httpBody?.count ?? 0, time: time)
        logger.lock.unlock()
    }
}

final class NetworkInfoLoggerImpl: NetworkInfoLogger, NetworkInfoProvider {
    fileprivate let lock = NSRecursiveLock()
    
    private var sizesAndTimes: [(Int, Int)] = []
    
    func newTrace(for request: URLRequest) -> NetworkTrace {
        NetworkTraceImpl(startTime: currentTimestamp(), request: request, logger: self)
    }
    
    func getRecentNetworkInfo() -> NetwokInfo? {
        lock.lock()
        defer { lock.unlock() }
        
        guard !sizesAndTimes.isEmpty else {
            return nil
        }
        
        var totalSize = 0.0
        var totalTime = 0.0
        var averageTime = 0.0
        let count = Double(sizesAndTimes.count)
        
        for (size, time) in sizesAndTimes {
            totalSize += Double(size) / 1000
            totalTime += Double(time) / 1000
            averageTime += Double(time) / count
        }
        
        sizesAndTimes = []
        
        return NetwokInfo(
            time: Int(averageTime.rounded()),
            speed: totalSize / totalTime
        )
    }
    
    fileprivate func logTrace(size: Int, time: Int) {
        sizesAndTimes.append((size, time))
    }
}
