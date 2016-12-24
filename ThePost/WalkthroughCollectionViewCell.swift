//
//  WalkthroughCollectionViewCell.swift
//  ThePost
//
//  Created by Andrew Robinson on 12/24/16.
//  Copyright © 2016 The Post. All rights reserved.
//

import UIKit

class WalkthroughCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var stepCountContainer: UIView!
    @IBOutlet weak var stepCountLabel: UILabel!
    @IBOutlet weak var bottomImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        stepCountContainer.roundCorners()
    }
    
}
