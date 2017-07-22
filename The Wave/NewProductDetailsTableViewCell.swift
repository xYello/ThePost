//
//  NewProductDetailsTableViewCell.swift
//  ThePost
//
//  Created by Andrew Robinson on 12/29/16.
//  Copyright © 2016 XYello, Inc. All rights reserved.
//

import UIKit

class NewProductDetailsTableViewCell: NewProductBaseTableViewCell, UITextFieldDelegate, UITextViewDelegate {

    @IBOutlet weak var sideImageView: UIImageView!
    @IBOutlet weak var detailNameLabel: UILabel!
    
    @IBOutlet weak var originalBoxSwitch: UISwitch!
    @IBOutlet weak var releaseYearTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
        
    override func awakeFromNib() {
        super.awakeFromNib()
        
        originalBoxSwitch.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        
        let components = Calendar.current.dateComponents([.year], from: Date())
        if let year = components.year {
            releaseYearTextField.attributedPlaceholder = NSAttributedString(string: "\(year)", attributes: [NSForegroundColorAttributeName: #colorLiteral(red: 0.9098039216, green: 0.9058823529, blue: 0.8235294118, alpha: 0.2531197567)])
        }
        
        releaseYearTextField.delegate = self
        descriptionTextView.delegate = self
    }
    
    // MARK: - TextField delegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var shouldAllowCharacter = true
        
        if let text = textField.text {
            if text.characters.count >= 4 && string != "" {
                shouldAllowCharacter = false
            }
        }
        
        return shouldAllowCharacter
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        var shouldAllowCharacter = true
        
        if let string = textView.text {
            if string.characters.count >= 112 && text != "" {
                shouldAllowCharacter = false
            } else {
                if let delegate = delegate {
                    delegate.valueDidChangeInCell(sender: self, value: string + text)
                }
            }
        }
        
        return shouldAllowCharacter
    }
    
    // MARK: - Actions
    
    @IBAction func switchValueChanged(_ sender: UISwitch) {
        if let delegate = delegate {
            delegate.valueDidChangeInCell(sender: self, value: sender.isOn)
        }
    }
    
    @IBAction func releaseYearTextChanged(_ sender: UITextField) {
        if let delegate = delegate {
            delegate.valueDidChangeInCell(sender: self, value: sender.text)
        }
    }

}
