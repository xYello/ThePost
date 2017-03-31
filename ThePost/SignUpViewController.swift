//
//  SignUpViewController.swift
//  ThePost
//
//  Created by Andrew Robinson on 12/23/16.
//  Copyright © 2016 The Post. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper
import OneSignal

class SignUpViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var usernameTextField: RoundedTextField!
    @IBOutlet weak var emailTextField: RoundedTextField!
    @IBOutlet weak var passwordTextField: RoundedTextField!
    @IBOutlet weak var confirmPasswordTextField: RoundedTextField!
    
    private var usernameImageView: UIImageView!
    private var emailImageView: UIImageView!
    private var passwordImageView: UIImageView!
    private var confirmPasswordImageView: UIImageView!
    
    @IBOutlet weak var onePasswordButton: UIButton!
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var signUpButton: UIButton!
    
    @IBOutlet weak var welcomeLabelToViewTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var closeButton: UIButton!
    
    private var ref: FIRDatabaseReference!
    
    private var welcomeLabelToViewTopConstant: CGFloat = 0.0
    
    private var isTypingInTextField = false
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        onePasswordButton.isHidden = (false == OnePasswordExtension.shared().isAppExtensionAvailable())
        
        usernameImageView = UIImageView(image: UIImage(named: "UsernameAvatar")!.withRenderingMode(.alwaysTemplate))
        formatTextField(field: usernameTextField, withImageView: usernameImageView)
        
        emailImageView = UIImageView(image: UIImage(named: "Mail")!.withRenderingMode(.alwaysTemplate))
        formatTextField(field: emailTextField, withImageView: emailImageView)
        
        passwordImageView = UIImageView(image: UIImage(named: "Password")!.withRenderingMode(.alwaysTemplate))
        formatTextField(field: passwordTextField, withImageView: passwordImageView)
        
        confirmPasswordImageView = UIImageView(image: UIImage(named: "ConfirmPasswordCheck")!.withRenderingMode(.alwaysTemplate))
        formatTextField(field: confirmPasswordTextField, withImageView: confirmPasswordImageView)
        
        signUpButton.roundCorners()
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tapped))
        view.addGestureRecognizer(gesture)
        
        ref = FIRDatabase.database().reference()
    }
    
    // MARK: Textfield delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === usernameTextField {
            emailTextField.becomeFirstResponder()
        } else if textField === emailTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField === passwordTextField {
            confirmPasswordTextField.becomeFirstResponder()
        } else {
            signUpButton.sendActions(for: .touchUpInside)
        }
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if !isTypingInTextField {
            isTypingInTextField = true
            
            welcomeLabelToViewTopConstant = welcomeLabelToViewTopConstraint.constant
            welcomeLabelToViewTopConstraint.constant = -usernameTextField.frame.origin.y + usernameTextField.frame.height + 28
            
            UIView.animate(withDuration: 0.25, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if !isTypingInTextField {
            welcomeLabelToViewTopConstraint.constant = welcomeLabelToViewTopConstant
            
            UIView.animate(withDuration: 0.25, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }
    
    // MARK: - Actions
    
    @objc private func tapped() {
        isTypingInTextField = false
        view.endEditing(false)
    }
    
    @IBAction func saveLoginTo1Password(_ sender: UIButton) {
        
        let newLoginDetails: [String: Any] = [
            AppExtensionTitleKey: "The Wave",
            AppExtensionUsernameKey: emailTextField.text!,
            AppExtensionPasswordKey: passwordTextField.text!,
            AppExtensionNotesKey: "Saved with The Wave app!",
            AppExtensionSectionTitleKey: "The Wave Browser",
            AppExtensionFieldsKey: ["fullname" : usernameTextField.text!]
        ]
        
        let passwordGenerationOptions: [String: Any] = [AppExtensionGeneratedPasswordMinLengthKey: (6), AppExtensionGeneratedPasswordMaxLengthKey: (50)]
        
        OnePasswordExtension.shared().storeLogin(forURLString: "http://thewaveapp.com/", loginDetails: newLoginDetails, passwordGenerationOptions: passwordGenerationOptions, for: self, sender: sender) { (loginDictionary, error) -> Void in
            if loginDictionary != nil {
                self.emailTextField.text = loginDictionary?[AppExtensionUsernameKey] as? String
                self.passwordTextField.text = loginDictionary?[AppExtensionPasswordKey] as? String
                self.confirmPasswordTextField.text = self.passwordTextField.text
                
                self.checkInputText(withField: "Email", withText: self.emailTextField.text)
                self.checkInputText(withField: "Password", withText: self.passwordTextField.text)
                self.checkInputText(withField: "Confirm Password", withText: self.confirmPasswordTextField.text)
                
                if let extras = loginDictionary?[AppExtensionReturnedFieldsKey] as? [String: Any] {
                    self.usernameTextField.text = extras["fullname"] as? String
                    self.checkInputText(withField: "Full Name", withText: self.usernameTextField.text)
                }
            }
        }
        
    }
    
    @IBAction func editingChanged(_ sender: RoundedTextField) {
        if sender.placeholder == "Full Name" {
            checkInputText(withField: "Full Name", withText: sender.text)
        }
        
        else if sender.placeholder == "Email" {
            checkInputText(withField: "Email", withText: sender.text)
            
            if !errorLabel.isHidden {
                errorLabel.isHidden = true
            }
        }
        
        else if sender.placeholder == "Password" {
            checkInputText(withField: "Password", withText: sender.text)
        }
        
        else if sender.placeholder == "Confirm Password" {
            checkInputText(withField: "Confirm Password", withText: sender.text)
        }
    }
    
    @IBAction func signUp(_ sender: UIButton) {
        var viewsToShake:[UIView] = []
        if usernameImageView.tintColor != #colorLiteral(red: 0.1464666128, green: 0.6735964417, blue: 0.3412255645, alpha: 1) {
            viewsToShake.append(usernameTextField)
        }
        
        if emailImageView.tintColor != #colorLiteral(red: 0.1464666128, green: 0.6735964417, blue: 0.3412255645, alpha: 1) {
            viewsToShake.append(emailTextField)
        }
        
        if passwordImageView.tintColor != #colorLiteral(red: 0.1464666128, green: 0.6735964417, blue: 0.3412255645, alpha: 1) {
            viewsToShake.append(passwordTextField)
        }
        
        if confirmPasswordImageView.tintColor != #colorLiteral(red: 0.1464666128, green: 0.6735964417, blue: 0.3412255645, alpha: 1) {
            viewsToShake.append(confirmPasswordTextField)
        }
        
        if viewsToShake.isEmpty {
            // Sign up
            
            disableButtons()
            
            FIRAuth.auth()?.createUser(withEmail: emailTextField.text!, password: passwordTextField.text!, completion: { user, error in
                guard let user = user, error == nil else {
                    // TODO: Update with error reporting.
                    print("Error signing up: \(error!.localizedDescription)")
                    
                    if error!.localizedDescription == "The email address is already in use by another account." {
                        self.errorLabel.isHidden = false
                        self.errorLabel.text = error!.localizedDescription
                        self.emailImageView.tintColor = #colorLiteral(red: 0.8470588235, green: 0.337254902, blue: 0.2156862745, alpha: 1)
                    }
                    
                    self.disableButtons()
                    
                    return
                }
                
                let changeRequest = FIRAuth.auth()!.currentUser!.profileChangeRequest()
                changeRequest.displayName = self.usernameTextField.text
                
                changeRequest.commitChanges() { error in
                    guard error == nil else {
                        // TODO: Update with error reporting.
                        print("Error saving changes: \(error!.localizedDescription)")
                        self.disableButtons()
                        return
                    }
                    
                    KeychainWrapper.standard.set(self.passwordTextField.text!, forKey: UserInfoKeys.UserPass)
                    self.ref.child("users").child(user.uid).setValue(["fullName": self.usernameTextField.text, "email": self.emailTextField.text])
                    self.ref.child("users").child(user.uid).child("isOnline").setValue(true)
                    self.saveOneSignalId()
                    self.performSegue(withIdentifier: "walkthroughSegue", sender: self)
                }
            })
            
        } else {
            for view in viewsToShake {
                shakeView(view: view)
            }
        }
    }
    
    // MARK: - Helpers
    
    private func formatTextField(field: UITextField, withImageView imageView: UIImageView) {
        field.roundCorners()
        field.delegate = self
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
    
    private func shakeView(view: UIView) {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.08
        animation.repeatCount = 2
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: view.center.x - 10, y: view.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: view.center.x + 10, y: view.center.y))
        view.layer.add(animation, forKey: "position")
    }
    
    private func checkInputText(withField field: String, withText text: String?) {
        if field == "Full Name" {
            if let text = text {
                if text.characters.count >= 4 {
                    usernameImageView.tintColor = #colorLiteral(red: 0.1464666128, green: 0.6735964417, blue: 0.3412255645, alpha: 1)
                } else {
                    usernameImageView.tintColor = #colorLiteral(red: 0.8470588235, green: 0.337254902, blue: 0.2156862745, alpha: 1)
                }
            } else {
                usernameImageView.tintColor = #colorLiteral(red: 0.8470588235, green: 0.337254902, blue: 0.2156862745, alpha: 1)
            }
        }
            
        else if field == "Email" {
            if let text = text {
                if text.characters.count >= 5 && text.contains("@") && text.contains(".") {
                    emailImageView.tintColor = #colorLiteral(red: 0.1464666128, green: 0.6735964417, blue: 0.3412255645, alpha: 1)
                } else {
                    emailImageView.tintColor = #colorLiteral(red: 0.8470588235, green: 0.337254902, blue: 0.2156862745, alpha: 1)
                }
            } else {
                emailImageView.tintColor = #colorLiteral(red: 0.8470588235, green: 0.337254902, blue: 0.2156862745, alpha: 1)
            }
        }
            
        else if field == "Password" {
            if let text = text {
                if text.characters.count > 5 {
                    passwordImageView.tintColor = #colorLiteral(red: 0.1464666128, green: 0.6735964417, blue: 0.3412255645, alpha: 1)
                } else {
                    passwordImageView.tintColor = #colorLiteral(red: 0.8470588235, green: 0.337254902, blue: 0.2156862745, alpha: 1)
                }
                
                if text == confirmPasswordTextField.text {
                    confirmPasswordImageView.tintColor = #colorLiteral(red: 0.1464666128, green: 0.6735964417, blue: 0.3412255645, alpha: 1)
                } else {
                    confirmPasswordImageView.tintColor = #colorLiteral(red: 0.8470588235, green: 0.337254902, blue: 0.2156862745, alpha: 1)
                }
            } else {
                passwordImageView.tintColor = #colorLiteral(red: 0.8470588235, green: 0.337254902, blue: 0.2156862745, alpha: 1)
            }
        }
            
        else if field == "Confirm Password" {
            if let text = text {
                if text == passwordTextField.text {
                    confirmPasswordImageView.tintColor = #colorLiteral(red: 0.1464666128, green: 0.6735964417, blue: 0.3412255645, alpha: 1)
                } else {
                    confirmPasswordImageView.tintColor = #colorLiteral(red: 0.8470588235, green: 0.337254902, blue: 0.2156862745, alpha: 1)
                }
            } else {
                confirmPasswordImageView.tintColor = #colorLiteral(red: 0.8470588235, green: 0.337254902, blue: 0.2156862745, alpha: 1)
            }
        }
    }
    
    private func disableButtons() {
        if signUpButton.isEnabled {
            onePasswordButton.alpha = 0.75
            closeButton.alpha = 0.75
            signUpButton.alpha = 0.75
            
            onePasswordButton.isEnabled = false
            closeButton.isEnabled = false
            signUpButton.isEnabled = false
        } else {
            onePasswordButton.alpha = 1.0
            closeButton.alpha = 1.0
            signUpButton.alpha = 1.0
            
            onePasswordButton.isEnabled = true
            closeButton.isEnabled = true
            signUpButton.isEnabled = true
        }
    }
    
    // MARK: - Firebase
    
    private func saveOneSignalId() {
        OneSignal.idsAvailable() { userId, pushToken in
            if let id = userId {
                let ref = self.ref.child("users").child(FIRAuth.auth()!.currentUser!.uid).child("pushNotificationIds")
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
