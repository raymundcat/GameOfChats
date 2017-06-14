//
//  UIImageView+Cache.swift
//  GameOfChats
//
//  Created by John Raymund Catahay on 30/04/2017.
//  Copyright © 2017 John Raymund Catahay. All rights reserved.
//

import UIKit
import PromiseKit

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
    case failedToDecodeImage
}

class ImageCache {
    static let shared = ImageCache()
    private let cache = NSCache<NSString, UIImage>()
    private init() { }
    
    func image(for url: URL) -> Promise<UIImage> {
        return Promise { fulfill, reject in
            image(for: url, completionHandler: { (result) in
                switch result {
                case .success(let image):
                    fulfill(image)
                    break
                case .failure(let error):
                    reject(error)
                    break
                }
            })
        }
    }
    
    func image(for url: URL, completionHandler: @escaping (_ result: Result<UIImage>) -> Void) {
        DispatchQueue.main.async {
            if let cachedImage = self.cache.object(forKey: url.absoluteString as NSString)  {
                completionHandler(.success(result: cachedImage))
                return
            }
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    completionHandler(.failure(error: error))
                    return
                }
                guard let data = data, let image = UIImage(data: data) else {
                    completionHandler(.failure(error: ImageCacheError.failedToDecodeImage))
                    return
                }
                DispatchQueue.main.async {
                    self.cache.setObject(image, forKey: url.absoluteString as NSString)
                    completionHandler(.success(result: image))
                }
            }.resume()
        }
    }
}
