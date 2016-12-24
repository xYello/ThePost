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
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var bottomImageView: UIImageView!
    
    @IBOutlet weak var imageToBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageAspectRatioConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        stepCountContainer.roundCorners()
    }
    
}
