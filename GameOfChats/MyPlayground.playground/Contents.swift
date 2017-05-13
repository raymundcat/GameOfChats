//: Playground - noun: a place where people can play

import UIKit

class LoginCoordinator{
    
    private(set) var loginNavigation: LoginNavigation?{
        didSet{
            configureNavigation()
        }
    }
    
    private func configureNavigation(){
        //plugin reactive navigation components here
    }
    
    init(loginVC: LoginViewController, presenter: LoginPresenter){
        loginVC.loginInput = presenter
        loginVC.loginOutput = presenter
        loginNavigation = presenter
    }
}

class LoginViewController {
    
    var loginInput: LoginInput? {
        didSet{
            configureLoginInput()
        }
    }
    
    var loginOutput: LoginOutPut? {
        didSet{
            configureLoginOutput()
        }
    }
    
    private func configureLoginInput() {
        //plugin reactive input components here
    }
    
    private func configureLoginOutput() {
        //plugin reactive input components here
    }
}

protocol LoginInput {
    //some Login Input signal/react components vars { get }
}

protocol LoginOutPut {
    //some Login UI Output signal/react components vars { get }
}

protocol LoginNavigation {
    //some navigation signal/react components vars { get }
}

class LoginPresenter: LoginInput, LoginOutPut, LoginNavigation {
    //observes LoginInputs
    //publishes LoginOutputs
    //publishes LoginNavigations
}
