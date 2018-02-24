//
//  PlaceDetailViewController.swift
//  BeenHere
//
//  Created by Petko Haydushki on 4.02.18.
//  Copyright © 2018 Petko Haydushki. All rights reserved.
//

import UIKit

import Firebase

class PlaceDetailViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource,UITableViewDataSource,UITableViewDelegate {
    
    @objc func placesUpdated() {
        placeImagesCollectionView.reloadData()
    }
    
    //MARK: - Outlets
    @IBOutlet weak var placeImagesCollectionView: UICollectionView!
    @IBOutlet weak var detailTableView: UITableView!
    @IBOutlet weak var starRatingCosmosView: CosmosView!
    
    var detailPlace : Place = Place.init()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = detailPlace.placeName.capitalized
        self.starRatingCosmosView.rating = detailPlace.rating

        NotificationCenter.default.addObserver(self, selector: #selector(placesUpdated), name: Notification.Name("ReloadData"), object: nil)

       
        self.detailTableView.delegate = self
        self.detailTableView.dataSource = self
        self.placeImagesCollectionView.delegate = self
        self.placeImagesCollectionView.dataSource = self
        // Do any additional setup after loading the view.
        
        self.starRatingCosmosView.didTouchCosmos = didTouchCosmos(_:)
        self.starRatingCosmosView.didFinishTouchingCosmos = didFinishTouchingCosmos(_:)
        let nib = UINib(nibName: "DetailTableFirstSectionHeader", bundle: nil)
        detailTableView.register(nib, forHeaderFooterViewReuseIdentifier: "DetailTableFirstSectionHeader")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }

    //MARK: - Images CollectionView Methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return detailPlace.imageNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "detailPlaceCell", for: indexPath) as! PlaceDetailCollectionViewCell
    
        let values : Array<Data> = Array(detailPlace.placeImages.values)
        if values.count > indexPath.row
        {
            cell.loadingImageIndicatorView.stopAnimating()
            cell.image.image = UIImage(data : values[indexPath.row])
        }
        return cell;
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let imageViewer =  self.storyboard?.instantiateViewController(withIdentifier: "imageViewerID") as! ImageViewerViewController
        let values : Array<Data> = Array(detailPlace.placeImages.values)
        imageViewer.data = values
        imageViewer.placeName = detailPlace.placeName
        imageViewer.initialImageIndex = indexPath.row
        let nav = UINavigationController(rootViewController: imageViewer)
        nav.navigationBar.tintColor = UIColor.white
        
        nav.navigationBar.topItem?.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .done, target: self, action: #selector(close))
        nav.navigationBar.topItem?.title = detailPlace.placeName
        
        self.present(nav, animated: true, completion: nil)
        
    }
    
    @objc func close () -> Void
    {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: - TableView Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "infoCell", for: indexPath)
        
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = detailPlace.info;
        cell.textLabel?.font = UIFont.systemFont(ofSize: 18.0, weight: UIFont.Weight.regular)
        return cell;
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        // Dequeue with the reuse identifier
        let cell = self.detailTableView.dequeueReusableHeaderFooterView(withIdentifier: "DetailTableFirstSectionHeader") as! DetailTableFirstSectionHeader
        
        let rating = String(format: "%.1f", detailPlace.calculateRating())
        

        cell.ratingLabel.text = rating
        cell.visitsCountLabel.text = "\(detailPlace.visitors.count)"
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    //MARK: - Rating View Methods
    private func didTouchCosmos(_ rating: Double) {
        print("didTouchCosmos")
    }
    
    private func didFinishTouchingCosmos(_ rating: Double) {
        print("didFinishTouchingCosmos")
        Places.rate(place: detailPlace, rating: Int(rating))

        self.detailTableView.reloadData()
    }

}
