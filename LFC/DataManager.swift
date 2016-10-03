//
//  DataManager.swift
//  LFC
//
//  Created by Admin on 22.09.16.
//  Copyright © 2016 bondar. All rights reserved.
//

import UIKit
import FlickrKit

class DataManager: NSObject {

    static let sharedInstance:DataManager = {
        let instance = DataManager()
        return instance
    }()
    
    private override init()
    {
        
    }
    
    func loadPhotosFromFlickr(withLimit limit:Int, page:Int, bbox:String,searchText:String,callback: @escaping ([Photo]) -> Void)
    {
        let flickr = FKFlickrPhotosSearch()
        flickr.per_page = "\(limit)"
        flickr.page = "\(page)"
        flickr.bbox = bbox
        flickr.text = searchText
        FlickrKit.shared().call(flickr) { (response, error) in
            DispatchQueue.main.async {
                if (response != nil) {
                    var photos = [Photo]()
                    let topPhotos = response?["photos"] as! [String: AnyObject]
                    let photoArray = topPhotos["photo"] as! [[String: AnyObject]]
                    for photoDictionary in photoArray {
                        let photoURLThumbnail = FlickrKit.shared().photoURL(for: FKPhotoSizeThumbnail100, fromPhotoDictionary: photoDictionary)
                        let photoURLOriginal = FlickrKit.shared().photoURL(for: FKPhotoSizeLarge1024, fromPhotoDictionary: photoDictionary)
                        if(Photo.validateInfo(photoDictionary: photoDictionary))
                        {
                            let photo = Photo(photoDictionary: photoDictionary, photoURLThumbnail: photoURLThumbnail!, photoURLOriginal: photoURLOriginal!)
                            photos.append(photo)
                        }
                    }
                    callback(photos)
                }
            }
        }

    }
}
