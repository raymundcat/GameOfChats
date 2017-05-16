//
//  AppDelegate.swift
//  GameOfChats
//
//  Created by John Raymund Catahay on 24/04/2017.
//  Copyright © 2017 John Raymund Catahay. All rights reserved.
//

import UIKit
import Firebase

class InitialFlowController: FlowController{
    
    private let config: FlowConfig
    init(config: FlowConfig) {
        self.config = config
    }
    
    func start() {
        let navigationController = UINavigationController(rootViewController: UIViewController())
        config.window?.rootViewController = navigationController
        
        let homeConfig = FlowConfig(window: config.window, navigationController: navigationController, parent: self)
        let homeFlowController = HomeFlowController(config: homeConfig)
        homeFlowController.start()
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        FIRApp.configure()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        
        let initialConfig = FlowConfig(window: window, navigationController: nil, parent: nil)
        let initialFlowController = InitialFlowController(config: initialConfig)
        initialFlowController.start()
        
        return true
    }
}

