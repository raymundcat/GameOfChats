//
//  UserProfile.swift
//  GameOfChats
//
//  Created by John Raymund Catahay on 02/05/2017.
//  Copyright © 2017 John Raymund Catahay. All rights reserved.
//

import Foundation

struct RegistrationForm{
    let name: String
    let email: String
    let password: String
    let profileImage: UIImage
}

struct UserProfile{
    let name: String
    let email: String
    let password: String
    let profileImageURL: String
}

struct LoginCredential{
    let email: String
    let password: String
}
