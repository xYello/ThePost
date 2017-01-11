//
//  ProductViewerSellerTableViewCell.swift
//  ThePost
//
//  Created by Andrew Robinson on 1/10/17.
//  Copyright © 2017 The Post. All rights reserved.
//

import UIKit

class ProductViewerSellerTableViewCell: UITableViewCell {

    @IBOutlet weak var sideImageView: UIImageView!
    @IBOutlet weak var detailNameLabel: UILabel!
    @IBOutlet weak var sellerNameLabel: UILabel!
    @IBOutlet weak var sellerImageView: UIImageView!
    
    @IBOutlet weak var numberOfReviewsLabel: UILabel!
    @IBOutlet weak var oneStar: UIImageView!
    @IBOutlet weak var twoStart: UIImageView!
    @IBOutlet weak var threeStar: UIImageView!
    @IBOutlet weak var fourStar: UIImageView!
    @IBOutlet weak var fiveStar: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        sellerImageView.clipsToBounds = true
        sellerImageView.roundCorners()
    }

}
