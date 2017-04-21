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
import OneSignal

class SignInViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var exitButton: UIButton!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var emailTextField: RoundedTextField!
    @IBOutlet weak var passwordTextField: RoundedTextField!
    
    @IBOutlet weak var onePassswordButton: UIButton!
    
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
        
        onePassswordButton.isHidden = (false == OnePasswordExtension.shared().isAppExtensionAvailable())
        
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === emailTextField {
            passwordTextField.becomeFirstResponder()
        } else {
            signInButton.sendActions(for: .touchUpInside)
        }
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if !isTypingInTextField {
            isTypingInTextField = true
            
            emailTextFieldCenterYConstraint.constant = emailTextFieldCenterYConstraint.constant - nameView.frame.height + 28
            passwordTextFieldCenterYConstraint.constant = passwordTextFieldCenterYConstraint.constant - nameView.frame.height + 28
            
            UIView.animate(withDuration: 0.25, animations: {
                self.view.layoutIfNeeded()
                self.nameView.alpha = 0.0
                self.exitButton.alpha = 0.0
                
                self.onePassswordButton.alpha = 0.0
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
                self.exitButton.alpha = 1.0
                
                self.onePassswordButton.alpha = 1.0
            })
        }
    }
    
    // MARK: - Actions
    
    @IBAction func findLoginFrom1Password(_ sender: UIButton) {
        disableButtons()
        
        OnePasswordExtension.shared().findLogin(forURLString: "http://thewaveapp.com/", for: self, sender: sender, completion: { loginDictionary, error in
            if loginDictionary != nil {
                self.emailTextField.text = loginDictionary?[AppExtensionUsernameKey] as? String
                self.passwordTextField.text = loginDictionary?[AppExtensionPasswordKey] as? String
                
                FIRAuth.auth()?.signIn(withEmail: self.emailTextField.text!, password: self.passwordTextField.text!, completion: { user, error in
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
                        
                        self.disableButtons()
                    } else {
                        FIRDatabase.database().reference().child("users").child(FIRAuth.auth()!.currentUser!.uid).child("isOnline").setValue(true)
                        self.saveOneSignalId()
                        KeychainWrapper.standard.set(self.passwordTextField.text!, forKey: UserInfoKeys.UserPass)
                        self.sendToNextViewController()
                    }
                })
            }
        })
    }
    
    @IBAction func forgotPasswordButtonPressed(_ sender: UIButton) {
        dismissKeyboard()
        performSegue(withIdentifier: "showRecoverPassword", sender: self)
    }

    @IBAction func signInButtonPressed(_ sender: UIButton) {
        if let email = emailTextField.text, let password = passwordTextField.text {
            disableButtons()
            
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
                    
                    self.disableButtons()
                } else {
                    FIRDatabase.database().reference().child("users").child(FIRAuth.auth()!.currentUser!.uid).child("isOnline").setValue(true)
                    self.saveOneSignalId()
                    KeychainWrapper.standard.set(self.passwordTextField.text!, forKey: UserInfoKeys.UserPass)
                    self.sendToNextViewController()
                }
            })
        }
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
    
    private func disableButtons() {
        if signInButton.isEnabled {
            onePassswordButton.alpha = 0.75
            exitButton.alpha = 0.75
            signInButton.alpha = 0.75
            
            onePassswordButton.isEnabled = false
            exitButton.isEnabled = false
            signInButton.isEnabled = false
        } else {
            onePassswordButton.alpha = 1.0
            exitButton.alpha = 1.0
            signInButton.alpha = 1.0
            
            onePassswordButton.isEnabled = true
            exitButton.isEnabled = true
            signInButton.isEnabled = true
        }
    }
    
    private func sendToNextViewController() {
        if OneSignal.getPermissionSubscriptionState().permissionStatus.status != .notDetermined {
            performSegue(withIdentifier: "unwindToPresenting", sender: self)
        } else {
            performSegue(withIdentifier: "showAppServicesRequestViewController", sender: self)
        }
    }
    
    // MARK: - Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if let vc = segue.destination as? RecoverPasswordViewController {
            vc.preloadedEmailAddress = emailTextField.text
        }
    }
    
    // MARK: - Firebase
    
    private func saveOneSignalId() {
        OneSignal.idsAvailable() { userId, pushToken in
            if let id = userId {
                let ref = FIRDatabase.database().reference().child("users").child(FIRAuth.auth()!.currentUser!.uid).child("pushNotificationIds")
                ref.observeSingleEvent(of: .value, with: { snapshot in
                    if var ids = snapshot.value as? [String: Bool] {
                        ids[id] = true
                        ref.updateChildValues(ids)
                    } else {
                        let ids = [id: true]
                        ref.updateChildValues(ids)
                    }
                })
            }
        }
    }
    
}
