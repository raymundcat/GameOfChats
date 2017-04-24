//
//  LoginViewController.swift
//  GameOfChats
//
//  Created by John Raymund Catahay on 24/04/2017.
//  Copyright © 2017 John Raymund Catahay. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .heroBlue
        
        let inputsContainerView = UIView()
        inputsContainerView.backgroundColor = .white
        view.addSubview(inputsContainerView)
        
        inputsContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        inputsContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        inputsContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
}
