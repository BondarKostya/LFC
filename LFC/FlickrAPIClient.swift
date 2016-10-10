//
//  DataManager.swift
//  LFC
//
//  Created by Admin on 22.09.16.
//  Copyright © 2016 bondar. All rights reserved.
//

import UIKit
import FlickrKit

class FlickrAPIClient {
    
    enum SearchParameters {
        case textSearch(limit: Int,page: Int, searchText: String)
        case positionSearch(limit: Int, page: Int, bbox: String)
        
        func setupSearch() ->  FKFlickrPhotosSearch
        {
            let flickrSearch = FKFlickrPhotosSearch()
            switch(self)
            {
            case .positionSearch(let limit, let page, let bbox) :
                flickrSearch.per_page = "\(limit)"
                flickrSearch.page = "\(page)"
                flickrSearch.bbox  = bbox
            case .textSearch(let limit, let page, let searchText) :
                flickrSearch.per_page = "\(limit)"
                flickrSearch.page = "\(page)"
                flickrSearch.text = searchText
                flickrSearch.bbox = AppConstants.standartBBOX
            }
            return flickrSearch
        }
        
    }
    
    static let sharedInstance = FlickrAPIClient()
    
    private init()
    {
        
    }
    
    func searchPhotos(withParameters searchParameters: SearchParameters, callback : @escaping ([Photo],Error?) -> Void) {
        let flickr = searchParameters.setupSearch()
        FlickrKit.shared().call(flickr) { (response, error) in
            DispatchQueue.main.async {
                if(error != nil)
                { 
                    guard let error = error as? NSError else
                    {
                        return
                    }
                    callback([],error)
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
                    callback(photos,nil)
                }
                
            }
        }
        
    }
    
    
}
