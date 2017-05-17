//
//  NewMessageFlowController.swift
//  GameOfChats
//
//  Created by John Raymund Catahay on 18/05/2017.
//  Copyright © 2017 John Raymund Catahay. All rights reserved.
//

import Foundation
import RxSwift

protocol NewMessageFlowOutput {
    var didSelectUser: PublishSubject<String> { get }
}

class NewMessageFlowController: FlowController, NewMessageFlowOutput{
    
    let didSelectUser = PublishSubject<String>()
    
    private let disposeBag = DisposeBag()
    private let viewController: NewMessageViewController
    private let presenter: NewMessagePresenter
    private let config: FlowConfig
    
    init(config: FlowConfig) {
        self.config = config
        
        presenter = NewMessagePresenter(usersAPI: UsersAPI())
        presenter.didSelectUser.bind(to: didSelectUser)
            .addDisposableTo(disposeBag)
        
        viewController = NewMessageViewController()
        viewController.input = presenter
        viewController.output = presenter
    }
    
    func start() {
        config.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func dismiss(){
        config.navigationController?.popViewController(animated: true)
    }
}
