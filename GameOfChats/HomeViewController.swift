//
//  HomeViewController.swift
//  GameOfChats
//
//  Created by John Raymund Catahay on 24/04/2017.
//  Copyright © 2017 John Raymund Catahay. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class HomeViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "New", style: .plain, target: self, action: #selector(handleNewMessage))
        
        checkUserLoggedIn()
    }
    
    func handleNewMessage(){
        let newMessageVC = NewMessageViewController()
        let newNavController = UINavigationController(rootViewController: newMessageVC)
        present(newNavController, animated: true, completion: nil)
    }
    
    func checkUserLoggedIn(){
        //check if user is logged in
        if FIRAuth.auth()?.currentUser?.uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0.2)
        }else{
            guard let uid = FIRAuth.auth()?.currentUser?.uid else { return }
            FIRDatabase.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                guard let dict = snapshot.value as? [String : AnyObject] else { return }
                guard let user = User.from(dict: dict) else { return }
                self.setupNavBar(withUser: user)
            })
        }
    }
    
    lazy var titleView: TitleView = {
        let view = TitleView()
        return view
    }()
    
    func setupNavBar(withUser user: User){
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        if let stringUrl = user.imgURL, let url = URL(string: stringUrl) {
            titleView.imageView.loadCachedImage(fromURL: url, withPlaceHolder: #imageLiteral(resourceName: "winter-logo"))
        }
        titleView.nameLabel.text = user.name
        navigationItem.titleView = titleView
    }
    
    func handleLogout(){
        do {
            try FIRAuth.auth()?.signOut()
        } catch let error {
            print("error \(error)")
        }
        present(LoginViewController(), animated: true, completion: nil)
    }
}

class TitleView: UIView{
    
    lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    func setupImageView(){
        imageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    func setupNameLabel(){
        nameLabel.leftAnchor.constraint(equalTo: imageView.rightAnchor, constant: 8).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
    }
    
    func setupContainerView(){
        containerView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.addSubview(containerView)
        containerView.addSubview(imageView)
        containerView.addSubview(nameLabel)
        setupContainerView()
        setupImageView()
        setupNameLabel()
    }
}
