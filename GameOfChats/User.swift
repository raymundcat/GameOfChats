//
//  User.swift
//  GameOfChats
//
//  Created by John Raymund Catahay on 29/04/2017.
//  Copyright © 2017 John Raymund Catahay. All rights reserved.
//

import Foundation

struct User {
    let name: String
    let email: String
    let imgURL: String?
    
    static func from(dict: [String : AnyObject]) -> User?{
        guard let name = dict["name"] as? String else { return nil }
        guard let email = dict["email"] as? String else { return nil }
        let imgURL = dict["profileImageURL"] as? String
        return User(name: name, email: email, imgURL: imgURL)
    }
}
