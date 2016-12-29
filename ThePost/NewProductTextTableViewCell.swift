//
//  NewProductTextTableViewCell.swift
//  ThePost
//
//  Created by Andrew Robinson on 12/28/16.
//  Copyright © 2016 The Post. All rights reserved.
//

import UIKit

class NewProductTextTableViewCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var sideImageView: UIImageView!
    @IBOutlet weak var detailNameLabel: UILabel!
    @IBOutlet weak var contentTextField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentTextField.attributedPlaceholder = NSAttributedString(string: "Type here...", attributes: [NSForegroundColorAttributeName: #colorLiteral(red: 0.9098039216, green: 0.9058823529, blue: 0.8235294118, alpha: 0.5)])
        contentTextField.addTarget(self, action: #selector(textChanged(_:)), for: .editingChanged)
        contentTextField.delegate = self
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var shouldAllowCharacter = true
        
        if textField.keyboardType == .numberPad {
            if let text = textField.text {
                if text.characters.count > 6 && string != "" {
                    shouldAllowCharacter = false
                }
            }
        }
        
        return shouldAllowCharacter
    }
    
    // MARK: - Actions
    
    @objc func textChanged(_ sender: UITextField) {
        if sender.keyboardType == .numberPad {
            if let text = sender.text {
                let noCommas = text.replacingOccurrences(of: ",", with: "")
                let noSymbol = noCommas.replacingOccurrences(of: "$", with: "")
                
                if let price = Int(noSymbol) {
                    let formatter = NumberFormatter()
                    formatter.numberStyle = .currency
                    formatter.maximumFractionDigits = 0
                    
                    let string = formatter.string(from: price as NSNumber)
                    sender.text = string
                }
            }
        }
    }

}
