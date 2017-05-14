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
    
    let config: FlowConfig
    let viewController: LoginViewController
    let presenter: LoginPresenter
    
    required init(config: FlowConfig) {
        self.config = config
        viewController = LoginViewController()
        presenter = LoginPresenter(authAPI: AuthAPI())
        
        viewController.loginInput = presenter
        presenter.loginResult.subscribe({ [weak self] _ in
            guard let `self` = self else { return }
            self.config.navigationController?.dismiss(animated: true, completion: nil)
        }).addDisposableTo(DisposeBag())
    }
    
    func start() {
        config.navigationController?.pushViewController(viewController, animated: true)
    }
}
