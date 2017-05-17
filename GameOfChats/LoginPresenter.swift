//
//  LoginPresenter.swift
//  GameOfChats
//
//  Created by John Raymund Catahay on 13/05/2017.
//  Copyright © 2017 John Raymund Catahay. All rights reserved.
//

import Foundation
import RxSwift

protocol LoginInput {
    var login: PublishSubject<LoginCredential> { get }
    var register: PublishSubject<RegistrationForm> { get }
}

protocol LoginOutput {
    var loginResult: PublishSubject<String> { get }
    var registerResult: PublishSubject<String> { get }
}

class LoginPresenter: LoginInput, LoginOutput{
    
    private let disposeBag = DisposeBag()
    
    let loginResult = PublishSubject<String>()
    let registerResult = PublishSubject<String>()
    
    let login = PublishSubject<LoginCredential>()
    let register = PublishSubject<RegistrationForm>()
    
    private let authAPI: AuthAPIProtocol
    
    init(authAPI: AuthAPIProtocol) {
        self.authAPI = authAPI
        
        login.throttle(1, scheduler: MainScheduler.instance)
        .subscribe({ event in
            guard let credential = event.element else { return }
            self.loginUser(credential: credential)
        }).addDisposableTo(disposeBag)
        
        register.throttle(1, scheduler: MainScheduler.instance)
        .subscribe({ event in
            guard let form = event.element else { return }
            self.registerUser(form: form)
        }).addDisposableTo(disposeBag)
    }
    
    private func loginUser(credential: LoginCredential){
        authAPI.loginUser(credential: credential).then{ uid -> Void in
            self.loginResult.onNext(uid)
        }.catch{ error in
            self.loginResult.onError(error)
        }
    }
    
    private func registerUser(form: RegistrationForm){
        authAPI.registerUser(form: form).then{ uid -> Void in
            self.registerResult.onNext(uid)
        }.catch{ error in
            self.registerResult.onError(error)
        }
    }
}
