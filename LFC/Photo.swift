//
//  Photo.swift
//  LFC
//
//  Created by Admin on 23.09.16.
//  Copyright © 2016 bondar. All rights reserved.
//

import Foundation
import UIKit


class Photo
{
    var photoTitle = ""
    var photoURLThumbnail: URL?
    var photoURLOriginal: URL?
    var photoId = ""
    var photoImageThumbnail: UIImage?
    var photoImageOriginal: UIImage?
    
    init(photoDictionary : Dictionary<String,AnyObject>, photoURLThumbnail : URL, photoURLOriginal : URL)
    {
        self.photoTitle = photoDictionary["title"] as! String
        self.photoId = photoDictionary["id"] as! String
        
        self.photoURLThumbnail = photoURLThumbnail
        self.photoURLOriginal = photoURLOriginal

    }
    
    static func validateInfo(photoDictionary : Dictionary<String,AnyObject>) -> Bool
    {
        let photoTitle = photoDictionary["title"] as? String
        let photoId = photoDictionary["id"] as? String
        
        if (photoId != nil) && (photoTitle != nil)
        {
            return true
        }else
        {
            return false
        }

    }
}
