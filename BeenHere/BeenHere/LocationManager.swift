//
//  LocationManager.swift
//  BeenHere
//
//  Created by Petko Haydushki on 1.02.18.
//  Copyright © 2018 Petko Haydushki. All rights reserved.
//

import Foundation

import CoreLocation

protocol LocationManagerDelegate: class {
    func locationUpdated( location : CLLocation, address : String)
}

class LocationManager: NSObject,CLLocationManagerDelegate {
    var locator : CLLocationManager;
    weak var delegate : LocationManagerDelegate?
    
    override init() {        
        locator = CLLocationManager.init()
        
        super.init()
        locator.delegate = self
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
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        
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
            self.delegate?.locationUpdated(location: location, address: "")
        }
        else
        {
            if let pc = placemarks?.count, pc > 0
            {
                let  placemark = placemarks![0]
                let addresDesc = placemark.addressDictionary?.description
                
                self.delegate?.locationUpdated(location: location, address: addresDesc!)
                print("\(addresDesc)")
            }
        }
        
    }
}
}

/*
 - (void)reverseGeocode:(CLLocation *)location
 {
 CLGeocoder *geocoder = [[CLGeocoder alloc] init];
 
 [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
 
 NSString *labelText;
 if (error)
 {
 labelText = MISSING_ADDRESS_TEXT;
 [[HistoryManager sharedManager] saveData];
 [[WatchDelegate sharedInstance] updateApplicationContext];
 }
 else
 {
 CLPlacemark *placemark = [placemarks lastObject];
 labelText = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
 
 if ([labelText isEqualToString:@""])
 {
 labelText = MISSING_ADDRESS_TEXT;
 }
 [[HistoryManager sharedManager] updateHistory:self.myCurrentHistory withAddress:labelText andLocale:[[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0]];
 [[HistoryManager sharedManager] saveData];
 [[WatchDelegate sharedInstance] updateApplicationContext];
 }
 }];
 }
 
 - (void)checkLocationPermission
 {
 CLAuthorizationStatus authStatus = [CLLocationManager authorizationStatus];
 if (authStatus == kCLAuthorizationStatusNotDetermined)
 {
 if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
 {
 [locationManager requestWhenInUseAuthorization];
 locationPreferenceRequested = YES;
 }
 }
 }
 
 - (BOOL)locationWhenInUseAuthorized
 {
 CLAuthorizationStatus authStatus = [CLLocationManager authorizationStatus];
 if (authStatus == kCLAuthorizationStatusAuthorizedWhenInUse)
 return YES;
 
 return NO;
 }
 
 + (BOOL)locationStatusDetermined
 {
 CLAuthorizationStatus authStatus = [CLLocationManager authorizationStatus];
 if (authStatus == kCLAuthorizationStatusNotDetermined)
 return NO;
 
 return YES;
 }
 
 @end
 */

