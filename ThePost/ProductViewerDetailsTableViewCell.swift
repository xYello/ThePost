//
//  ProductViewerDetailsTableViewCell.swift
//  ThePost
//
//  Created by Andrew Robinson on 1/10/17.
//  Copyright © 2017 The Post. All rights reserved.
//

import UIKit

class ProductViewerDetailsTableViewCell: UITableViewCell {

    @IBOutlet weak var sideImageView: UIImageView!
    @IBOutlet weak var detailNameLabel: UILabel!
    @IBOutlet weak var originalBoxImageView: UIImageView!
    @IBOutlet weak var datePostedLabel: UILabel!
    @IBOutlet weak var releaseYearLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
