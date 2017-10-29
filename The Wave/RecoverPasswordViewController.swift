//
//  RecoverPasswordViewController.swift
//  ThePost
//
//  Created by Andrew Robinson on 2/9/17.
//  Copyright © 2017 XYello, Inc. All rights reserved.
//

import UIKit
import Firebase

class RecoverPasswordViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var passwordIcon: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var emailTextField: RoundedTextField!
    
    @IBOutlet weak var recoverButton: UIButton!
    
    @IBOutlet weak var exitButton: UIButton!
    
    @IBOutlet weak var emailTextFieldCenterYConstraint: NSLayoutConstraint!
    
    private var emailImageView: UIImageView!
    
    var preloadedEmailAddress: String?
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        passwordIcon.image = UIImage(named: "Password")!.withRenderingMode(.alwaysTemplate)
        passwordIcon.tintColor = #colorLiteral(red: 0.9098039216, green: 0.9058823529, blue: 0.8235294118, alpha: 1)
        
        emailImageView = UIImageView(image: UIImage(named: "Mail")!.withRenderingMode(.alwaysTemplate))
        formatTextField(field: emailTextField, withImageView: emailImageView)
        
        recoverButton.roundCorners()
        
        if let text = preloadedEmailAddress {
            emailTextField.text = text
        }
    }
    
    // MARK: - Textfield delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        recoverButton.sendActions(for: .touchUpInside)
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        emailTextFieldCenterYConstraint.constant = emailTextFieldCenterYConstraint.constant - emailTextField.frame.origin.y + 45
        
        UIView.animate(withDuration: 0.25, animations: {
            self.view.layoutIfNeeded()
            self.titleLabel.alpha = 0.0
            self.messageLabel.alpha = 0.0
            self.exitButton.alpha = 0.0
        })
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        emailTextFieldCenterYConstraint.constant = 0.0
        
        UIView.animate(withDuration: 0.25, animations: {
            self.view.layoutIfNeeded()
            self.titleLabel.alpha = 1.0
            self.messageLabel.alpha = 1.0
            self.exitButton.alpha = 1.0
        })
    }
    
    // MARK: - Actions

    @IBAction func recoverPasswordPressed(_ sender: UIButton) {
        if let text = emailTextField.text {
            Auth.auth().sendPasswordReset(withEmail: text) { error in
                if let error = error {
                    print("Error resetting password: \(error.localizedDescription)")
                    SentryManager.shared.sendEvent(withError: error)
                } else {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func closeButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(false)
    }
    
    // MARK: - Helpers
    
    private func formatTextField(field: UITextField, withImageView imageView: UIImageView) {
        field.roundCorners()
        field.delegate = self
        field.attributedPlaceholder = NSAttributedString(string: field.placeholder!, attributes: [NSAttributedStringKey.foregroundColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.3503303272)])
        
        imageView.tintColor = #colorLiteral(red: 0.9098039216, green: 0.9058823529, blue: 0.8235294118, alpha: 1)
        
        // Pad the image so it doesn't appear right in-line with the textfield border.
        if let size = imageView.image?.size {
            imageView.frame = CGRect(x: 0.0, y: 0.0, width: size.width + 15.0, height: size.height)
        }
        imageView.contentMode = .left
        
        field.rightViewMode = .always
        field.rightView = imageView
    }
    
}
