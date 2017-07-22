//
//  WalkthroughCollectionViewCell.swift
//  ThePost
//
//  Created by Andrew Robinson on 12/24/16.
//  Copyright © 2016 XYello, Inc. All rights reserved.
//

import UIKit

class WalkthroughCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var bottomImageView: UIImageView!
    
    @IBOutlet weak var nextButton: UIButton!
    
    override func awakeFromNib() {
        nextButton.roundCorners()
    }
    
}
