//
//  SecondViewController.swift
//  BeenHere
//
//  Created by Petko Haydushki on 15.12.17.
//  Copyright © 2017 Petko Haydushki. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class LocatorViewController: UIViewController, LocationManagerDelegate {

    

    var locationManager : LocationManager = LocationManager.init()
    
    //Buttons
    @IBOutlet weak var stopLocationButton: UIButton!
    @IBOutlet weak var getLocationButton: UIButton!
    
    //Radar like View
    @IBOutlet weak var radarView: MeterCircularView!
    //Labels
    @IBOutlet weak var placeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        locationManager.delegate = self
        let dist = locationManager.distanceBetween(point1:CGPoint(x: 42.7, y: 23.33) ,point2: CGPoint(x: 42.14, y: 24.74))
        print("distance \(dist)")
        self.title = "Locator"        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.getLocationButton.layer.cornerRadius = self.getLocationButton.frame.size.height/2.0
        self.getLocationButton.layer.masksToBounds = true
        self.stopLocationButton.layer.cornerRadius = self.stopLocationButton.frame.size.height/2.0
        self.stopLocationButton.layer.masksToBounds = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
    // Start Updating location here!!!
        self.placeLabel.text = ""
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        locationManager.locator.stopUpdatingLocation()
    }
    
    //MARK: - LocationManagerDelegate methods
    func locationUpdated(location: CLLocation, address: [String : String]) {
        self.placeLabel.text = address["address"]
        
        if (radarView.mapView.annotations.count <= 1)
        {
            radarView.mapView.addAnnotations(Places.PlacesLocations())
        }
        let currentLocatonPoint = CGPoint(x: location.coordinate.latitude, y: location.coordinate.longitude)
        
        var minDistance = 1000000.0
        for place in Places.sharedInstance.places
        {
            let p = CGPoint(x: place.latitude,y: place.longitude)
            let distance = locationManager.distanceBetween(point1: p, point2: currentLocatonPoint)
            print("Разстоянието до \(place.placeName) e \(distance)")
            if (distance < minDistance)
            {
                minDistance = distance
            }
            if (distance < 500.0)
            {
                self.placeLabel.text = "Намирате се на \(Int(distance)) метра от \(place.placeName). \r Доближете се още \(Int(distance - 100.0)) метра за да посетите!"
                if(Places.visit(place: place) == true && distance < 100.0)
                {
                    self.placeLabel.text = "Посетихте \(place.placeName)!"
                    self.radarView.stopRotating()
                    locationManager.locator.stopUpdatingLocation()
                    showVisitedAlert(place: place)
                }
            }
        }
        
        let region = MKCoordinateRegionMakeWithDistance(location.coordinate, minDistance * 5.2, minDistance * 5.2)
        radarView.mapView.setRegion(region, animated: true)
    }
    
    func showVisitedAlert(place : Place) -> Void {
        
        let alert = UIAlertController(title: "BeenHere", message: "Congratulations! You have visited \(place.placeName)!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .`default`, handler: { _ in
            NSLog("The \"OK\" alert occured.")
        }))
        self.present(alert, animated: true, completion: nil)
    }

    func locationFailed() {
        
        
        self.radarView.stopRotating()
        self.placeLabel.text = "Something went wrong"
    }
    
    func startLocationUpdates() {
        self.radarView.rotate()
        locationManager.getLocation()
    }

    //MARK: - ButtonActions

    @IBAction func getLocationAction(_ sender: Any) {
        self.radarView.rotate()
        locationManager.getLocation()
    }
    
    @IBAction func stopLocationAction(_ sender: Any) {
        self.radarView.stopRotating()
        locationManager.locator.stopUpdatingLocation()
    }
    
}

