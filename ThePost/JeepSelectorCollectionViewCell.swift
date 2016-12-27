//
//  JeepSelectorCollectionViewCell.swift
//  ThePost
//
//  Created by Andrew Robinson on 12/26/16.
//  Copyright © 2016 The Post. All rights reserved.
//

import UIKit

class JeepSelectorCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var modelImage: UIImageView!
    @IBOutlet weak var modelLabel: UILabel!
    @IBOutlet weak var modelYearLabel: UILabel!
    
    @IBOutlet weak var selectButton: JeepModelButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.roundCorners(radius: 20.0)
        selectButton.roundCorners()
    }
    
}
