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
    @IBOutlet weak var personNameLabel: UILabel!
    @IBOutlet weak var presenceIndicator: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var recentMessageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profileImageView.roundCorners()
        profileImageView.clipsToBounds = true
        
        presenceIndicator.roundCorners()
    }

}
