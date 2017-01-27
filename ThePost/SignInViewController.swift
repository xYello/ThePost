//
//  SignInViewController.swift
//  ThePost
//
//  Created by Andrew Robinson on 1/11/17.
//  Copyright © 2017 The Post. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class SignInViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var emailTextField: RoundedTextField!
    @IBOutlet weak var passwordTextField: RoundedTextField!
    
    @IBOutlet weak var signInButton: UIButton!
    
    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var emailTextFieldCenterYConstraint: NSLayoutConstraint!
    @IBOutlet weak var passwordTextFieldCenterYConstraint: NSLayoutConstraint!
    
    private var emailImageView: UIImageView!
    private var passwordImageView: UIImageView!
    
    private var isTypingInTextField = false
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        errorLabel.isHidden = true
        
        emailImageView = UIImageView(image: UIImage(named: "Mail")!.withRenderingMode(.alwaysTemplate))
        formatTextField(field: emailTextField, withImageView: emailImageView)
        
        passwordImageView = UIImageView(image: UIImage(named: "Password")!.withRenderingMode(.alwaysTemplate))
        formatTextField(field: passwordTextField, withImageView: passwordImageView)
        
        signInButton.layer.borderColor = signInButton.titleLabel!.textColor.cgColor
        signInButton.layer.borderWidth = 4.0
        signInButton.roundCorners()
    }
    
    // MARK: - Textfield delegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if !isTypingInTextField {
            isTypingInTextField = true
            
            emailTextFieldCenterYConstraint.constant = emailTextFieldCenterYConstraint.constant - nameView.frame.height + 28
            passwordTextFieldCenterYConstraint.constant = passwordTextFieldCenterYConstraint.constant - nameView.frame.height + 28
            
            UIView.animate(withDuration: 0.25, animations: {
                self.view.layoutIfNeeded()
                self.nameView.alpha = 0.0
            })
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if !isTypingInTextField {
        
            emailTextFieldCenterYConstraint.constant = emailTextFieldCenterYConstraint.constant + nameView.frame.height - 28
            passwordTextFieldCenterYConstraint.constant = passwordTextFieldCenterYConstraint.constant + nameView.frame.height - 28
            
            UIView.animate(withDuration: 0.25, animations: {
                self.view.layoutIfNeeded()
                self.nameView.alpha = 1.0
            })
        }
    }
    
    // MARK: - Actions
    
    @IBAction func forgotPasswordButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "unwindToPresenting", sender: self)
    }

    @IBAction func signInButtonPressed(_ sender: UIButton) {
        if let email = emailTextField.text, let password = passwordTextField.text {
            FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { user, error in
                if let error = error {
                    if error.localizedDescription == "The email address is badly formatted." {
                        self.errorLabel.isHidden = false
                        self.errorLabel.text = "Invalid email address. Please try again."
                    } else if error.localizedDescription == "The password is invalid or the user does not have a password." {
                        self.errorLabel.isHidden = false
                        self.errorLabel.text = "Invalid email or password. Please try again."
                    } else if error.localizedDescription == "There is no user record corresponding to this identifier. The user may have been deleted." {
                        self.errorLabel.isHidden = false
                        self.errorLabel.text = "Invalid email or password. Please try again."
                    } else if error.localizedDescription == "We have blocked all requests from this device due to unusual activity. Try again later." {
                        self.errorLabel.isHidden = false
                        self.errorLabel.text = "Please stop."
                    } else {
                        print("Error signing in: \(error.localizedDescription)")
                    }
                } else {
                    KeychainWrapper.standard.set(self.passwordTextField.text!, forKey: Constants.UserInfoKeys.UserPass.rawValue)
                    self.performSegue(withIdentifier: "unwindToPresenting", sender: self)
                }
            })
        }
    }
    
    @IBAction func facebookButtonPressed(_ sender: UIButton) {
        
    }
    
    @IBAction func twitterButtonPressed(_ sender: UIButton) {
        
    }
    
    @objc private func dismissKeyboard() {
        isTypingInTextField = false
        view.endEditing(false)
    }
    
    // MARK: - Helpers
    
    private func formatTextField(field: UITextField, withImageView imageView: UIImageView) {
        field.roundCorners()
        field.attributedPlaceholder = NSAttributedString(string: field.placeholder!, attributes: [NSForegroundColorAttributeName: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.3503303272)])
        
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
