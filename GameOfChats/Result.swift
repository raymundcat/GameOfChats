//
//  Result.swift
//  GameOfChats
//
//  Created by John Raymund Catahay on 13/05/2017.
//  Copyright © 2017 John Raymund Catahay. All rights reserved.
//

import Foundation

enum Result<T>{
    case success(result: T)
    case failure(error: Error)
}
