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
        // Initialization code
        
        self.profileImageView.clipsToBounds = true
        
        self.postImageView.translatesAutoresizingMaskIntoConstraints = false
        self.likeButton.translatesAutoresizingMaskIntoConstraints = false
        self.profileImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let imageWidth = NSLayoutConstraint(item: self.postImageView,
                                            attribute: .width,
                                            relatedBy: .equal,
                                            toItem: self,
                                            attribute: .width,
                                            multiplier: 1,
                                            constant: 0)
        
        let imageHeight = NSLayoutConstraint(item: self.postImageView,
                                             attribute: .height,
                                             relatedBy: .equal,
                                             toItem: self,
                                             attribute: .height,
                                             multiplier: 0.75,
                                             constant: 0)
        
        let imageTrailing = NSLayoutConstraint(item: self.postImageView,
                                               attribute: .bottom,
                                               relatedBy: .equal,
                                               toItem: self,
                                               attribute: .bottom,
                                               multiplier: 1,
                                               constant: 0)
        
        self.addConstraints([imageWidth, imageHeight, imageTrailing])
        
        let buttonYPosition = NSLayoutConstraint(item: self.likeButton,
                                                 attribute: .centerY,
                                                 relatedBy: .equal,
                                                 toItem: self,
                                                 attribute: .centerY,
                                                 multiplier: 0.25,
                                                 constant: 0)
        
        let buttonXPosition = NSLayoutConstraint(item: self.likeButton,
                                                 attribute: .right,
                                                 relatedBy: .equal,
                                                 toItem: self,
                                                 attribute: .right,
                                                 multiplier: 0.95,
                                                 constant: 0)
        
        self.addConstraints([buttonYPosition, buttonXPosition])
        
        
        let profileImageWidth = NSLayoutConstraint(item: self.profileImageView,
                                            attribute: .width,
                                            relatedBy: .equal,
                                            toItem: self,
                                            attribute: .width,
                                            multiplier: 0.15,
                                            constant: 0)
        
        let profileImageHeight = NSLayoutConstraint(item: self.profileImageView,
                                             attribute: .height,
                                             relatedBy: .equal,
                                             toItem: self,
                                             attribute: .width,
                                             multiplier: 0.15,
                                             constant: 0)
        
        let profileImageX = NSLayoutConstraint(item: self.profileImageView,
                                                    attribute: .top,
                                                    relatedBy: .equal,
                                                    toItem: self,
                                                    attribute: .top,
                                                    multiplier: 1,
                                                    constant: 20)
        
        let profileImageY = NSLayoutConstraint(item: self.profileImageView,
                                               attribute: .leading,
                                               relatedBy: .equal,
                                               toItem: self,
                                               attribute: .leading,
                                               multiplier: 1,
                                               constant: 20)
        
        self.addConstraints([profileImageWidth, profileImageHeight, profileImageX, profileImageY])
        

    }
    
    override func layoutSubviews() {
        super .layoutSubviews()
        self.profileImageView.roundCorners()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func likeButtonPressed(_ sender: Any) {
 
    }
    
}
