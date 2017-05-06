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

    lazy var titleView: TitleView = {
        let view = TitleView()
        return view
    }()
    
    func showChatLog(forUser user: User){
        let vc = ChatLogViewController(collectionViewLayout: UICollectionViewFlowLayout())
        vc.user = user
        navigationController?.pushViewController(vc, animated: true)
    }
    
    let cellID = "cellID"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UserMessageCell.self, forCellReuseIdentifier: cellID)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "New", style: .plain, target: self, action: #selector(handleNewMessage))
        
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        navigationItem.titleView = titleView
        
        setUpNewUser()
    }
    
    func setUpNewUser(){
        checkUserLoggedIn()
        observeMessages()
    }
    
    func handleNewMessage(){
        let newMessageVC = NewMessageViewController()
        newMessageVC.delegate = self
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
                guard let user = User.from(dict: dict, withID: snapshot.key) else { return }
                self.titleView.user = user
            })
        }
    }
    
    lazy var loginViewController: LoginViewController = {
        let loginVC = LoginViewController()
        loginVC.delegate = self
        return loginVC
    }()
    
    func handleLogout(){
        do {
            try FIRAuth.auth()?.signOut()
        } catch let error {
            print("error \(error)")
        }
        present(loginViewController, animated: true, completion: nil)
    }
    
    var messages: [ChatMessage]{
        var messages = Array(messagesDict.values)
        messages.sort(by: { (message1, message2) -> Bool in
            return message1.timestamp > message2.timestamp
        })
        return messages
    }
    
    var messagesDict = [String : ChatMessage]()
    
    func observeMessages(){
        guard let user = FIRAuth.auth()?.currentUser else { return }
        self.messagesDict.removeAll()
        self.tableView.reloadData()
        let userMessagesRef = FIRDatabase.database().reference().child("user-messages")
        let messagesRef = FIRDatabase.database().reference().child("messages")
        userMessagesRef.child(user.uid).observe(.childAdded, with: { (snapshot) in
            messagesRef.child(snapshot.key).observeSingleEvent(of: .value, with: { (snapshot) in
                guard let dict = snapshot.value as? [String : AnyObject] else { return }
                guard let message = ChatMessage.from(dict: dict) else { return }
                guard let partnerID = message.getChatPartner(ofUser: user.uid) else { return }
                self.messagesDict[partnerID] = message
                
                self.handleReloadTable()
            }, withCancel: nil)
        }, withCancel: nil)
    }
    
    private var reloadTimer: Timer?
    func handleReloadTable(){
        reloadTimer?.invalidate()
        reloadTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { (timer) in
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
    }
}

extension HomeViewController{
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65.0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID) as? UserMessageCell else { return UITableViewCell() }
        cell.message = messages[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let userID = FIRAuth.auth()?.currentUser?.uid else { return }
        guard let partnerID = messages[indexPath.row].getChatPartner(ofUser: userID) else { return }
        FIRDatabase.database().reference().child("users").child(partnerID).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dict = snapshot.value as? [String : AnyObject] else { return }
            guard let partnerUser = User.from(dict: dict, withID: snapshot.key) else { return }
            self.showChatLog(forUser: partnerUser)
        }, withCancel: nil)
    }
}

extension HomeViewController: NewMessagesDelegate{
    func newMessagesDidChoose(user: User) {
        showChatLog(forUser: user)
    }
}

extension HomeViewController: LoginViewContollerDelegate{
    func loginViewControllerDidFinishLoginRegister() {
        setUpNewUser()
        loginViewController.dismiss(animated: true, completion: nil)
    }
}
