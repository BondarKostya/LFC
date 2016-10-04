//
//  DataManager.swift
//  LFC
//
//  Created by Admin on 22.09.16.
//  Copyright © 2016 bondar. All rights reserved.
//

import UIKit
import FlickrKit

enum LoadType {
    case ByText(limit:Int,page:Int,searchText:String)
    case ByPosition(limit:Int,page:Int,bbox:String)
    
    func parameters() -> [String:String?]
    {
        var dictionary = [String : String?]()
        switch(self)
        {
        case .ByPosition(let limit,let page,let bbox) :
            dictionary["limit"] = "\(limit)"
            dictionary["page"] = "\(page)"
            dictionary["bbox"] = bbox
        case .ByText(let limit,let page,let searchText) :
            dictionary["limit"] = "\(limit)"
            dictionary["page"] = "\(page)"
            dictionary["text"] = searchText
        }
        return dictionary
    }
    
}

class DataManager: NSObject {
    
    static let sharedInstance:DataManager = {
        let instance = DataManager()
        return instance
    }()
    
    private override init()
    {
        
    }
    
    func loadPhotosFromFlickr(loadType:LoadType,callback: @escaping ([Photo]) -> Void)
    {
        let flickr = FKFlickrPhotosSearch()
        let parameters = loadType.parameters()
        flickr.per_page = parameters["limit"] ?? ""
        flickr.page = parameters["page"] ?? ""
        flickr.text = parameters["text"] ?? ""
        flickr.bbox = parameters["bbox"] ?? ""
        FlickrKit.shared().call(flickr) { (response, error) in
            DispatchQueue.main.async {
                if(error != nil)
                { 
                    guard let err = error as? NSError else
                    {
                        return
                    }
                    let notificationName = Notification.Name("ErrorHandler")
                    NotificationCenter.default.post(name: notificationName, object: err)
                }
                if (response != nil)
                {
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
