//
//  NewMessageViewController.swift
//  GameOfChats
//
//  Created by John Raymund Catahay on 29/04/2017.
//  Copyright © 2017 John Raymund Catahay. All rights reserved.
//

import UIKit
import FirebaseDatabase

class NewMessageViewController: UITableViewController{
    
    var users: [User] = [User]()
    
    let cellID = "cellID"
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(handleBack))
        fetchUsers()
        
        self.tableView.register(CustomCell.self, forCellReuseIdentifier: cellID)
    }
    
    func handleBack(){
        dismiss(animated: true, completion: nil)
    }
    
    func fetchUsers(){
        FIRDatabase.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
            guard let dict = snapshot.value as? [String : AnyObject] else { return }
            guard let name = dict["name"] as? String else { return }
            guard let email = dict["email"] as? String else { return }
            let imgURL = dict["profileImageURL"] as? String
            let user = User(name: name, email: email, imgURL: imgURL)
            self.users.append(user)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? CustomCell else {
            return UITableViewCell()
        }
        cell.user = users[indexPath.row]
        return cell
    }
}

class CustomCell: UITableViewCell{
    
    var user: User?{
        didSet{
            guard let user = user else { return }
            self.textLabel?.text = user.name
            self.detailTextLabel?.text = user.email
            if let url = user.imgURL{
                self.imgURL = URL(string: url)
            }
        }
    }
    
    var imgURL: URL?{
        didSet{
            guard let imgURL = imgURL else {
                self.imageView?.image = #imageLiteral(resourceName: "winter-logo")
                return
            }
            self.imageView?.loadCachedImage(fromURL: imgURL, withPlaceHolder: #imageLiteral(resourceName: "winter-logo"))
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        self.imageView?.image = #imageLiteral(resourceName: "winter-logo")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
