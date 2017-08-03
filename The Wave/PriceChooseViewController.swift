//
//  PriceChooseViewController.swift
//  The Wave
//
//  Created by Andrew Robinson on 8/1/17.
//  Copyright © 2017 XYello, Inc. All rights reserved.
//

import UIKit

class PriceChooseViewController: SeletectedImageViewController, UITextFieldDelegate {

    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var nextButton: BigRedShadowButton!

    private var product = Product()
    private var isAllowedToContinue = false {
        didSet {
            nextButton.isEnabled = isAllowedToContinue
        }
    }

    // MARK: - View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        product.images.append(image)

        priceTextField.becomeFirstResponder()
        priceTextField.addTarget(self, action: #selector(textFieldTextChanged(_:)), for: .editingChanged)
        priceTextField.delegate = self

        priceTextField.attributedPlaceholder = NSAttributedString(string: "$0", attributes: [NSForegroundColorAttributeName: #colorLiteral(red: 0.137254902, green: 0.6352941176, blue: 0.3019607843, alpha: 0.5)])
        priceTextField.layer.borderColor = UIColor.white.cgColor
        priceTextField.layer.borderWidth = 1.0
        priceTextField.roundCorners(radius: 3.0)
        priceTextField.clipsToBounds = true

        nextButton.isEnabled = isAllowedToContinue
        view.hideKeyboardWhenTappedAround()
    }

    override func present(fromVc: UIViewController) {
        modalPresentationStyle = .overCurrentContext
        super.present(fromVc: fromVc)
    }

    // MARK: - Actions

    @objc func textFieldTextChanged(_ sender: UITextField) {
        if let text = sender.text {
            if text != "" {

                let noCommas = text.replacingOccurrences(of: ",", with: "")
                let noSymbol = noCommas.replacingOccurrences(of: "$", with: "")

                if let price = Int(noSymbol) {
                    let formatter = NumberFormatter()
                    formatter.numberStyle = .currency
                    formatter.maximumFractionDigits = 0

                    product.price = Float(price)

                    let string = formatter.string(from: price as NSNumber)
                    sender.text = string
                }
            }
        }
    }
    
    @IBAction func nextPressed(_ sender: BigRedShadowButton) {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = mainStoryboard.instantiateViewController(withIdentifier: "jeepSelectorViewController") as! JeepSelectorViewController

        navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: - Textfield delegate

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var shouldAllowCharacter = true

        if let text = textField.text {
            if text.characters.count > 6 && string != "" {
                shouldAllowCharacter = false
            } else {
                isAllowedToContinue = true
            }
        }

        return shouldAllowCharacter
    }
}
