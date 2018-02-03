//
//  SecondViewController.swift
//  BeenHere
//
//  Created by Petko Haydushki on 15.12.17.
//  Copyright © 2017 Petko Haydushki. All rights reserved.
//

import UIKit
import CoreLocation

class LocatorViewController: UIViewController, LocationManagerDelegate {

    var locationManager : LocationManager = LocationManager.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = LocationManager.init()
        locationManager.delegate = self
        
        self.title = "Locator"        

        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        locationManager.getLocation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        locationManager.locator.stopUpdatingLocation()
    }
    
    func locationUpdated(location: CLLocation, address : String) {
        print("location updated with lat: \(location.coordinate.latitude) and lon: \(location.coordinate.longitude)")
        print("address is \(address)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

