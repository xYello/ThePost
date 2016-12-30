//
//  NewProductSwitchTableViewCell.swift
//  ThePost
//
//  Created by Andrew Robinson on 12/29/16.
//  Copyright © 2016 The Post. All rights reserved.
//

import UIKit

class NewProductSwitchTableViewCell: UITableViewCell {

    @IBOutlet weak var sideImageView: UIImageView!
    @IBOutlet weak var detailNameLabel: UILabel!
    @IBOutlet weak var switchControl: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        switchControl.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
    }

}
