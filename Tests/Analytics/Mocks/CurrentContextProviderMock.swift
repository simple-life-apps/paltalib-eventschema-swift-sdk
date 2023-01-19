//
//  CurrentContextProviderMock.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 29/06/2022.
//

import Foundation
import PaltaAnalyticsModel
@testable import PaltaAnalytics

final class CurrentContextProviderMock: CurrentContextProvider {
    var context: BatchContext = BatchContextMock()
    var currentContextId: UUID = UUID()
}
