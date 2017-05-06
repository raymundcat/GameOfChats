//
//  UIColor+Extemsions.swift
//  GameOfChats
//
//  Created by John Raymund Catahay on 24/04/2017.
//  Copyright © 2017 John Raymund Catahay. All rights reserved.
//

import UIKit

extension UIColor{
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(red: r/255 , green: g/255, blue: b/255, alpha: 1)
    }
    
    static var heroBlue: UIColor { return UIColor(r: 61, g: 91, b: 151) }
}
