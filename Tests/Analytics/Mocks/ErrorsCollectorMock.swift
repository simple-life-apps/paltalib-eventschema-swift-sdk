//
//  ErrorsCollectorMock.swift
//  
//
//  Created by Vyacheslav Beltyukov on 27/04/2023.
//

import Foundation
@testable import PaltaAnalytics

final class ErrorsCollectorMock: ErrorsCollector {
    var errorsLogged: [String] = []
    
    func logError(_ message: String) {
        errorsLogged.append(message)
    }
}

final class ErrorsProviderMock: ErrorsProvider {
    var errors: [String] = []
    
    func getErrors() -> [String] {
        errors
    }
}
