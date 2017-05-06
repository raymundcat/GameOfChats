//
//  User.swift
//  GameOfChats
//
//  Created by John Raymund Catahay on 29/04/2017.
//  Copyright © 2017 John Raymund Catahay. All rights reserved.
//

import Foundation

let userChache = UserCache()

struct User {
    let id: String
    let name: String
    let email: String
    let imgURL: String?
    
    static func from(dict: [String : AnyObject], withID id: String) -> User?{
        guard let name = dict["name"] as? String else { return nil }
        guard let email = dict["email"] as? String else { return nil }
        let imgURL = dict["profileImageURL"] as? String
        return User(id: id, name: name, email: email, imgURL: imgURL)
    }
}

class UserCache{
    let userChache = NSCache<AnyObject, AnyObject>()
    
    func getUser(withID id: String) -> User?{
        let userObject = userChache.object(forKey: id as AnyObject) as? UserObject
        return userObject?.user
    }
    
    func save(user: User){
        userChache.setObject(UserObject(user: user), forKey: user.id as AnyObject)
    }
    
    private class UserObject: NSObject{
        let user: User
        init(user: User) {
            self.user = user
        }
    }
}
