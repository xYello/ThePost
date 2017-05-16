//
//  SettingsContainerViewController.swift
//  ThePost
//
//  Created by Andrew Robinson on 2/11/17.
//  Copyright © 2017 The Post. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper
import FBSDKLoginKit
import OneSignal

class SettingsContainerViewController: UIViewController {
    
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var fullNameTextField: UITextField!
    
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var passwordContainer: UIView!
    @IBOutlet weak var confirmPasswordContainer: UIView!
    
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordLabel: UILabel!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    
    var fullName: String!
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.roundCorners(radius: 8.0)
        view.clipsToBounds = true
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tapped))
        view.addGestureRecognizer(gesture)
        
        fullNameTextField.text = fullName
        
        if KeychainWrapper.standard.string(forKey: UserInfoKeys.UserPass) == nil {
            categoryLabel.isHidden = true
            passwordContainer.isHidden = true
            confirmPasswordContainer.isHidden = true
        }
        
        saveButton.roundCorners(radius: 8.0)
        saveButton.alpha = 0.0
        
        closeButton.layer.borderColor = closeButton.titleLabel!.textColor.cgColor
        closeButton.layer.borderWidth = 1.0
        closeButton.roundCorners(radius: 8.0)
    }
    
    // MARK: - Actions
    
    @IBAction func fullNameTextFieldChanged(_ sender: UITextField) {
        if saveButton.alpha != 1.0 {
            UIView.animate(withDuration: 0.25, animations: {
                self.saveButton.alpha = 1.0
            })
        }
        
        if let text = sender.text {
            if text.characters.count >= 4 {
                fullNameLabel.textColor = #colorLiteral(red: 0.1464666128, green: 0.6735964417, blue: 0.3412255645, alpha: 1)
            } else {
                fullNameLabel.textColor = #colorLiteral(red: 0.8470588235, green: 0.337254902, blue: 0.2156862745, alpha: 1)
            }
        } else {
            fullNameLabel.textColor = #colorLiteral(red: 0.8470588235, green: 0.337254902, blue: 0.2156862745, alpha: 1)
        }
    }
    
    @IBAction func passwordTextFieldEditingChanged(_ sender: UITextField) {
        if saveButton.alpha != 1.0 {
            UIView.animate(withDuration: 0.25, animations: {
                self.saveButton.alpha = 1.0
            })
        }
        
        if let text = sender.text {
            if text.characters.count > 5 {
                passwordLabel.textColor = #colorLiteral(red: 0.1464666128, green: 0.6735964417, blue: 0.3412255645, alpha: 1)
            } else {
                passwordLabel.textColor = #colorLiteral(red: 0.8470588235, green: 0.337254902, blue: 0.2156862745, alpha: 1)
            }
            
            if text == confirmPasswordTextField.text {
                confirmPasswordLabel.textColor = #colorLiteral(red: 0.1464666128, green: 0.6735964417, blue: 0.3412255645, alpha: 1)
            } else {
                confirmPasswordLabel.textColor = #colorLiteral(red: 0.8470588235, green: 0.337254902, blue: 0.2156862745, alpha: 1)
            }
        } else {
            passwordLabel.textColor = #colorLiteral(red: 0.8470588235, green: 0.337254902, blue: 0.2156862745, alpha: 1)
        }
    }
    
    @IBAction func confirmPasswordTextFieldEditingChanged(_ sender: UITextField) {
        if let text = sender.text {
            if text == passwordTextField.text {
                confirmPasswordLabel.textColor = #colorLiteral(red: 0.1464666128, green: 0.6735964417, blue: 0.3412255645, alpha: 1)
            } else {
                confirmPasswordLabel.textColor = #colorLiteral(red: 0.8470588235, green: 0.337254902, blue: 0.2156862745, alpha: 1)
            }
        } else {
            confirmPasswordLabel.textColor = #colorLiteral(red: 0.8470588235, green: 0.337254902, blue: 0.2156862745, alpha: 1)
        }
    }
    
    @objc private func tapped() {
        view.endEditing(false)
    }
    
    @IBAction func wantsToLogout(_ sender: UIButton) {
        let ref = FIRDatabase.database().reference().child("users").child(FIRAuth.auth()!.currentUser!.uid)
        ref.child("isOnline").removeValue()
        
        if let id = OneSignal.getPermissionSubscriptionState().subscriptionStatus.userId {
            ref.child("pushNotificationIds").child(id).removeValue()
        }
        
        do {
            try FIRAuth.auth()?.signOut()
            
            KeychainWrapper.standard.removeObject(forKey: UserInfoKeys.UserPass)
            
            FBSDKLoginManager().logOut()
            
            KeychainWrapper.standard.removeObject(forKey: TwitterInfoKeys.token)
            KeychainWrapper.standard.removeObject(forKey: TwitterInfoKeys.secret)
            
            self.dismissParent()
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: logoutNotificationKey), object: nil, userInfo: nil)
        } catch {
            FIRDatabase.database().reference().child("users").child(FIRAuth.auth()!.currentUser!.uid).child("isOnline").setValue(true)
            print("Error signing out")
        }
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        
        if passwordLabel.textColor == #colorLiteral(red: 0.1464666128, green: 0.6735964417, blue: 0.3412255645, alpha: 1) && confirmPasswordLabel.textColor == #colorLiteral(red: 0.1464666128, green: 0.6735964417, blue: 0.3412255645, alpha: 1) {
            FIRAuth.auth()!.currentUser!.updatePassword(passwordTextField.text!, completion: { error in
                if let error = error {
                    print("Error saving password: \(error.localizedDescription)")
                } else {
                    KeychainWrapper.standard.set(self.passwordTextField.text!, forKey: UserInfoKeys.UserPass)
                }
            })
        }
        
        if fullName != fullNameTextField.text && fullNameLabel.textColor == #colorLiteral(red: 0.1464666128, green: 0.6735964417, blue: 0.3412255645, alpha: 1) {
            let ref = FIRDatabase.database().reference().child("users").child(FIRAuth.auth()!.currentUser!.uid)
            let updates = ["fullName": fullNameTextField.text!]
            ref.updateChildValues(updates) { error, ref in
                if let error = error {
                    print("Error saving name: \(error.localizedDescription)")
                } else {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: nameChangeNotificationKey), object: nil, userInfo: nil)
                }
            }
        }
        
        dismissParent()
    }
    
    @IBAction func closeButtonPressed(_ sender: UIButton) {
        dismissParent()
    }
    
    // MARK: - Helpers
    
    private func dismissParent() {
        if let parent = parent as? SettingsViewController {
            parent.prepareForDismissal {
                parent.dismiss(animated: false, completion: nil)
            }
        }
    }

}
