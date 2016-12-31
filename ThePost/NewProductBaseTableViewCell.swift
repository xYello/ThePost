//
//  NewProductBaseTableViewCell.swift
//  ThePost
//
//  Created by Andrew Robinson on 12/30/16.
//  Copyright © 2016 The Post. All rights reserved.
//

import UIKit

protocol NewProductBaseTableViewCellDelegate: class {
    func valueDidChangeInCell(sender: NewProductBaseTableViewCell, value: Any?)
}

class NewProductBaseTableViewCell: UITableViewCell {
    
    weak var delegate: NewProductBaseTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
