//
//  FlowController.swift
//  GameOfChats
//
//  Created by John Raymund Catahay on 14/05/2017.
//  Copyright © 2017 John Raymund Catahay. All rights reserved.
//

import Foundation

enum FlowType {
    case main
    case navigation
}

struct FlowConfig {
    let window: UIWindow?
    let navigationController: UINavigationController?
    let parent: FlowController?
    
    func whichFlowAmI() -> FlowType? {
        if window != nil { return .main }
        if navigationController != nil { return .navigation }
        return nil
    }
}

protocol FlowController {
    init(config : FlowConfig)
    func start()
}
