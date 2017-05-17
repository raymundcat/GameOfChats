//
//  NewMessagePresenter.swift
//  GameOfChats
//
//  Created by John Raymund Catahay on 18/05/2017.
//  Copyright © 2017 John Raymund Catahay. All rights reserved.
//

import Foundation
import RxSwift

protocol NewMessageInput {
    var viewDidLoad: PublishSubject<()> { get }
    var didSelectUser: PublishSubject<String> { get }
}

protocol NewMessageOutput {
    var users: Variable<[User]> { get }
}

class NewMessagePresenter: NewMessageInput, NewMessageOutput{
    
    let viewDidLoad = PublishSubject<()>()
    let didSelectUser = PublishSubject<String>()
    
    let users = Variable<[User]>([])
    
    private let disposeBag = DisposeBag()
    private let usersAPI: UsersAPIProtocol
    
    init(usersAPI: UsersAPIProtocol) {
        self.usersAPI = usersAPI
        
        viewDidLoad.subscribe { _ in
            self.usersAPI.getAllUsers(onreceive: { (user) in
                self.users.value.append(user)
            })
        }.addDisposableTo(disposeBag)
    }
}
