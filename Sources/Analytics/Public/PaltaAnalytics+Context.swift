//
//  PaltaAnalytics+Context.swift
//  PaltaAnalytics
//
//  Created by Vyacheslav Beltyukov on 30/06/2022.
//

import Foundation
import PaltaAnalyticsModel

public extension PaltaAnalytics {
    func _editContext<C: BatchContext>(_ modifier: (inout C) -> Void) {
        assembly?.eventQueueAssembly.contextModifier.editContext(modifier)
    }
    
    func _getContext<C: BatchContext>() -> C {
        assembly?.eventQueueAssembly.contextProvider.context as? C ?? C()
    }
}
