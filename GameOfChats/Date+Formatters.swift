//
//  Date+Formatters.swift
//  GameOfChats
//
//  Created by John Raymund Catahay on 05/05/2017.
//  Copyright © 2017 John Raymund Catahay. All rights reserved.
//

import Foundation

extension Date{
    func simpleTimeFormat() -> String?{
        return format(withString: "hh:mm:ss a")
    }
    
    func format(withString format: String) -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}
