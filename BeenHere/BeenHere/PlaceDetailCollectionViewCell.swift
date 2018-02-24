//
//  PlaceDetailCollectionViewCell.swift
//  BeenHere
//
//  Created by Petko Haydushki on 13.02.18.
//  Copyright © 2018 Petko Haydushki. All rights reserved.
//

import UIKit

class PlaceDetailCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var loadingImageIndicatorView: UIActivityIndicatorView!
    
    override func draw(_ rect: CGRect) {
        
        self.image.layer.cornerRadius = 15.0
        self.image.layer.masksToBounds = true
    }
    
    override func awakeFromNib() {
        self.loadingImageIndicatorView.startAnimating()
    }
}
