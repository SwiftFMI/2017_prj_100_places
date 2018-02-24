//
//  Places.swift
//  BeenHere
//
//  Created by Petko Haydushki on 15.02.18.
//  Copyright © 2018 Petko Haydushki. All rights reserved.
//

import Foundation
import Firebase
import StoreKit
import MapKit

protocol PlacesDatasource: class
{
    func placesUpdated()
}

class Places: NSObject {
    
    var places : Array = Array<Place>()
    
    weak var delegate : PlacesDatasource?
    
    
    static let sharedInstance = Places()
    
    // MARK: - Initialization Method
    
    private override init() {
        super.init()
    }
    
    
    //MARK: - Database and Storage handlers
    
    func downloadImageFromStorage (place : Place, storage : Storage)-> Void {
        
        let storageRef = storage.reference()
        self.getDataForImageName(place: place, storageRef: storageRef)
    }
    
    func getDataForImageName(place : Place, storageRef : StorageReference) -> Void {
        
        let name = place.imageNames.first
        let imageRef = storageRef.child(name!)
        
        imageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error
            {
                print(error.localizedDescription)
                print("Uh-oh, an error occurred! ")
            }
            else
            {
                if (place.placeImages[name!] == nil)
                {
                    place.placeImages[name!] = data!
                    self.writeImageDataToFile(imgName: name!, data: data!)
                }
            }
        }
        self.delegate?.placesUpdated()
    }
    
    func writeImageDataToFile(imgName : String, data : Data?) -> Void {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let localURL = documentsURL.appendingPathComponent(imgName)
        
        do{
            try data?.write(to: localURL, options: .atomicWrite)
            delegate?.placesUpdated()
        }catch _ {
            print("Unsuccessful write")
        }
    }
    
    func readImageDataFromUrl(url : URL) -> Void {
        
    }
    
    func imageExistsForName(name : String) -> Data? {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let localURL = documentsURL.appendingPathComponent("\(name)")
        var isDir: ObjCBool = false
        if fileManager.fileExists(atPath: localURL.path, isDirectory: &isDir)
        {
            return fileManager.contents(atPath: localURL.path)!
        }
        return nil
    }
    
    func getPlacesDataForPlace(place : Place) -> Void {

        let storage = Storage.storage()
        let storageRef = storage.reference()

        for name in place.imageNames
        {
            let imageRef = storageRef.child(name)
            
            imageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
                if let error = error {
                    print(error.localizedDescription)
                    print("Uh-oh, an error occurred! ")
                } else {
                    for item in self.places
                    {
                        if (item.key.elementsEqual(place.key))
                        {
                            if (item.placeImages[name] == nil)
                            {
                                item.placeImages[name] = data!
                                self.writeImageDataToFile(imgName: name, data: data)
                                self.delegate?.placesUpdated()
                            }
                            break
                        }
                    }
                    self.delegate?.placesUpdated()
                    NotificationCenter.default.post(Notification(name: Notification.Name("ReloadData")))
                }
            }
        }
    }
    
    
    
    func downloadDatabasePlacesData() -> Void {
        let storage = Storage.storage()
        
        var ref: DatabaseReference!
        ref = Database.database().reference()
        
        ref.child("Places").observe(.childAdded) { (snapshot) in
            
            let child = snapshot.value as! Dictionary<String,Any>
            let images = child["images"] as! Array<String>
            let newPlace = Place.placeFromDictionary(dictionary: child,key: snapshot.key)
            if let data = self.imageExistsForName(name: images[0])
            {
                newPlace.placeImages[images[0]] = data
            }
            else
            {
                self.downloadImageFromStorage(place: newPlace, storage: storage)
            }
            if self.places.contains(newPlace) == false
            {
                self.places.insert(newPlace, at: self.places.count)
            }
            self.delegate?.placesUpdated()
        }
        ref.child("Places").observe(.childChanged) { (snapshot) in
            let child = snapshot.value as! Dictionary<String,Any>

            let newPlace = Place.placeFromDictionary(dictionary: child,key: snapshot.key)
            
            for i in 0...self.places.count-1
            {
                if (self.places[i].key == newPlace.key)
                {
                    self.places[i] = newPlace
                    break;
                }
            }
            let storage = Storage.storage()
            self.downloadImageFromStorage(place: newPlace, storage: storage)
            
            self.delegate?.placesUpdated()
        }
    }
    
    
    //MARK: - Rate/Visit Methods
    class func visit(place : Place) -> Bool {
  
        var username : String;
        if (Auth.auth().currentUser != nil)
        {
            username = (Auth.auth().currentUser?.uid)!
        }
        else
        {
            username = "Anonymous\(place.visitors.count + 1)"
        }
        if (place.visitors.contains(username) == false)
        {
            var ref: DatabaseReference!
            ref = Database.database().reference()
    
            place.visit(user : username)
        
            ref.child("Places/\(place.key)").updateChildValues(Place.dictionaryFromPlace(place: place))
            
            return true
        }
        return false
    }
    
    func visitedPlaces() -> Array<Place> {
        var visitedPlaces = Array<Place>()
        
        for place in places
        {
            if place.visitors.contains((Auth.auth().currentUser?.uid)!) && visitedPlaces.contains(place) == false
            {
                visitedPlaces.append(place)
            }
        }
        return visitedPlaces
    }
    
    class func rate(place : Place, rating : Int) -> Void {
        var ref: DatabaseReference!
        ref = Database.database().reference()
        
        var username : String;
        if (Auth.auth().currentUser != nil)
        {
            username = (Auth.auth().currentUser?.uid)!
        }
        else
        {
            username = "\(place.ratings.count + 1)"
        }
        place.rate(username: username, rating: rating)
        
        ref.child("Places/\(place.key)").updateChildValues(Place.dictionaryFromPlace(place: place))
    }
    
    class PlaceLocation: NSObject, MKAnnotation
    {
        var identifier = "place location"
        var title: String?
        var coordinate: CLLocationCoordinate2D
        init(name:String,lat:CLLocationDegrees,long:CLLocationDegrees){
            title = name
            coordinate = CLLocationCoordinate2DMake(lat, long)
        }
    }
    
    class func PlacesLocations() -> Array<PlaceLocation> {
        var placeLocations = Array<PlaceLocation>()
        
        for place in Places.sharedInstance.places
        {
            placeLocations.append(PlaceLocation.init(name: place.placeName, lat: place.latitude, long: place.longitude))
        }
        return placeLocations
    }
}

