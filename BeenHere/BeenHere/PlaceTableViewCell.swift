//
//  PlaceTableViewCell.swift
//  BeenHere
//
//  Created by Petko Haydushki on 13.02.18.
//  Copyright © 2018 Petko Haydushki. All rights reserved.
//

import UIKit

class PlaceTableViewCell: UITableViewCell {
    
    @IBOutlet weak var placeImageView: UIImageView!
    @IBOutlet weak var placeNameLabel: UILabel!
    
    @IBOutlet weak var dowloadingImageIndicator: UIActivityIndicatorView!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.dowloadingImageIndicator.startAnimating()
    }
    
    override func draw(_ rect: CGRect) {
        self.placeImageView.layer.cornerRadius = 10.0
        self.placeImageView.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
