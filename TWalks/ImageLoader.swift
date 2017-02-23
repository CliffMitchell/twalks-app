//
//  ImageLoader.swift
//  TWalks
//
//  Created by Cliff Mitchell on 04/12/2015.
//  Copyright © 2015 Cliff Mitchell. All rights reserved.
//

import UIKit

class ImageLoader: NSObject {
    
    var cache = NSCache<NSString, AnyObject>()
    
    class var sharedLoader : ImageLoader {
        struct Static {
            static let instance : ImageLoader = ImageLoader()
        }
        return Static.instance
    }
    
    func imageForUrl(_ urlString: String, completionHandler:@escaping (_ image: UIImage?, _ url: String) -> ()) {
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.background).async(execute: {()in
            var data: Data? = self.cache.object(forKey: urlString as NSString) as? Data
            
            if let goodData = data {
                
                let image = UIImage(data: goodData)
                DispatchQueue.main.async(execute: {() in
                    completionHandler(image, urlString)
                })
                return
            }
            
            var downloadTask: URLSessionDataTask = URLSession.shared.dataTask(with: URL(string: urlString)!, completionHandler: {(data: Data?, response: URLResponse?, error: NSError?) -> Void in
                if (error != nil) {
                    completionHandler(nil, urlString)
                    return
                }
                
                if data != nil {
                    let image = UIImage(data: data!)
                    self.cache.setObject(data!, forKey: urlString)
                    DispatchQueue.main.async(execute: {() in
                        completionHandler(image, urlString)
                    })
                    return
                }
                
            } as! (Data?, URLResponse?, Error?) -> Void)
            downloadTask.resume()
        })
        
    }
    
    
    
    
    

}
