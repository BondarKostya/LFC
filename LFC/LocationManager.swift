//
//  LocationManager.swift
//  LFC
//
//  Created by mini on 10/3/16.
//  Copyright © 2016 bondar. All rights reserved.
//

import Foundation
import MapKit
import SDWebImage

protocol BBOXChangeDelegate {
    func bboxChanged(bbox: String)
}

class LFCLocationManager : NSObject {
    
    static let sharedInstance:LFCLocationManager = {
        let instance = LFCLocationManager()
        return instance
    }()
    let locationManager = CLLocationManager()
    var bbox = AppParameters.sharedInstance.standartBBOX
    
    var bboxDelegate:BBOXChangeDelegate?
    
    private override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
}

extension LFCLocationManager : CLLocationManagerDelegate
{
    func setupLocation()
    {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        if let locationBBOX = self.checkLocation(status: CLLocationManager.authorizationStatus())
        {
            self.bbox = locationBBOX
        }
    }
    func checkLocation(status: CLAuthorizationStatus) -> String?
    {
        
        switch status {
        case .authorizedAlways,
             .authorizedWhenInUse:
            guard let location = locationManager.location else
            {
                return nil
            }
            print(location.coordinate.longitude)
            print(location.coordinate.latitude)
            let centerCoord = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let region = MKCoordinateRegionMakeWithDistance(centerCoord, 1000, 1000)
            
            let latMin = region.center.latitude - 0.5 * region.span.latitudeDelta;
            let latMax = region.center.latitude + 0.5 * region.span.latitudeDelta;
            let lonMin = region.center.longitude - 0.5 * region.span.longitudeDelta;
            let lonMax = region.center.longitude + 0.5 * region.span.longitudeDelta;
            
            print("\(lonMin),\(latMin),\(lonMax),\(latMax)")
            return "\(lonMin),\(latMin),\(lonMax),\(latMax)"
        default:
            print("Not Authorised")
            locationManager.requestWhenInUseAuthorization()
            return nil
        }
        
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus)
    {
        if let locationBBOX = self.checkLocation(status: CLLocationManager.authorizationStatus())
        {
            self.bbox = locationBBOX
            guard let delegate = self.bboxDelegate else {
                return
            }
            delegate.bboxChanged(bbox: bbox)
        }
    }

}
