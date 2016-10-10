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

protocol LocationManagerDelegate: NSObjectProtocol {
    func locationChanged(location: CLLocation?)
}

class LocationManager : NSObject {
    
    let locationManager = CLLocationManager()
    var bbox = AppConstants.standartBBOX
    
    internal var locationManagerDelegates = [LocationManagerDelegate?]()
    
    override init()
    {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func addDelegate(delegate: LocationManagerDelegate) {
        locationManagerDelegates.append(delegate)
    }
    
    func removeDelegate(delegate: LocationManagerDelegate) {
        for i in ( 0..<self.locationManagerDelegates.count){
            if (locationManagerDelegates[i]?.isEqual(delegate))! {
                locationManagerDelegates.remove(at: i)
                break;
            }
        }
    }
    
}

extension LocationManager : CLLocationManagerDelegate
{
    func location(status: CLAuthorizationStatus) -> CLLocation?
    {
        switch status {
        case .authorizedAlways,
             .authorizedWhenInUse:
            return locationManager.location
        default:
            print("Not Authorised")
            locationManager.requestWhenInUseAuthorization()
            return nil
        }
        
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for delegate in self.locationManagerDelegates {
            guard let delegate = delegate else {
                continue
            }
            delegate.locationChanged(location: self.location(status: CLLocationManager.authorizationStatus()))
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus)
    {
        for delegate in self.locationManagerDelegates {
            guard let delegate = delegate else {
                continue
            }
            delegate.locationChanged(location: self.location(status: CLLocationManager.authorizationStatus()))
        }
    }

}
