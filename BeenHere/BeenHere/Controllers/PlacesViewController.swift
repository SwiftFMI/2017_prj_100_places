//
//  FirstViewController.swift
//  BeenHere
//
//  Created by Petko Haydushki on 15.12.17.
//  Copyright © 2017 Petko Haydushki. All rights reserved.
//

import UIKit
import Firebase
import StoreKit

import FirebaseAuthUI
import FirebaseGoogleAuthUI
import FirebaseFacebookAuthUI


class PlacesViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,PlacesDatasource,FUIAuthDelegate {
    
    func placesUpdated()
    {
        if (showOnlyVisited == true)
        {
            places = placesDataSource.visitedPlaces()
        }
        else
        {
            places = placesDataSource.places
        }
        UIView.animate(withDuration: 0.2) {
            self.placesTableView.alpha = 1.0
        }
        
        loadingIndicator.stopAnimating()
        
        self.placesTableView.reloadData()
    }
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    var placesDataSource : Places = Places.sharedInstance
    var places = Array<Place>()

    var showOnlyVisited : Bool = false
    
    @IBOutlet weak var placesTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        placesTableView.alpha = 0.0
        loadingIndicator.startAnimating()
        
        
        print("viewDidLoad")
//        if (Auth.auth().currentUser == nil)
//        {
//            Auth.auth().signInAnonymously() { (user, error) in
//                // ...
//            }
//        }
        if (showOnlyVisited == true)
        {
            places = placesDataSource.visitedPlaces()
        }
        else
        {
            places = placesDataSource.places
        }
        
        self.title = "Places"
        placesDataSource.delegate = self
        self.placesDataSource.downloadDatabasePlacesData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        print("User \(Auth.auth().currentUser?.uid ?? "User UID nil")")
        print("User \(Auth.auth().currentUser?.displayName ?? "User displayName nil")")
        
        let providers: [FUIAuthProvider] = [
            FUIGoogleAuth(),
            FUIFacebookAuth(),
            ]
        
        // Auth Here
        let authUI = FUIAuth.defaultAuthUI()
        // You need to adopt a FUIAuthDelegate protocol to receive callback
        authUI?.providers = providers
        authUI?.delegate = self as FUIAuthDelegate
        
        if ((Auth.auth().currentUser?.displayName) == nil)
        {
            let authUI = FUIAuth.defaultAuthUI()
            let authViewController = authUI?.authViewController()
//            self.present(authViewController!, animated: true, completion: nil)
        }
    }
    
    //MARK: - TableView Methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: false)
        print("\(places.description)");
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "placeCell", for: indexPath) as! PlaceTableViewCell

        let place : Place = places[indexPath.row]
        let firstImage : String = place.imageNames[0]
        cell.placeNameLabel.text = place.placeName

        cell.ratingView.rating = place.rating
        
        if let placeData = place.placeImages[firstImage]
        {
            cell.dowloadingImageIndicator.stopAnimating()
            cell.placeImageView.image = UIImage(data: placeData)
        }
        return cell;
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if  let destination = segue.destination as? PlaceDetailViewController,
            let index = placesTableView.indexPathForSelectedRow?.row
        {
            print("\(places[index].description)");
            destination.detailPlace = places[index]
            
            for image in places[index].imageNames
            {
                if let data = Places.sharedInstance.imageExistsForName(name: image)
                {
                    if (destination.detailPlace.placeImages[image] == nil)
                    {
                        destination.detailPlace.placeImages[image] = data
                    }
                }
                else
                {
                    Places.sharedInstance.getPlacesDataForPlace(place: places[index])
                }
            }
        }
    }
}
//https://firebasestorage.googleapiself.com/v0/b/beenhere-ph.appspot.com/o/krushuna.jpg?alt=media&token=c7e39688-bfe9-4b9b-9b4c-32e8d8cf91cb

