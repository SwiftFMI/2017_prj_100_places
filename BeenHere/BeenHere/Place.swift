//
//  Place.swift
//  BeenHere
//
//  Created by Petko Haydushki on 13.02.18.
//  Copyright © 2018 Petko Haydushki. All rights reserved.
//

import Foundation

class Place : NSObject
{
    var placeName : String
    var imgName : String
    var key : String
    var info : String
    var placeImageData : Data?
    var latitude : Double
    var longitude : Double
    var rating : Double
    var visits : Int
    var id : Int
    var visitors : Array<String>
    var ratings : Dictionary<String,Int>
    
    
    override init() {
        placeName = String.init()
        imgName = String.init()
        key = String.init()
        info = String.init()
        visitors = Array<String>()
        ratings = Dictionary<String,Int>()
        
        
        latitude = 0.0
        longitude = 0.0
        
        rating = 0.0
        visits = 0
        id = 0
        
        super.init()
    }
    override var description: String
    {
        return "Place: \(self.placeName), \(self.rating), \(self.visits), \(self.imgName)"
    }
    
    func visit() -> Void {
        self.visitors.append("Poseti me")
    }
    
    func rate(username : String, rating : Int) -> Void {
        self.ratings[username] = rating
    }
    
    class func placeFromDictionary(dictionary : Dictionary<String,Any>, key : String) -> Place {
        let newPlace : Place = Place.init()
        newPlace.placeName = dictionary["name"] as! String
        newPlace.imgName = dictionary["img"] as! String
        newPlace.info = dictionary["info"] as! String
        newPlace.rating = dictionary["rating"] as! Double
        newPlace.latitude = dictionary["lat"] as! Double
        newPlace.longitude = dictionary["lon"] as! Double
        newPlace.visits = dictionary["visits"] as! Int
        newPlace.id = dictionary["id"] as! Int
        newPlace.key = key
        
        if dictionary["ratings"] != nil
        {
            newPlace.visitors = dictionary["visitors"] as! Array<String>
        }
        if dictionary["ratings"] != nil
        {
            newPlace.ratings = dictionary["ratings"] as! Dictionary<String,Int>
        }
        return newPlace
    }
    
    class func dictionaryFromPlace(place : Place) -> Dictionary<String,Any> {
        
        var dictPlace : Dictionary = Dictionary<String,Any>()
        
        dictPlace["name"] = place.placeName
        dictPlace["img"] = place.imgName
        dictPlace["key"] = place.key
        dictPlace["info"] = place.info
        dictPlace["rating"] = place.rating
        dictPlace["lat"] = place.latitude
        dictPlace["lon"] = place.longitude
        dictPlace["visits"] = place.visits
        dictPlace["id"] = place.id
        dictPlace["visitors"] = place.visitors
        dictPlace["ratings"] = place.ratings
        
        return dictPlace
    }
}
