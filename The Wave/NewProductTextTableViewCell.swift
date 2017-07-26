//
//  NewProductTextTableViewCell.swift
//  ThePost
//
//  Created by Andrew Robinson on 12/28/16.
//  Copyright © 2016 XYello, Inc. All rights reserved.
//

import UIKit

class NewProductTextTableViewCell: NewProductBaseTableViewCell, UITextFieldDelegate {

    @IBOutlet weak var sideImageView: UIImageView!
    @IBOutlet weak var detailNameLabel: UILabel!
    @IBOutlet weak var contentTextField: UITextField!

    var placeHolder: String = "" {
        didSet {
            contentTextField.attributedPlaceholder = NSAttributedString(string: placeHolder, attributes: [NSForegroundColorAttributeName: #colorLiteral(red: 0.9098039216, green: 0.9058823529, blue: 0.8235294118, alpha: 0.5)])
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
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
        if let text = sender.text {
            if text != "" {
                if sender.keyboardType == .numberPad {
                    
                    let noCommas = text.replacingOccurrences(of: ",", with: "")
                    let noSymbol = noCommas.replacingOccurrences(of: "$", with: "")
                    
                    if let price = Int(noSymbol) {
                        let formatter = NumberFormatter()
                        formatter.numberStyle = .currency
                        formatter.maximumFractionDigits = 0
                        
                        let string = formatter.string(from: price as NSNumber)
                        sender.text = string
                        
                        if let delegate = delegate {
                            delegate.valueDidChangeInCell(sender: self, value: price)
                        }
                    }
                } else {
                    if let delegate = delegate {
                        delegate.valueDidChangeInCell(sender: self, value: text)
                    }
                }
                
                sideImageView.tintColor = #colorLiteral(red: 0.9098039216, green: 0.9058823529, blue: 0.8235294118, alpha: 1)
                detailNameLabel.textColor = #colorLiteral(red: 0.9098039216, green: 0.9058823529, blue: 0.8235294118, alpha: 1)
            } else {
                sideImageView.tintColor = #colorLiteral(red: 0.8470588235, green: 0.337254902, blue: 0.2156862745, alpha: 1)
                detailNameLabel.textColor = #colorLiteral(red: 0.8470588235, green: 0.337254902, blue: 0.2156862745, alpha: 1)
            }
        }
    }

}
