//
//  PlaceDetailViewController.swift
//  BeenHere
//
//  Created by Petko Haydushki on 4.02.18.
//  Copyright © 2018 Petko Haydushki. All rights reserved.
//

import UIKit

import Firebase

class PlaceDetailViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var placeImagesCollectionView: UICollectionView!
    
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var visitsCountLabel: UILabel!
    @IBOutlet weak var infoTextView: UITextView!
    var detailPlace : Place = Place.init()

    @IBOutlet weak var starRatingCosmosView: CosmosView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = detailPlace.placeName.capitalized
        self.infoTextView.text = detailPlace.info
        
        self.visitsCountLabel.text = "\(detailPlace.visitors.count)"
        self.starRatingCosmosView.rating = calculateRating()
        self.ratingLabel.text = "\(calculateRating())"
        
        self.placeImagesCollectionView.delegate = self
        self.placeImagesCollectionView.dataSource = self
        // Do any additional setup after loading the view.
        
        self.starRatingCosmosView.didTouchCosmos = didTouchCosmos(_:)
        self.starRatingCosmosView.didFinishTouchingCosmos = didFinishTouchingCosmos(_:)
        
        visit()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "detailPlaceCell", for: indexPath) as! PlaceDetailCollectionViewCell
        
        if let placeData = detailPlace.placeImageData
        {
            
            cell.image.image = UIImage(data: placeData)
        }
        return cell;
    }

    func visit() -> Void {
        var ref: DatabaseReference!
        ref = Database.database().reference()

        ref.child("Places").child(detailPlace.key).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            print(value ?? "Dictionary Problem")
            
            // ...
        }) { (error) in
            print(error.localizedDescription)
        }
        if (detailPlace.visitors.contains("Poseti me") == false)
        {
            detailPlace.visit()
        }
        ref.child("Places/\(detailPlace.key)").updateChildValues(Place.dictionaryFromPlace(place: detailPlace))
        
    }
    func rate(rating : Int) -> Void {
        var ref: DatabaseReference!
        ref = Database.database().reference()
        
        ref.child("Places").child(detailPlace.key).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            
            print(value ?? "Dictionary Problem")
            // ...
        }) { (error) in
            print(error.localizedDescription)
        }
        var username : String;
        if (Auth.auth().currentUser != nil)
        {
            username = (Auth.auth().currentUser?.uid)!
        }
        else
        {
            username = "\(detailPlace.ratings.count + 1)"
        }
        detailPlace.rate(username: username, rating: rating)

        
        ref.child("Places/\(detailPlace.key)").updateChildValues(Place.dictionaryFromPlace(place: detailPlace))
        
        self.ratingLabel.text = "\(calculateRating())"
    }
    
    func calculateRating() -> Double {

        if (detailPlace.ratings.count > 0)
        {
            var ratingsSum = 0
            let values = Array( detailPlace.ratings.values)
            
            for val in values
            {
                ratingsSum += val
            }
            return Double(ratingsSum/detailPlace.ratings.count)
        }
        return 0.0
    }
    
    private func didTouchCosmos(_ rating: Double) {
        print("didTouchCosmos")
    }
    
    private func didFinishTouchingCosmos(_ rating: Double) {
        print("didFinishTouchingCosmos")
        self.rate(rating: Int(rating))
    }

}
