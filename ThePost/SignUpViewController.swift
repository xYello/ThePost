//
//  SignUpViewController.swift
//  ThePost
//
//  Created by Andrew Robinson on 12/23/16.
//  Copyright © 2016 The Post. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {

    @IBOutlet weak var usernameTextField: RoundedTextField!
    @IBOutlet weak var emailTextField: RoundedTextField!
    @IBOutlet weak var passwordTextField: RoundedTextField!
    @IBOutlet weak var confirmPasswordTextField: RoundedTextField!
    
    private var usernameImageView:UIImageView!
    private var emailImageView:UIImageView!
    private var passwordImageView:UIImageView!
    private var confirmPasswordImageView:UIImageView!
    
    @IBOutlet weak var redIndicator: UIView!
    @IBOutlet weak var yellowIndicator: UIView!
    @IBOutlet weak var greenIndicator: UIView!
    
    @IBOutlet weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameImageView = UIImageView(image: UIImage(named: "UsernameAvatar")!.withRenderingMode(.alwaysTemplate))
        formatTextField(field: usernameTextField, withImageView: usernameImageView)
        
        emailImageView = UIImageView(image: UIImage(named: "Mail")!.withRenderingMode(.alwaysTemplate))
        formatTextField(field: emailTextField, withImageView: emailImageView)
        
        passwordImageView = UIImageView(image: UIImage(named: "Password")!.withRenderingMode(.alwaysTemplate))
        formatTextField(field: passwordTextField, withImageView: passwordImageView)
        
        confirmPasswordImageView = UIImageView(image: UIImage(named: "ConfirmPasswordCheck")!.withRenderingMode(.alwaysTemplate))
        formatTextField(field: confirmPasswordTextField, withImageView: confirmPasswordImageView)
        
        redIndicator.layer.cornerRadius = 10.0
        yellowIndicator.layer.cornerRadius = 10.0
        greenIndicator.layer.cornerRadius = 10.0
        
        signUpButton.layer.cornerRadius = 25.0
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tapped))
        view.addGestureRecognizer(gesture)
    }
    
    // MARK: - Actions
    
    @objc private func tapped() {
        for otherView in view.subviews {
            if otherView is UITextField {
                otherView.resignFirstResponder()
            }
        }
    }
    
    @IBAction func editingChanged(_ sender: RoundedTextField) {
        if sender.placeholder == "Username" {
            if let text = sender.text {
                if text.characters.count >= 4 {
                    usernameImageView.tintColor = #colorLiteral(red: 0.1464666128, green: 0.6735964417, blue: 0.3412255645, alpha: 1)
                } else {
                    usernameImageView.tintColor = #colorLiteral(red: 0.8552903533, green: 0.03449717909, blue: 0.01357735228, alpha: 1)
                }
            } else {
                usernameImageView.tintColor = #colorLiteral(red: 0.8552903533, green: 0.03449717909, blue: 0.01357735228, alpha: 1)
            }
        }
        
        else if sender.placeholder == "Email" {
            if let text = sender.text {
                if text.characters.count >= 5 && text.contains("@") && text.contains(".") {
                    emailImageView.tintColor = #colorLiteral(red: 0.1464666128, green: 0.6735964417, blue: 0.3412255645, alpha: 1)
                } else {
                    emailImageView.tintColor = #colorLiteral(red: 0.8552903533, green: 0.03449717909, blue: 0.01357735228, alpha: 1)
                }
            } else {
                emailImageView.tintColor = #colorLiteral(red: 0.8552903533, green: 0.03449717909, blue: 0.01357735228, alpha: 1)
            }
        }
        
        else if sender.placeholder == "Password" {
            if let text = sender.text {
                
                // TODO: Insert password strength logic here?
                if text.characters.count >= 1 {
                    passwordImageView.tintColor = #colorLiteral(red: 0.1464666128, green: 0.6735964417, blue: 0.3412255645, alpha: 1)
                } else {
                    passwordImageView.tintColor = #colorLiteral(red: 0.8552903533, green: 0.03449717909, blue: 0.01357735228, alpha: 1)
                }
            } else {
                passwordImageView.tintColor = #colorLiteral(red: 0.8552903533, green: 0.03449717909, blue: 0.01357735228, alpha: 1)
            }
        }
        
        else if sender.placeholder == "Confirm Password" {
            if let text = sender.text {
                if text == passwordTextField.text {
                    confirmPasswordImageView.tintColor = #colorLiteral(red: 0.1464666128, green: 0.6735964417, blue: 0.3412255645, alpha: 1)
                } else {
                    confirmPasswordImageView.tintColor = #colorLiteral(red: 0.8552903533, green: 0.03449717909, blue: 0.01357735228, alpha: 1)
                }
            } else {
                confirmPasswordImageView.tintColor = #colorLiteral(red: 0.8552903533, green: 0.03449717909, blue: 0.01357735228, alpha: 1)
            }
        }
    }
    
    
    // MARK: - Helpers
    
    private func formatTextField(field: UITextField, withImageView imageView: UIImageView) {
        field.layer.cornerRadius = 20.0
        field.attributedPlaceholder = NSAttributedString(string: field.placeholder!, attributes: [NSForegroundColorAttributeName: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.3503303272)])
        
        imageView.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        // Pad the image so it doesn't appear right in-line with the textfield border.
        if let size = imageView.image?.size {
            imageView.frame = CGRect(x: 0.0, y: 0.0, width: size.width + 15.0, height: size.height)
        }
        imageView.contentMode = .left
        
        field.rightViewMode = .always
        field.rightView = imageView
    }

}
