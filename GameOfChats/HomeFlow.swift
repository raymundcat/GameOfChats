//
//  HomeFlow.swift
//  GameOfChats
//
//  Created by John Raymund Catahay on 14/05/2017.
//  Copyright © 2017 John Raymund Catahay. All rights reserved.
//

import UIKit

class HomeFlow: FlowController {
    
    let config: FlowConfig
    let viewController: HomeViewController
    let presenter: HomePresenter
    
    lazy var titleView: TitleView = {
        let view = TitleView()
        return view
    }()
    
    required init(config: FlowConfig) {
        self.config = config
        presenter = HomePresenter(authAPI: AuthAPI(), messagesAPI: MessagesAPI())
        viewController = HomeViewController()
        viewController.homeInput = presenter
        viewController.homeOutput = presenter
        
        viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        viewController.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "New", style: .plain, target: self, action: #selector(handleNewMessage))
        
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        viewController.navigationItem.titleView = titleView
    }
    
    func start() {
        config.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func showLogin(){
        let loginConfig = FlowConfig(window: config.window, navigationController: config.navigationController, parent: self)
        let loginFlow = LoginFlow(config: loginConfig)
        loginFlow.start()
    }
    
    @objc func handleLogout(){
        
    }
    
    @objc func handleNewMessage(){
        
    }
}
