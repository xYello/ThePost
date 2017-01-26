//
//  NewReviewActivityTableViewCell.swift
//  ThePost
//
//  Created by Andrew Robinson on 1/25/17.
//  Copyright © 2017 The Post. All rights reserved.
//

import UIKit

class NewReviewActivityTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var messageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profileImageView.roundCorners()
        profileImageView.clipsToBounds = true
    }

}
