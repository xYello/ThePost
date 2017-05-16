//
//  ConversationTableViewCell.swift
//  ThePost
//
//  Created by Andrew Robinson on 1/6/17.
//  Copyright © 2017 The Post. All rights reserved.
//

import UIKit

class ConversationTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var soldImageView: UIImageView!
    
    @IBOutlet weak var unreadMessageView: UIView!
    @IBOutlet weak var unreadCountLabel: UILabel!
    
    @IBOutlet weak var personNameLabel: UILabel!
    @IBOutlet weak var presenceIndicator: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var recentMessageLabel: UILabel!
    
    var isProductSold = false {
        didSet {
            if isProductSold {
                UIView.animate(withDuration: 0.25, animations: {
                    self.soldImageView.alpha = 1.0
                })
            } else {
                UIView.animate(withDuration: 0.25, animations: {
                    self.soldImageView.alpha = 0.0
                })
            }
        }
    }
    
    var messageCountUnread = 0 {
        didSet {
            if messageCountUnread == 0 {
                UIView.animate(withDuration: 0.25, animations: {
                    self.unreadMessageView.alpha = 0.0
                })
            } else {
                UIView.animate(withDuration: 0.25, animations: {
                    self.unreadMessageView.alpha = 1.0
                })
            }
            
            unreadCountLabel.text = "\(messageCountUnread)"
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profileImageView.roundCorners()
        profileImageView.clipsToBounds = true
        
        soldImageView.alpha = 0.0
        
        unreadMessageView.alpha = 0.0
        unreadMessageView.roundCorners()
        
        presenceIndicator.roundCorners()
        presenceIndicator.isHidden = true
    }

}
