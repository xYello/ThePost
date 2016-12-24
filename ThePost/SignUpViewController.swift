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
    }
    
    // MARK: - Helpers
    
    private func formatTextField(field: UITextField, withImageView imageView: UIImageView) {
        field.layer.cornerRadius = 20.0
        field.attributedPlaceholder = NSAttributedString(string: field.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor.white])
        
        imageView.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        // Pad the image so it doesn't appear right in-line with the textfield border.
        if let size = imageView.image?.size {
            imageView.frame = CGRect(x: 0.0, y: 0.0, width: size.width + 15.0, height: size.height)
        }
        imageView.contentMode = .left
        
        field.rightViewMode = .always
        field.rightView = imageView
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        let duration = notification.userInfo![UIKeyboardAnimationCurveUserInfoKey] as! TimeInterval
        let curve = notification.userInfo![UIKeyboardAnimationCurveUserInfoKey] as! NSNumber
        let keyboardFrame = notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! CGRect
        let keyboardUpCenterY = (view.frame.height - keyboardFrame.height) / 2.0
        
        let textFieldsCenterY = usernameTextField.frame.origin.y + ((confirmPasswordTextField.frame.origin.y) - usernameTextField.frame.origin.y) / 2.0
        
        for otherView in view.subviews {
            if otherView is UITextField {
                let centerOffset = keyboardUpCenterY - (textFieldsCenterY - otherView.frame.origin.y)
                UIView.animate(withDuration: duration, delay: 0.0, options: UIViewAnimationOptions(rawValue: UInt(curve)), animations: {
                    otherView.frame = CGRect(x: otherView.frame.origin.x, y: centerOffset, width: otherView.frame.width, height: otherView.frame.height)
                }, completion: nil)
            } else {
                UIView.animate(withDuration: duration, delay: 0.0, options: UIViewAnimationOptions(rawValue: UInt(curve)), animations: {
                    otherView.alpha = 0.0
                }, completion: nil)
            }
        }
    }

}
