//
//  RoundedTextField.swift
//  ThePost
//
//  Created by Andrew Robinson on 12/23/16.
//  Copyright © 2016 The Post. All rights reserved.
//

import UIKit

class RoundedTextField: UITextField {
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        super.textRect(forBounds: bounds)
        return CGRect(x: bounds.origin.x + 18.0, y: bounds.origin.y, width: bounds.width - 58, height: bounds.height)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        super.editingRect(forBounds: bounds)
        return CGRect(x: bounds.origin.x + 18.0, y: bounds.origin.y, width: bounds.width - 58, height: bounds.height)
    }

}
