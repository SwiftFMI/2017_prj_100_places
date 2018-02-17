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

protocol PlacesDatasource: class
{
    func placesUpdated()
}

class Places: NSObject {
    
    var places : Array = Array<Place>()
 
    weak var delegate : PlacesDatasource?

    
    //MARK: - Database and Storage handlers

    func downloadImageFromStorage (name : String, storage : Storage)-> Void {
        
        let storageRef = storage.reference()
        
        
        self.getDataForImageName(name: name, storageRef: storageRef)
    }
    
    func getDataForImageName(name : String, storageRef : StorageReference) -> Void {
        
        let imageRef = storageRef.child(name)
        
        imageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                print(error.localizedDescription)
                print("Uh-oh, an error occurred! ")
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            } else {
                for item in self.places
                {
                    if (item.imgName.elementsEqual(name))
                    {
                        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                        let localURL = documentsURL.appendingPathComponent(name)
                        
                        do{
                            try data?.write(to: localURL, options: .atomicWrite)
                        }catch _ {
                            print("Unsuccessful write")
                        }
                        item.placeImageData = data!
                        break
                    }
                }
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
                self.delegate?.placesUpdated()
            }
        }
    }
    
    func downloadDatabasePlacesData() -> Void {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true

        Database.database().isPersistenceEnabled = false

        var ref: DatabaseReference!
        ref = Database.database().reference()
        
        ref.child("Places").observe(.childAdded) { (snapshot) in
            let child = snapshot.value as! Dictionary<String,Any>
            if  child.count == 11
            {
                let newPlace = Place.placeFromDictionary(dictionary: child,key: snapshot.key)
                
                let fileManager = FileManager.default
                let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
                let localURL = documentsURL.appendingPathComponent("\(child["img"] ?? "default")")
                var isDir: ObjCBool = false
                if fileManager.fileExists(atPath: localURL.path, isDirectory: &isDir)
                {
                    newPlace.placeImageData = fileManager.contents(atPath: localURL.path)
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
                else
                {
                    let storage = Storage.storage()
                    self.downloadImageFromStorage(name: "\(child["img"] ?? "default")", storage: storage)
                }
               
                self.places.insert(newPlace, at: self.places.count)
            }
            self.delegate?.placesUpdated()
        }
        ref.child("Places").observe(.childChanged) { (snapshot) in
            let child = snapshot.value as! Dictionary<String,Any>
           
            let newPlace = Place.placeFromDictionary(dictionary: child,key: snapshot.key)
            
            for i in 0...self.places.count-1
            {
                if (self.places[i].id == newPlace.id)
                {
                    self.places[i] = newPlace
                    break;
                }
            }
            let storage = Storage.storage()
            self.downloadImageFromStorage(name: "\(child["img"] ?? "default")", storage: storage)
            
            self.delegate?.placesUpdated()
        }
    }
}


//let fileManager = FileManager.default
//let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//let localURL = documentsURL.appendingPathComponent(name)
//var isDir: ObjCBool = false
//if fileManager.fileExists(atPath: localURL.path, isDirectory: &isDir)
//{
//    item.placeImageData = fileManager.contents(atPath: localURL.path)
//}
//else
//{
//    do{
//        try data?.write(to: localURL, options: .atomicWrite)
//    }catch _ {
//
//    }
//    item.placeImageData = data!
//}

