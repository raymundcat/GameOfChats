//
//  Errors.swift
//  GameOfChats
//
//  Created by John Raymund Catahay on 02/05/2017.
//  Copyright © 2017 John Raymund Catahay. All rights reserved.
//

import Foundation

enum ImageUploadError: Error {
    case failedToReadImage
    case noImageReturned
}

enum AccountCreationError: Error{
    case userNotFound
}
