//
//  LoginViewController.swift
//  GameOfChats
//
//  Created by John Raymund Catahay on 24/04/2017.
//  Copyright © 2017 John Raymund Catahay. All rights reserved.
//

import UIKit
import Anchorage
import RxSwift

class LoginViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    
    let inputsContainerView: UIView = {
        let inputsContainerView = UIView()
        inputsContainerView.backgroundColor = .white
        inputsContainerView.layer.cornerRadius = 5
        inputsContainerView.layer.masksToBounds = true
        return inputsContainerView
    }()
    
    lazy var loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(r: 80, g: 101, b: 161)
        button.setTitle("REGISTER", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(handleLoginOrRegister), for: .touchUpInside)
        return button
    }()
    
    let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Name"
        return textField
    }()
    
    let nameSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Email"
        return textField
    }()
    
    let emailsSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Password"
        return textField
    }()
    
    lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = #imageLiteral(resourceName: "winter-logo")
        imageView.backgroundColor = .clear
        imageView.layer.shadowRadius = 2
        imageView.layer.shadowOpacity = 0.3
        imageView.layer.shadowOffset = .zero
        imageView.layer.shadowColor = UIColor.black.cgColor
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector((handleTapImageView))))
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    func handleTapImageView(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    lazy var loginRegisterSegmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Login","Register"])
        sc.tintColor = .white
        sc.selectedSegmentIndex = 0
        return sc
    }()
    
    var loginInput: LoginInput?
    
    func handleLoginOrRegister(){
        if loginRegisterSegmentedControl.selectedSegmentIndex == 0 {
            handleLogin()
        }else{
            handleRegister()
        }
    }
    
    func handleLogin(){
        guard let email = emailTextField.text, let password = passwordTextField.text else { return }
        let credential = LoginCredential(email: email, password: password)
        loginInput?.login.onNext(credential)
    }
    
    func handleRegister(){
        guard let email = emailTextField.text, let password = passwordTextField.text, let name = nameTextField.text, let chosenImage = profileImageView.image, chosenImage != #imageLiteral(resourceName: "winter-logo") else { return }
        let form = RegistrationForm(name: name, email: email, password: password, profileImage: chosenImage)
        loginInput?.register.onNext(form)
    }
    
    var containerViewHeightAnchor: NSLayoutConstraint?
    var nameTextFieldHeightAnchor: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleViewTap)))
        view.backgroundColor = .heroBlue
        view.addSubview(profileImageView)
        view.addSubview(inputsContainerView)
        view.addSubview(loginButton)
        view.addSubview(loginRegisterSegmentedControl)
        inputsContainerView.addSubview(nameTextField)
        inputsContainerView.addSubview(nameSeparatorView)
        inputsContainerView.addSubview(emailTextField)
        inputsContainerView.addSubview(emailsSeparatorView)
        inputsContainerView.addSubview(passwordTextField)
        
        profileImageView.centerXAnchor == view.centerXAnchor
        profileImageView.bottomAnchor == loginRegisterSegmentedControl.topAnchor - 10
        profileImageView.widthAnchor == 80
        profileImageView.heightAnchor == 80
        
        loginRegisterSegmentedControl.centerXAnchor == view.centerXAnchor
        loginRegisterSegmentedControl.bottomAnchor == inputsContainerView.topAnchor - 10
        loginRegisterSegmentedControl.widthAnchor == view.widthAnchor * 0.8
        loginRegisterSegmentedControl.heightAnchor == 30
        
        inputsContainerView.centerAnchors == view.centerAnchors
        containerViewHeightAnchor = inputsContainerView.heightAnchor == 80
        inputsContainerView.widthAnchor == view.widthAnchor * 0.8
        
        loginButton.centerXAnchor == view.centerXAnchor
        loginButton.topAnchor == inputsContainerView.bottomAnchor + 10
        loginButton.widthAnchor == view.widthAnchor * 0.8
        
        nameTextField.centerXAnchor == inputsContainerView.centerXAnchor
        nameTextField.topAnchor == inputsContainerView.topAnchor
        nameTextFieldHeightAnchor = nameTextField.heightAnchor == 0
        nameTextField.widthAnchor == inputsContainerView.widthAnchor * 0.9
        nameTextField.isHidden = true
        
        nameSeparatorView.centerXAnchor == inputsContainerView.centerXAnchor
        nameSeparatorView.topAnchor == nameTextField.bottomAnchor
        nameSeparatorView.heightAnchor == 0.5
        nameSeparatorView.widthAnchor == inputsContainerView.widthAnchor
        
        emailTextField.centerXAnchor == inputsContainerView.centerXAnchor
        emailTextField.topAnchor == nameSeparatorView.bottomAnchor
        emailTextField.heightAnchor == 40
        emailTextField.widthAnchor == inputsContainerView.widthAnchor * 0.9
        
        emailsSeparatorView.centerXAnchor == inputsContainerView.centerXAnchor
        emailsSeparatorView.topAnchor == emailTextField.bottomAnchor
        emailsSeparatorView.heightAnchor == 0.5
        emailsSeparatorView.widthAnchor == inputsContainerView.widthAnchor
        
        passwordTextField.centerXAnchor == inputsContainerView.centerXAnchor
        passwordTextField.topAnchor == emailsSeparatorView.bottomAnchor
        passwordTextField.heightAnchor == 40
        passwordTextField.widthAnchor == inputsContainerView.widthAnchor * 0.9
        
        loginRegisterSegmentedControl.rx
        .controlEvent(UIControlEvents.valueChanged)
        .subscribe { (event) in
            self.updateViews()
        }.addDisposableTo(disposeBag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateViews()
    }
    
    func updateViews(){
        let index = self.loginRegisterSegmentedControl.selectedSegmentIndex
        loginButton.setTitle(index == 0 ? "LOGIN" : "REGISTER", for: .normal)
        containerViewHeightAnchor?.constant = index == 0 ? 80 : 120
        nameTextFieldHeightAnchor?.constant = index == 0 ? 0 : 40
        nameTextField.isHidden = index == 0
        nameSeparatorView.isHidden = index == 0
        UIView.animate(withDuration: 0.25, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    func handleViewTap(){
        view.endEditing(true)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
}

extension LoginViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = getImage(fromPickerViewInfo: info){
            profileImageView.image = image
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        profileImageView.image = #imageLiteral(resourceName: "winter-logo")
        dismiss(animated: true, completion: nil)
    }
}

func getImage(fromPickerViewInfo info: [String: Any]) -> UIImage?{
    if let chosen = info[UIImagePickerControllerEditedImage] as? UIImage{
        return chosen
    }else{
        return info[UIImagePickerControllerOriginalImage] as? UIImage
    }
}
