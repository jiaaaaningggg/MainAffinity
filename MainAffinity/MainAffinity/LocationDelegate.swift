//
//  LocationDelegate.swift
//  MainAffinity
//
//  Created by Mahshukurrahman on 5/2/22.
//

import Foundation
import CoreLocation
class LocationDelegate : NSObject, CLLocationManagerDelegate{
    var locationCallback:((CLLocation) -> ())? = nil
    func locationManager(_ manager: CLLocationManager,
                             didUpdateLocations locations: [CLLocation])
        {
            guard let currentLocation = locations.last else { return }
            locationCallback?(currentLocation)
        }
    
}
