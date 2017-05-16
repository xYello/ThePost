//
//  ProductViewerExCheckTableViewCell.swift
//  ThePost
//
//  Created by Andrew Robinson on 1/10/17.
//  Copyright © 2017 The Post. All rights reserved.
//

import UIKit

class ProductViewerExCheckTableViewCell: UITableViewCell {

    @IBOutlet weak var sideImageView: UIImageView!
    @IBOutlet weak var detailNameLabel: UILabel!
    @IBOutlet weak var exCheckImageView: UIImageView!
    
    var isChecked = false {
        didSet {
            if isChecked {
                exCheckImageView.image = UIImage(named: "PVCheck")
            } else {
                exCheckImageView.image = UIImage(named: "PVEx")
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
