//
//  UsersAPI.swift
//  GameOfChats
//
//  Created by John Raymund Catahay on 18/05/2017.
//  Copyright © 2017 John Raymund Catahay. All rights reserved.
//

import Foundation
import FirebaseDatabase

protocol UsersAPIProtocol {
    func getAllUsers(onreceive: @escaping (_ user: User) -> Void)
}

class UsersAPI: UsersAPIProtocol{
    
    func getAllUsers(onreceive: @escaping (_ user: User) -> Void){
        FIRDatabase.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
            guard let dict = snapshot.value as? [String : AnyObject] else { return }
            guard let user = User.from(dict: dict, withID: snapshot.key) else { return }
            onreceive(user)
        })
    }
}
