//
//  CategorySelectorCollectionViewCell.swift
//  ThePost
//
//  Created by Andrew Robinson on 12/26/16.
//  Copyright © 2016 The Post. All rights reserved.
//

import UIKit

class CategorySelectorCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    @IBOutlet weak var categoryTitleLabel: UILabel!
    @IBOutlet weak var numberOfItemsLabel: UILabel!
    
    var categoryTitle = "" {
        didSet {
            categoryTitleLabel.text = categoryTitle
        }
    }
    
    var numberOfItems = 0 {
        didSet {
            numberOfItemsLabel.text = "\(numberOfItems) items"
        }
    }
    
    var backgroundImage: UIImage! {
        didSet {
            backgroundImageView.image = backgroundImage
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.roundCorners(radius: 15)
    }
    
}
