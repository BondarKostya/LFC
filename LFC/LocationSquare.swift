//
//  LocationSquare.swift
//  LFC
//
//  Created by mini on 10/10/16.
//  Copyright © 2016 bondar. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit
struct LocationSquare {
    static func calculateLocationSquare(location:CLLocation, rangeInMeters: Double) -> String {
        
        let centerCoord = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegionMakeWithDistance(centerCoord, rangeInMeters, rangeInMeters)
        
        let latMin = region.center.latitude - 0.5 * region.span.latitudeDelta;
        let latMax = region.center.latitude + 0.5 * region.span.latitudeDelta;
        let lonMin = region.center.longitude - 0.5 * region.span.longitudeDelta;
        let lonMax = region.center.longitude + 0.5 * region.span.longitudeDelta;
        
        return "\(lonMin),\(latMin),\(lonMax),\(latMax)"
    }
}
