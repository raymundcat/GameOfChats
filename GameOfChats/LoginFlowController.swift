//
//  LoginCoordinator.swift
//  GameOfChats
//
//  Created by John Raymund Catahay on 14/05/2017.
//  Copyright © 2017 John Raymund Catahay. All rights reserved.
//

import Foundation
import RxSwift

protocol LoginFlowOutput {
    var loginResult: PublishSubject<String> { get }
}

class LoginFlowController: FlowController, LoginFlowOutput{
    
    private let disposeBag = DisposeBag()
    
    private let config: FlowConfig
    private let viewController: LoginViewController
    private let presenter: LoginPresenter
    let loginResult = PublishSubject<String>()
    
    init(config: FlowConfig) {
        self.config = config
        presenter = LoginPresenter(authAPI: AuthAPI())
        viewController = LoginViewController()
        viewController.loginInput = presenter
        
        presenter.loginResult.subscribe { (event) in
            guard let uid = event.element else { return }
            self.loginResult.onNext(uid)
            self.config.navigationController?.dismiss(animated: true, completion: nil)
            }.addDisposableTo(disposeBag)
        
        presenter.registerResult.subscribe { (event) in
            guard let uid = event.element else { return }
            self.loginResult.onNext(uid)
            self.config.navigationController?.dismiss(animated: true, completion: nil)
            }.addDisposableTo(disposeBag)
    }
    
    func start() {
        config.navigationController?.present(viewController, animated: true, completion: nil)
    }
}
