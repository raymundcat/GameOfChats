//
//  LoginCoordinator.swift
//  GameOfChats
//
//  Created by John Raymund Catahay on 14/05/2017.
//  Copyright © 2017 John Raymund Catahay. All rights reserved.
//

import Foundation
import RxSwift

class LoginFlow: FlowController{
    
    let disposeBag = DisposeBag()
    
    let config: FlowConfig
    let viewController: LoginViewController
    let presenter: LoginPresenter
    
    required init(config: FlowConfig) {
        self.config = config
        viewController = LoginViewController()
        presenter = LoginPresenter(authAPI: AuthAPI())
        
        viewController.loginInput = presenter
    }
    
    func start() {
        presenter.loginResult.subscribe({ _ in
            self.config.navigationController?.dismiss(animated: true, completion: nil)
        }).addDisposableTo(disposeBag)
        config.navigationController?.present(viewController, animated: true, completion: nil)
    }
}
