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

class PlacesViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,PlacesDatasource {
    
    func placesUpdated() {
        self.placesTableView.reloadData()
    }
    
    var placesDataSource : Places = Places()
    
    @IBOutlet weak var placesTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("viewDidLoad")
        if (Auth.auth().currentUser == nil)
        {
            Auth.auth().signInAnonymously() { (user, error) in
                // ...
            }
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
        
        print("User \(Auth.auth().currentUser?.displayName ?? "User displayName nil")")
    }
    
    
    //MARK: - TableView Methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: false)
        
        
        print("\(placesDataSource.places[indexPath.row].description)");
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return placesDataSource.places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "placeCell", for: indexPath) as! PlaceTableViewCell
        
        
        cell.placeNameLabel.text = placesDataSource.places[indexPath.row].placeName
        if let placeData = placesDataSource.places[indexPath.row].placeImageData
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
            print("\(placesDataSource.places[index].description)");
            destination.detailPlace = placesDataSource.places[index]
        }
    }
    

}
//https://firebasestorage.googleapiself.com/v0/b/beenhere-ph.appspot.com/o/krushuna.jpg?alt=media&token=c7e39688-bfe9-4b9b-9b4c-32e8d8cf91cb

