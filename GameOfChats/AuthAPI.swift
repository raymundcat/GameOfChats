//
//  LoginAPI.swift
//  GameOfChats
//
//  Created by John Raymund Catahay on 13/05/2017.
//  Copyright © 2017 John Raymund Catahay. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

protocol AuthAPIProtocol {
    func getCurrentUser() -> Promise<User>
    func loginUser(credential: LoginCredential) -> Promise<String>
    func registerUser(form: RegistrationForm) -> Promise<String>
    func logout() -> Promise<()>
}

enum AuthError: Error{
    case noCurrentUser
}

class AuthAPI: AuthAPIProtocol {
    
    func getCurrentUser() -> Promise<User>{
        return Promise{ fulfill, reject in
            if FIRAuth.auth()?.currentUser?.uid == nil {
                reject(AuthError.noCurrentUser)
            }else{
                guard let uid = FIRAuth.auth()?.currentUser?.uid else { return }
                FIRDatabase.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                    guard let dict = snapshot.value as? [String : AnyObject] else { return }
                    guard let user = User.from(dict: dict, withID: snapshot.key) else { return }
                    fulfill(user)
                })
            }
        }
    }
    
    func logout() -> Promise<()> {
        return Promise{ fulfill, reject in
            do {
                try FIRAuth.auth()?.signOut()
                fulfill()
            } catch let error {
                reject(error)
            }
        }
    }
    
    func loginUser(credential: LoginCredential) -> Promise<String> {
        return Promise{ fulfill, reject in
            loginUser(email: credential.email, password: credential.password).then{ uid -> Void in
                fulfill(uid)
            }.catch{ error in
                reject(error)
            }
        }
    }
    
    func registerUser(form: RegistrationForm) -> Promise<String> {
        return Promise{ fulfill, reject in
            createUser(email: form.email, password: form.password).then{ uid -> Promise<(String, String)> in
                return self.upload(forUID: uid, userProfileImage: form.profileImage).then{($0, uid)}
            }.then{ (url, uid) -> Promise<String> in
                let userProfile = UserProfile(name: form.name, email: form.email, password: form.password, profileImageURL: url)
                return self.updateUserProfile(forUID: uid, withProfile: userProfile).then{ uid }
            }.then{ uid -> Void in
                fulfill(uid)
            }.catch{ error in
                reject(error)
            }
        }
    }
    
    func loginUser(email: String, password: String) -> Promise<String>{
        return Promise{ fulfill, reject in
            FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
                if let error = error {
                    reject(error)
                }
                if let uid = user?.uid{
                    fulfill(uid)
                }else{
                    reject(AccountCreationError.userNotFound)
                }
            })
        }
    }
    
    func createUser(email: String, password: String) -> Promise<String>{
        return Promise{ fulfill, reject in
            FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
                if let error = error {
                    reject(error)
                }
                if let uid = user?.uid{
                    fulfill(uid)
                }else{
                    reject(AccountCreationError.userNotFound)
                }
            })
        }
    }
    
    func upload(forUID uid: String, userProfileImage: UIImage) -> Promise<String>{
        return Promise{ fulfill, reject in
            let storageRef = FIRStorage.storage().reference().child("profileImageViews").child("\(uid).jpg")
            guard let imageData = UIImageJPEGRepresentation(userProfileImage, 0.1) else {
                reject(ImageUploadError.failedToReadImage)
                return
            }
            storageRef.put(imageData, metadata: nil, completion: { (metaData, error) in
                if let error = error {
                    reject(error)
                }else{
                    if let url = metaData?.downloadURL()?.absoluteString{
                        fulfill(url)
                    }else{
                        reject(ImageUploadError.noImageReturned)
                    }
                }
            })
        }
    }
    
    func updateUserProfile(forUID uid: String, withProfile profile: UserProfile) -> Promise<Void>{
        return Promise { fulfill, reject in
            let ref = FIRDatabase.database().reference(fromURL: firURL)
            let userRef = ref.child("users").child(uid)
            let values = ["email": profile.email,
                          "password": profile.password,
                          "name": profile.name,
                          "profileImageURL": profile.profileImageURL]
            
            userRef.updateChildValues(values, withCompletionBlock: { (error, ref) in
                if let error = error{
                    print("auth error occured: \(String(describing: error.localizedDescription))")
                    reject(error)
                    return
                }
                print("saved user successfully")
                fulfill()
            })
        }
    }
}
