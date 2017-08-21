//
//  ProductExtraDetailsViewController.swift
//  The Wave
//
//  Created by Andrew Robinson on 8/5/17.
//  Copyright © 2017 XYello, Inc. All rights reserved.
//

import UIKit

class ProductExtraDetailsViewController: SeletectedImageViewController, JeepModelChooserDelegate, UITextViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var topBackgroundView: UIView!
    @IBOutlet weak var bottomBackgroundView: UIView!

    @IBOutlet weak var leftMostButton: UIButton!
    @IBOutlet weak var leftMidButton: UIButton!
    @IBOutlet weak var rightMidButton: UIButton!
    @IBOutlet weak var rightMostButton: UIButton!
    
    @IBOutlet weak var productNameTextField: UITextField!
    @IBOutlet weak var jeepTypeView: UIView!
    @IBOutlet weak var jeepTypeLabel: UILabel!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var locationGlyphImageView: UIImageView!

    @IBOutlet weak var descriptionTextView: UITextView!

    @IBOutlet weak var shippingSwitch: UISwitch!
    @IBOutlet weak var paypalSwitch: UISwitch!
    @IBOutlet weak var cashSwitch: UISwitch!

    private var product: Product!

    // MARK: - Init

    init(withProduct product: Product) {
        self.product = product
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Top background view
        format(button: leftMostButton)
        format(button: leftMidButton)
        format(button: rightMidButton)
        format(button: rightMostButton)

        leftMostButton.setImage(product.images[0], for: .normal)
        leftMidButton.setBackgroundImage(#imageLiteral(resourceName: "NewImageProduct"), for: .normal)

        // Bottom background view
        productNameTextField.addBorder(withWidth: 1.0, color: .waveLightGray)
        productNameTextField.roundCorners(radius: 3.0)

        jeepTypeView.addBorder(withWidth: 1.0, color: .waveLightGray)
        jeepTypeView.roundCorners(radius: 3.0)
        jeepTypeLabel.text = product.jeepModel.name

        if let price = product.price {
            priceTextField.text = "$\(Int(price))"
        }
        priceTextField.textColor = .waveGreen
        priceTextField.addBorder(withWidth: 1.0, color: .waveLightGray)
        priceTextField.roundCorners(radius: 3.0)
        priceTextField.delegate = self
        priceTextField.keyboardType = .numberPad

        locationView.addBorder(withWidth: 1.0, color: .waveLightGray)
        locationView.roundCorners(radius: 3.0)

        descriptionTextView.addBorder(withWidth: 1.0, color: .waveLightGray)
        descriptionTextView.roundCorners(radius: 3.0)
        descriptionTextView.delegate = self

        shippingSwitch.isOn = false
        paypalSwitch.isOn = false

        view.hideKeyboardWhenTappedAround()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        bottomBackgroundView.roundCorners(radius: 8.0)
    }

    // MARK: - UITextField delegate

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var shouldAllowCharacter = true

        if let text = textField.text {
            if text.characters.count > 6 && string != "" {
                shouldAllowCharacter = false
            } else {

            }
        }

        return shouldAllowCharacter
    }

    // MARK: - UITextView delegate

    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.resignFirstResponder()

        if textView.text == "Write a description..." {
            textView.text = ""
        }
        
        let vc = KeyboardHelperViewController.getVc(with: textView.text) { text in
            if text != "" {
                self.descriptionTextView.text = text
                self.descriptionTextView.textColor = .black
            } else {
                self.descriptionTextView.text = "Write a description..."
                self.descriptionTextView.textColor = #colorLiteral(red: 0.6980392157, green: 0.6980392157, blue: 0.6980392157, alpha: 1)
            }
        }
        present(vc, animated: false, completion: nil)
    }

    // MARK: - JeepModelChooser delegate

    func didChange(model: JeepModel) {
        jeepTypeLabel.text = model.name
    }

    // MARK: - Actions

    @IBAction func cameraButtonPressed(_ sender: UIButton) {
        let vc = ImageSelectorViewController(prefilledImage: sender.image(for: .normal)) { image in
            if let image = image {
                self.updateButtonImage(for: image, from: sender)
            }
        }
        present(vc, animated: true, completion: nil)
    }

    @IBAction func namePriceTextFieldChanged(_ sender: UITextField) {
        if sender === productNameTextField {
            productNameTextField.addBorder(withWidth: 1.0, color: .waveLightGray)
        } else if sender === priceTextField {
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

            priceTextField.addBorder(withWidth: 1.0, color: .waveLightGray)
        }
    }

    @IBAction func jeepTypeButtonPressed(_ sender: UIButton) {
        let vc = JeepModelChooserViewController(withProduct: product)
        vc.modalPresentationStyle = .overCurrentContext
        vc.delegate = self
        vc.selectedProduct = product.jeepModel
        present(vc, animated: true, completion: nil)
    }
    
    @IBAction func locationButtonPressed(_ sender: UIButton) {
    }

    @IBAction func postProductButtonPressed(_ sender: BigRedShadowButton) {
        if isRequiredTextFieldsFilled() {
            product.name = productNameTextField.text
            product.acceptsCash = cashSwitch.isOn
            product.acceptsPayPal = paypalSwitch.isOn
            product.willingToShip = shippingSwitch.isOn
            product.detailedDescription = descriptionTextView.text

            let vc = ProductUploadViewController(withProduct: product)
            vc.handler = handler
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func xButonPressed(_ sender: UIButton) {
        handler.dismiss()
    }

    // MARK: - Helpers

    private func format(button: UIButton) {
        button.clipsToBounds = true
        button.roundCorners(radius: CornerRadius.constant)
        button.setImage(nil, for: .normal)
    }

    private func updateButtonImage(for image: UIImage, from sender: UIButton) {
        if sender === leftMostButton {
            product.images[0] = image
            sender.setImage(image, for: .normal)
        } else if sender === leftMidButton {
            if product.images.count >= 2 {
                product.images[1] = image
            } else {
                product.images.append(image)
                rightMidButton.setBackgroundImage(#imageLiteral(resourceName: "NewImageProduct"), for: .normal)
            }
            sender.setImage(image, for: .normal)
        } else if sender === rightMidButton {
            if product.images.count >= 3 {
                product.images[2] = image
                sender.setImage(image, for: .normal)
            } else if product.images.count == 2 {
                product.images.append(image)
                sender.setImage(image, for: .normal)
                rightMostButton.setBackgroundImage(#imageLiteral(resourceName: "NewImageProduct"), for: .normal)
            } else if product.images.count == 1 {
                product.images.append(image)
                leftMidButton.setImage(image, for: .normal)
                sender.setBackgroundImage(#imageLiteral(resourceName: "NewImageProduct"), for: .normal)
            }
        } else if sender === rightMostButton {
            if product.images.count == 4 {
                product.images[3] = image
                sender.setImage(image, for: .normal)
            } else if product.images.count == 3 {
                product.images.append(image)
                sender.setImage(image, for: .normal)
            } else if product.images.count == 2 {
                product.images.append(image)
                rightMidButton.setImage(image, for: .normal)
                sender.setBackgroundImage(#imageLiteral(resourceName: "NewImageProduct"), for: .normal)
            } else if product.images.count == 1 {
                product.images.append(image)
                leftMidButton.setImage(image, for: .normal)
                rightMidButton.setBackgroundImage(#imageLiteral(resourceName: "NewImageProduct"), for: .normal)
            }
        }
    }

    private func isRequiredTextFieldsFilled() -> Bool {
        var viewsToShake = [UIView]()
        if let text = productNameTextField.text {
            if text.characters.count == 0 {
                indicateTextFieldIsRequired(textField: productNameTextField)
                viewsToShake.append(productNameTextField)
            }
        } else {
            indicateTextFieldIsRequired(textField: productNameTextField)
            viewsToShake.append(productNameTextField)
        }

        if let text = priceTextField.text {
            let priceString = text.components(separatedBy: CharacterSet.decimalDigits.inverted).joined(separator: "")
            if text.characters.count <= 1 || "$" + priceString != text {
                indicateTextFieldIsRequired(textField: priceTextField)
                viewsToShake.append(priceTextField)
            }
        } else {
            indicateTextFieldIsRequired(textField: priceTextField)
            viewsToShake.append(priceTextField)
        }

        if viewsToShake.count > 0 {
            for view in viewsToShake {
                view.shake()
            }

            return false
        } else {
            return true
        }
    }

    private func indicateTextFieldIsRequired(textField: UITextField) {
        textField.addBorder(withWidth: 1.0, color: .waveRed)
    }

}
