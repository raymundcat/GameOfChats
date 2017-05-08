//
//  UIImageView+Cache.swift
//  GameOfChats
//
//  Created by John Raymund Catahay on 30/04/2017.
//  Copyright © 2017 John Raymund Catahay. All rights reserved.
//

import UIKit

extension UIImageView{
    
    func loadCachedImage(fromURL url: URL, withPlaceHolder placeHolder: UIImage?) {
        ImageCache.shared.image(for: url) { (result) in
            switch result{
            case .success(let image):
                self.image = image
                break
            case .failure(_):
                self.image = placeHolder
                break
            }
        }
    }
}

enum ImageCacheError: Error{
    case faileToDecodeImage
}

enum ImageCacheResult{
    case success(image: UIImage)
    case failure(error: Error)
}

class ImageCache {
    
    /// A singleton instance of `ImageCache`.
    static let shared = ImageCache()
    private let cache = NSCache<NSString, UIImage>()
    
    private init() { }
    
    func image(for url: URL, completionHandler: @escaping (_ result: ImageCacheResult) -> Void) {
        DispatchQueue.main.async {
            if let cachedImage = self.cache.object(forKey: url.absoluteString as NSString)  {
                /* Use cached image. */
                print("Use cached image")
                completionHandler(.success(image: cachedImage))
                return
            }
            /* No cached image exists. Download image instead. */
            print("Download Image")
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    completionHandler(.failure(error: error))
                    return
                }
                guard let data = data, let image = UIImage(data: data) else {
                    completionHandler(.failure(error: ImageCacheError.faileToDecodeImage))
                    return
                }
                DispatchQueue.main.async {
                    self.cache.setObject(image, forKey: url.absoluteString as NSString)
                    completionHandler(.success(image: image))
                }
            }.resume()
        }
    }
}
