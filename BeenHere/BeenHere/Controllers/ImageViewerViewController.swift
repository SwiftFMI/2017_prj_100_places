//
//  ImageViewerViewController.swift
//  BeenHere
//
//  Created by Petko Haydushki on 23.02.18.
//  Copyright © 2018 Petko Haydushki. All rights reserved.
//

import UIKit

class ImageViewerViewController: UIViewController,UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var imageViewerCollectionView: UICollectionView!
    var initialImageIndex = 0
    
    var placeName = String()
    var data = Array<Data>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.imageViewerCollectionView.delegate = self
        self.imageViewerCollectionView.dataSource = self
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        imageViewerCollectionView.setContentOffset(CGPoint(x: CGFloat(initialImageIndex) * self.view.frame.width, y: 0), animated: false)
//
//
        view.layoutIfNeeded()
        imageViewerCollectionView.scrollToItem(at: IndexPath(item: initialImageIndex, section: 0), at: UICollectionViewScrollPosition.left, animated: false)
        
    }
    override func viewDidAppear(_ animated: Bool) {
        imageViewerCollectionView.flashScrollIndicators()
//        imageViewerCollectionView.scrollToItem(at: IndexPath(item: initialImageIndex, section: 0), at: UICollectionViewScrollPosition.left, animated: false)
//
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageViewerCell", for: indexPath) as! ImageViewerCollectionViewCell
        
        cell.imageView.image = UIImage(data: data[indexPath.row])
        
        return cell;
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width:(collectionView.frame.width), height: (collectionView.frame.height))
    }
    
}
