//
//  NetworkInfoLoggerMock.swift
//  
//
//  Created by Vyacheslav Beltyukov on 02/05/2023.
//

import Foundation
@testable import PaltaAnalytics

final class NetworkTraceMock: NetworkTrace {
    var stopped = false
    var data: Data?
    
    func finish(with responseData: Data?) {
        self.stopped = true
        self.data = responseData
    }
}

final class NetworkInfoLoggerMock: NetworkInfoLogger {
    let trace = NetworkTraceMock()
    
    var request: URLRequest?
    
    func newTrace(for request: URLRequest) -> NetworkTrace {
        self.request = request
        return trace
    }
}
