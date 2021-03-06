//
//  LocationManager.swift
//  BeenHere
//
//  Created by Petko Haydushki on 1.02.18.
//  Copyright © 2018 Petko Haydushki. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

protocol LocationManagerDelegate: class {
    
    func locationUpdated( location : CLLocation, address : [String: String])
    func locationFailed()
    func startLocationUpdates()
}

class LocationManager: NSObject,CLLocationManagerDelegate {
    
    var locator : CLLocationManager
    weak var delegate : LocationManagerDelegate?
    
    override init() {
        
        locator = CLLocationManager.init()
        
        super.init()
        locator.delegate = self
        locator.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }
    
    
    
    func getLocation() -> Void
    {
        checkPermission()
    }
    
    func checkPermission() -> Void
    {
        let authStatus = CLLocationManager.authorizationStatus()
        
        
        switch authStatus {
        case .denied:
            print("LocationManager::Access Denied")
        case .authorizedWhenInUse:
            self.locator.startUpdatingLocation()
        case .notDetermined:
            self.locator.requestWhenInUseAuthorization()
        default:
            print("LocationManager::def")
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if (status == CLAuthorizationStatus.authorizedWhenInUse)
        {
            delegate?.startLocationUpdates()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        delegate?.locationFailed()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let newLocation = locations.last
        
        if let locationAccuracy = newLocation?.horizontalAccuracy ,locationAccuracy < 1500.0
        {
            reverseGeocode(location: newLocation!)
        }
    }
    
    func reverseGeocode(location : CLLocation) -> Void {
        let geocoder : CLGeocoder = CLGeocoder.init()
        
        geocoder.reverseGeocodeLocation(location) { (placemarks, err) in
            
            if (err != nil)
            {
                self.delegate?.locationUpdated(location: location, address: ["":""])
            }
            else
            {
                if let pc = placemarks?.count, pc > 0
                {
                    let  placemark = placemarks![0]
                    let addressDictionaryComponents = placemark.addressDictionary!["FormattedAddressLines"] as! NSArray
                    
                    let address = addressDictionaryComponents.componentsJoined(by:", ")
                    //                addresDesc?.append("\(location.speed * 3.6)")
//                    self.delegate?.locationUpdated(location: location, address: address)
                    self.delegate?.locationUpdated(location: location, address: ["address":address, "speed":"\(location.speed*3.6)"])
                    print("\(address)")
                }
            }            
        }
    }
    
    
    func distanceBetween(point1 : CGPoint, point2 : CGPoint) -> Double {
        
        let location1 = CLLocation(latitude: Double(point1.x), longitude: Double(point1.y))
        let location2 = CLLocation(latitude: Double(point2.x), longitude: Double(point2.y))
        let distance : CLLocationDistance = location1.distance(from: location2)
        
        return distance
    }
    
}

