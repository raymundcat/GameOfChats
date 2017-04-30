//
//  UIImageView+Cache.swift
//  GameOfChats
//
//  Created by John Raymund Catahay on 30/04/2017.
//  Copyright © 2017 John Raymund Catahay. All rights reserved.
//

import UIKit

let imageCache = NSCache<AnyObject, AnyObject>()

extension UIImageView{
    func loadCachedImage(fromURL url: URL, withPlaceHolder placeHolder: UIImage?){
        
        if let imageFromCache = imageCache.object(forKey: url as AnyObject) as? UIImage{
            self.image = imageFromCache
            return
        }
        
        self.image = placeHolder
        URLSession.shared.dataTask(with: url, completionHandler: { (data, session, error) in
            guard let data = data, let image = UIImage(data: data), error == nil else {
                return
            }
            
            DispatchQueue.main.async {
                self.image = image
                imageCache.setObject(image, forKey: url as AnyObject)
            }
        }).resume()
    }
}
