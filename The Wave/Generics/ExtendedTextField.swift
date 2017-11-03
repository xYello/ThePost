//
//  ExtendedTextField.swift
//  The Wave
//
//  Created by Andrew Robinson on 8/6/17.
//  Copyright © 2017 XYello, Inc. All rights reserved.
//

import UIKit

class ExtendedTextField: UITextField {

    let adjustment: CGFloat = 8.0

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        super.textRect(forBounds: bounds)
        return CGRect(x: bounds.origin.x + adjustment, y: bounds.origin.y, width: bounds.width - adjustment, height: bounds.height)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        super.editingRect(forBounds: bounds)
        return CGRect(x: bounds.origin.x + adjustment, y: bounds.origin.y, width: bounds.width - adjustment, height: bounds.height)
    }

}
