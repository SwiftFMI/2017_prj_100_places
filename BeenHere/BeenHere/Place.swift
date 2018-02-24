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
    var key : String
    var info : String
    var latitude : Double
    var longitude : Double
    var rating : Double
    var visits : Int
    var visitors : Array<String>
    var ratings : Dictionary<String,Int>
    var imageNames : Array<String>
    var placeImages : Dictionary<String,Data>
    
    
    override init() {
        placeName = String.init()
        key = String.init()
        info = String.init()
        visitors = Array<String>()
        ratings = Dictionary<String,Int>()
        placeImages = Dictionary<String,Data>()
        imageNames = Array<String>()
        
        latitude = 0.0
        longitude = 0.0
        
        rating = 0.0
        visits = 0
        
        super.init()
    }
    override var description: String
    {
        return "Place: \(self.placeName), \(self.rating), \(self.visits), \(self.imageNames)"
    }
    
    func visit(user : String) -> Void {
        if (self.visitors.contains(user) == false)
        {
            self.visitors.append(user)
        }
    }
    
    func rate(username : String, rating : Int) -> Void {
        self.ratings[username] = rating
        self.rating = calculateRating()
    }
    
    func calculateRating() -> Double {
        if (ratings.count > 0)
        {
            var ratingsSum = 0
            let values = Array(ratings.values)
            
            for val in values
            {
                ratingsSum += val
            }
            return Double(ratingsSum)/Double(ratings.count)
        }
        return 0.0
    }
    
    
    
    class func placeFromDictionary(dictionary : Dictionary<String,Any>, key : String) -> Place {
        let newPlace : Place = Place.init()
        newPlace.placeName = dictionary["name"] as! String
        newPlace.info = dictionary["info"] as! String
        newPlace.rating = dictionary["rating"] as! Double
        newPlace.latitude = dictionary["lat"] as! Double
        newPlace.longitude = dictionary["lon"] as! Double
        newPlace.visits = dictionary["visits"] as! Int
        newPlace.key = key
        if dictionary["images"] != nil
        {
            newPlace.imageNames = dictionary["images"] as! Array<String>
        }
        if dictionary["visitors"] != nil
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
        dictPlace["key"] = place.key
        dictPlace["info"] = place.info
        dictPlace["rating"] = place.rating
        dictPlace["lat"] = place.latitude
        dictPlace["lon"] = place.longitude
        dictPlace["visits"] = place.visits
        dictPlace["visitors"] = place.visitors
        dictPlace["ratings"] = place.ratings
        dictPlace["images"] = place.imageNames
        
        return dictPlace
    }
    
    override func isEqual( _ object: Any?) -> Bool {
        if let object = object as? Place {
            return key.elementsEqual(object.key)
        } else {
            return false
        }
    }
    
    override var hash: Int {
        return key.hashValue
    }
}
