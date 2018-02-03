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
    
    //Buttons
    @IBOutlet weak var stopLocationButton: UIButton!
    @IBOutlet weak var getLocationButton: UIButton!
    
    //Labels
    @IBOutlet weak var placeLabel: UILabel!
    @IBOutlet weak var movingSpeedLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        
        self.title = "Locator"        

    }
    
    override func viewDidAppear(_ animated: Bool) {
    // Start Updating location here!!!
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        locationManager.locator.stopUpdatingLocation()
    }
    
    func locationUpdated(location: CLLocation, address : String) {
        print("location updated with lat: \(location.coordinate.latitude) and lon: \(location.coordinate.longitude)")
        print("address is \(address)")
    }


    @IBAction func getLocationAction(_ sender: Any)
    {
        locationManager.getLocation()
    }
    
    @IBAction func stopLocationAction(_ sender: Any)
    {
        locationManager.locator.stopUpdatingLocation()
    }
    
}

