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
    func loginUser(credential: LoginCredential)
    func registerUser(form: RegistrationForm)
}

protocol LoginOutput {
    
}

protocol LoginNavigation {
    
}

class LoginPresenter: LoginInput{
    
    private let loginAPI: LoginAPIProtocol
    
    init(loginAPI: LoginAPIProtocol = LoginAPI()) {
        self.loginAPI = loginAPI
    }
    
    func loginUser(credential: LoginCredential){
        loginAPI.loginUser(credential: credential).then{ uid -> Void in
            
        }.catch{ error in
            
        }
    }
    
    func registerUser(form: RegistrationForm){
        loginAPI.registerUser(form: form).then{ uid -> Void in
            
        }.catch{ error in
                
        }
    }
}
