//
//  NewProductTextTableViewCell.swift
//  ThePost
//
//  Created by Andrew Robinson on 12/28/16.
//  Copyright © 2016 The Post. All rights reserved.
//

import UIKit

class NewProductTextTableViewCell: UITableViewCell {

    @IBOutlet weak var sideImageView: UIImageView!
    @IBOutlet weak var detailNameLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!

    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
