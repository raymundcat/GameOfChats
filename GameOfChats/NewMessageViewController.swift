//
//  NewMessageViewController.swift
//  GameOfChats
//
//  Created by John Raymund Catahay on 29/04/2017.
//  Copyright © 2017 John Raymund Catahay. All rights reserved.
//

import UIKit
import FirebaseDatabase

protocol NewMessagesDelegate: class {
    func newMessagesDidChoose(user: User)
}

class NewMessageViewController: UITableViewController{
    
    weak var delegate: NewMessagesDelegate?
    
    var users: [User] = [User]()
    
    let cellID = "cellID"
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(handleBack))
        fetchUsers()
        
        self.tableView.register(UserCell.self, forCellReuseIdentifier: cellID)
    }
    
    func handleBack(){
        dismiss(animated: true, completion: nil)
    }
    
    func fetchUsers(){
        FIRDatabase.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
            guard let dict = snapshot.value as? [String : AnyObject] else { return }
            guard let user = User.from(dict: dict, withID: snapshot.key) else { return }
            self.users.append(user)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
    }
}

extension NewMessageViewController{
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65.0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? UserCell else {
            return UITableViewCell()
        }
        cell.user = users[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true, completion: {
            self.delegate?.newMessagesDidChoose(user: self.users[indexPath.row])
        })
    }
}
