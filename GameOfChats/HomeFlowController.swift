//
//  HomeFlow.swift
//  GameOfChats
//
//  Created by John Raymund Catahay on 14/05/2017.
//  Copyright © 2017 John Raymund Catahay. All rights reserved.
//

import UIKit
import RxSwift

class HomeFlowController: FlowController {
    
    private let disposeBag = DisposeBag()
    private let config: FlowConfig
    private let viewController: HomeViewController
    private let presenter: HomePresenter
    
    private var loginFlowController: LoginFlowController?
    private var chatlogFlowController: ChatlogFlowController?
    private var newMessageFlowController: NewMessageFlowController?
    
    private lazy var titleView: TitleView = {
        let view = TitleView()
        return view
    }()
    
    init(config: FlowConfig) {
        self.config = config
        presenter = HomePresenter(authAPI: AuthAPI(), messagesAPI: MessagesAPI())
        
        viewController = HomeViewController()
        viewController.homeInput = presenter
        viewController.homeOutput = presenter
    }
    
    func start() {
        let loginConfig = FlowConfig(window: config.window,
                                     navigationController: config.navigationController,
                                     parent: self)
        loginFlowController = LoginFlowController(config: loginConfig)
        loginFlowController?.loginResult.subscribe({ _ in
            self.presenter.viewDidLoad.onNext(())
        }).addDisposableTo(disposeBag)
        
        let newMessageConfig = FlowConfig(window: config.window,
                                          navigationController: config.navigationController,
                                          parent: self)
        newMessageFlowController = NewMessageFlowController(config: newMessageConfig)
        newMessageFlowController?.didSelectUser.subscribe({ (event) in
            self.newMessageFlowController?.dismiss()
            guard let currentUID = self.presenter.currentUser.value?.id else { return }
            guard let partnerUID = event.element else { return }
            let chatlogConfig = FlowConfig(window: self.config.window,
                                           navigationController: self.config.navigationController,
                                           parent: self)
            self.chatlogFlowController = ChatlogFlowController(config: chatlogConfig, partnerUsers: (currentUID, partnerUID))
            self.chatlogFlowController?.start()
        }).addDisposableTo(disposeBag)
        
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
            self.newMessageFlowController?.start()
        }.addDisposableTo(disposeBag)
        
        presenter.shouldOpenMessagesForUser
            .throttle(0.5, scheduler: MainScheduler.instance)
            .subscribe { (event) in
                guard let currentUID = self.presenter.currentUser.value?.id else { return }
                guard let partnerUID = event.element else { return }
                let chatlogConfig = FlowConfig(window: self.config.window,
                                               navigationController: self.config.navigationController,
                                               parent: self)
                self.chatlogFlowController = ChatlogFlowController(config: chatlogConfig, partnerUsers: (currentUID, partnerUID))
                self.chatlogFlowController?.start()
        }.addDisposableTo(disposeBag)
        
        config.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func showLogin(){
        loginFlowController?.start()
    }
    
    @objc func handleLogout(){
        presenter.logOut.onNext(())
    }
    
    @objc func handleNewMessage(){
        presenter.openUsers.onNext(())
    }
}
