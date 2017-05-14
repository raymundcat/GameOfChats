//
//  AppDelegate.swift
//  GameOfChats
//
//  Created by John Raymund Catahay on 24/04/2017.
//  Copyright © 2017 John Raymund Catahay. All rights reserved.
//

import UIKit
import Firebase

class InitialFlow: FlowController{
    
    let config: FlowConfig
    required init(config: FlowConfig) {
        self.config = config
    }
    
    func start() {
        let navigationController = UINavigationController(rootViewController: UIViewController())
        config.window?.rootViewController = navigationController
        
        let homeConfig = FlowConfig(window: config.window, navigationController: navigationController, parent: self)
        let homeFlow = HomeFlow(config: homeConfig)
        homeFlow.start()
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
        let initialFlow = InitialFlow(config: initialConfig)
        initialFlow.start()
        
        return true
    }
}

