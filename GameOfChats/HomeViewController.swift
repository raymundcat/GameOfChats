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
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Log Out", style: .plain, target: self, action: #selector(handleLogout))
        
        checkUserLoggedIn()
    }
    
    func checkUserLoggedIn(){
        //check if user is logged in
        if FIRAuth.auth()?.currentUser?.uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0.2)
        }else{
            guard let uid = FIRAuth.auth()?.currentUser?.uid else { return }
            FIRDatabase.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                
                guard let dict = snapshot.value as? [String : AnyObject] else { return }
                
                self.navigationItem.title = dict["name"] as? String ?? "No name found?"
            })
        }
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
