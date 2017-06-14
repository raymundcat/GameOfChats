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
    func getUser(withID id: String, onReceive: @escaping (_ result: Result<User>) -> Void)
}

class UsersAPI: UsersAPIProtocol{
    func getAllUsers(onreceive: @escaping (_ user: User) -> Void){
        FIRDatabase.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
            guard let dict = snapshot.value as? [String : AnyObject] else { return }
            guard let user = User.from(dict: dict, withID: snapshot.key) else { return }
            onreceive(user)
        })
    }
    
    func getUser(withID id: String, onReceive: @escaping (_ result: Result<User>) -> Void){
        if let user = UsersCache.shared.user(withID: id) {
            onReceive(Result.success(result: user))
        }else{
            FIRDatabase.database()
                .reference().child("users").child(id)
                .observeSingleEvent(of: .value, with: { (snapshot) in
                guard let dict = snapshot.value as? [String : AnyObject] else {
                    onReceive(Result.failure(error: UserFetchingError.invalidDictionary))
                    return
                }
                guard let user = User.from(dict: dict, withID: snapshot.key) else {
                    onReceive(Result.failure(error: UserFetchingError.failedToDecodeUser))
                    return
                }
                UsersCache.shared.save(user: user)
                onReceive(Result.success(result: user))
            }, withCancel: nil)
        }
    }
}

enum UserFetchingError: Error {
    case invalidDictionary
    case failedToDecodeUser
}

class UsersCache {
    static let shared = UsersCache()
    private let cache = NSCache<NSString, User>()
    private init() { }
    func user(withID id: String) -> User? {
        return self.cache.object(forKey: id as NSString)
    }
    func save(user: User) {
        self.cache.setObject(user, forKey: user.id as NSString)
    }
}

