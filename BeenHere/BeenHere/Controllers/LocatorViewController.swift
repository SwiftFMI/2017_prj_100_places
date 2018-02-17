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
    
    @IBOutlet weak var locationActivityIndicator: UIActivityIndicatorView!
    //Buttons
    @IBOutlet weak var stopLocationButton: UIButton!
    @IBOutlet weak var getLocationButton: UIButton!
    
    //Radar like View
    @IBOutlet weak var radarView: MeterCircularView!
    //Labels
    @IBOutlet weak var placeLabel: UILabel!
    @IBOutlet weak var currentSpeedLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    
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
    
    //MARK: - LocationManagerDelegate methods
    func locationUpdated(location: CLLocation, address : String) {
        self.placeLabel.text = address
        self.locationActivityIndicator.startAnimating()
    }
    
    func locationUpdated(location: CLLocation, address: [String : String]) {
        self.locationActivityIndicator.startAnimating()
        self.placeLabel.text = address["address"]
        self.currentSpeedLabel.text = address["speed"]
    }

    func locationFailed() {
        self.locationActivityIndicator.stopAnimating()
        self.placeLabel.text = "Something went wrong"
    }

    //MARK: - ButtonActions

    @IBAction func getLocationAction(_ sender: Any) {
        self.radarView.rotate()
        locationManager.getLocation()
    }
    
    @IBAction func stopLocationAction(_ sender: Any) {
        self.radarView.stopRotating()

        self.locationActivityIndicator.stopAnimating()
        
        locationManager.locator.stopUpdatingLocation()
    }
    
}

