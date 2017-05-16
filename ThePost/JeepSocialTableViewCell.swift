//
//  JeepSocialTableViewCell.swift
//  ThePost
//
//  Created by Tyler Flowers on 2/14/17.
//  Copyright © 2017 The Post. All rights reserved.
//

import UIKit

class JeepSocialTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var postImageView: UIImageView!
    
    @IBOutlet weak var postNameLabel: UILabel!
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.profileImageView.clipsToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.profileImageView.roundCorners()
    }

    @IBAction func likeButtonPressed(_ sender: Any) {
 
    }
    
}
