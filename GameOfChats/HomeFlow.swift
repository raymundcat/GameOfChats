//
//  HomeFlow.swift
//  GameOfChats
//
//  Created by John Raymund Catahay on 14/05/2017.
//  Copyright © 2017 John Raymund Catahay. All rights reserved.
//

import UIKit
import RxSwift

class HomeFlow: FlowController {
    
    let config: FlowConfig
    let viewController: HomeViewController
    let presenter: HomePresenter
    
    var loginFlow: LoginFlow?
    
    lazy var titleView: TitleView = {
        let view = TitleView()
        return view
    }()
    
    let disposeBag = DisposeBag()
    
    required init(config: FlowConfig) {
        self.config = config
        presenter = HomePresenter(authAPI: AuthAPI(), messagesAPI: MessagesAPI())
        
        viewController = HomeViewController()
        viewController.homeInput = presenter
        viewController.homeOutput = presenter
    }
    
    func start() {
        
        let loginConfig = FlowConfig(window: config.window, navigationController: config.navigationController, parent: self)
        loginFlow = LoginFlow(config: loginConfig)
        
        viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        viewController.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "New", style: .plain, target: self, action: #selector(handleNewMessage))
        
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        viewController.navigationItem.titleView = titleView
        
        presenter.currentUser.asObservable().subscribe { (event) in
        guard let user = event.element else { return }
            self.titleView.user = user
        }.addDisposableTo(disposeBag)
        
        presenter.shouldLogOut.subscribe { (_) in
            self.showLogin()
        }.addDisposableTo(disposeBag)
        
        presenter.shouldOpenUsers.subscribe { (_) in
            //open users/messages flow
        }.addDisposableTo(disposeBag)
        
        presenter.shouldOpenMessagesForUser.subscribe { (_) in
            //open user chat
        }.addDisposableTo(disposeBag)
        
        config.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func showLogin(){
        loginFlow?.start()
    }
    
    @objc func handleLogout(){
        presenter.logOut.onNext(true)
    }
    
    @objc func handleNewMessage(){
        presenter.openUsers.onNext(true)
    }
}
