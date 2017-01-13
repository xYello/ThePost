//
//  CreateReviewContainerViewController.swift
//  ThePost
//
//  Created by Andrew Robinson on 1/11/17.
//  Copyright © 2017 The Post. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class CreateReviewContainerViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var questionLabel: UILabel!
    
    @IBOutlet weak var farLeftStar: UIImageView!
    @IBOutlet weak var leftMidStar: UIImageView!
    @IBOutlet weak var midStar: UIImageView!
    @IBOutlet weak var rightMidStar: UIImageView!
    @IBOutlet weak var farRightStar: UIImageView!
    
    @IBOutlet weak var fakePlaceholderLabel: UILabel!
    
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    
    private var originalViewFrame: CGRect?
    
    private var hasReviewedBefore = false
    
    private var amountOfStars = 0 {
        didSet {
            switch amountOfStars {
            case 1:
                farLeftStar.tintColor = #colorLiteral(red: 0.9529411765, green: 0.6274509804, blue: 0.09803921569, alpha: 1)
                
                leftMidStar.tintColor = #colorLiteral(red: 0.7215686275, green: 0.7607843137, blue: 0.7803921569, alpha: 1)
                midStar.tintColor = #colorLiteral(red: 0.7215686275, green: 0.7607843137, blue: 0.7803921569, alpha: 1)
                rightMidStar.tintColor = #colorLiteral(red: 0.7215686275, green: 0.7607843137, blue: 0.7803921569, alpha: 1)
                farRightStar.tintColor = #colorLiteral(red: 0.7215686275, green: 0.7607843137, blue: 0.7803921569, alpha: 1)
            case 2:
                farLeftStar.tintColor = #colorLiteral(red: 0.9529411765, green: 0.6274509804, blue: 0.09803921569, alpha: 1)
                leftMidStar.tintColor = #colorLiteral(red: 0.9529411765, green: 0.6274509804, blue: 0.09803921569, alpha: 1)
                
                midStar.tintColor = #colorLiteral(red: 0.7215686275, green: 0.7607843137, blue: 0.7803921569, alpha: 1)
                rightMidStar.tintColor = #colorLiteral(red: 0.7215686275, green: 0.7607843137, blue: 0.7803921569, alpha: 1)
                farRightStar.tintColor = #colorLiteral(red: 0.7215686275, green: 0.7607843137, blue: 0.7803921569, alpha: 1)
            case 3:
                farLeftStar.tintColor = #colorLiteral(red: 0.9529411765, green: 0.6274509804, blue: 0.09803921569, alpha: 1)
                leftMidStar.tintColor = #colorLiteral(red: 0.9529411765, green: 0.6274509804, blue: 0.09803921569, alpha: 1)
                midStar.tintColor = #colorLiteral(red: 0.9529411765, green: 0.6274509804, blue: 0.09803921569, alpha: 1)
                
                rightMidStar.tintColor = #colorLiteral(red: 0.7215686275, green: 0.7607843137, blue: 0.7803921569, alpha: 1)
                farRightStar.tintColor = #colorLiteral(red: 0.7215686275, green: 0.7607843137, blue: 0.7803921569, alpha: 1)
            case 4:
                farLeftStar.tintColor = #colorLiteral(red: 0.9529411765, green: 0.6274509804, blue: 0.09803921569, alpha: 1)
                leftMidStar.tintColor = #colorLiteral(red: 0.9529411765, green: 0.6274509804, blue: 0.09803921569, alpha: 1)
                midStar.tintColor = #colorLiteral(red: 0.9529411765, green: 0.6274509804, blue: 0.09803921569, alpha: 1)
                rightMidStar.tintColor = #colorLiteral(red: 0.9529411765, green: 0.6274509804, blue: 0.09803921569, alpha: 1)
                
                farRightStar.tintColor = #colorLiteral(red: 0.7215686275, green: 0.7607843137, blue: 0.7803921569, alpha: 1)
            default:
                farLeftStar.tintColor = #colorLiteral(red: 0.9529411765, green: 0.6274509804, blue: 0.09803921569, alpha: 1)
                leftMidStar.tintColor = #colorLiteral(red: 0.9529411765, green: 0.6274509804, blue: 0.09803921569, alpha: 1)
                midStar.tintColor = #colorLiteral(red: 0.9529411765, green: 0.6274509804, blue: 0.09803921569, alpha: 1)
                rightMidStar.tintColor = #colorLiteral(red: 0.9529411765, green: 0.6274509804, blue: 0.09803921569, alpha: 1)
                farRightStar.tintColor = #colorLiteral(red: 0.9529411765, green: 0.6274509804, blue: 0.09803921569, alpha: 1)
            }
        }
    }
    
    var product: Product!
    var userId: String!
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.roundCorners(radius: 8.0)
        view.clipsToBounds = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(viewTapped))
        view.addGestureRecognizer(pan)
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        let string = formatter.string(from: floor(product.price) as NSNumber)
        let endIndex = string!.index(string!.endIndex, offsetBy: -3)
        let truncated = string!.substring(to: endIndex) // Remove the .00 from the price.
        priceLabel.text = truncated
        
        imageView.roundCorners()
        
        questionLabel.text = ""
        
        formatStar(farLeftStar)
        formatStar(leftMidStar)
        formatStar(midStar)
        formatStar(rightMidStar)
        formatStar(farRightStar)
        
        textView.delegate = self
        
        cancelButton.layer.borderColor = cancelButton.titleLabel!.textColor.cgColor
        cancelButton.layer.borderWidth = 1.0
        cancelButton.roundCorners(radius: 8.0)
        
        submitButton.roundCorners(radius: 8.0)
        submitButton.isEnabled = false
        submitButton.backgroundColor = UIColor.clear
        checkIfPreviouslyReviewed()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
        
        grabProfileDetails()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        originalViewFrame = view.frame
    }
    
    // MARK: - Notifications
    
    @objc private func keyboardWillShow(_ notification: NSNotification) {
        if view.frame.origin.y == originalViewFrame?.origin.y {
            if let userInfo = notification.userInfo {
                let keyboardRect = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
                let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
                let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber
                let animationCurveRaw = animationCurveRawNSN.uintValue
                let animationCurve  = UIViewAnimationOptions(rawValue: animationCurveRaw)
                
                let endViewFrame = CGRect(x: view.frame.origin.x, y: view.frame.origin.y - textView.frame.origin.y, width: view.frame.width, height: view.frame.height)
                let viewExpansion = keyboardRect.origin.y - endViewFrame.origin.y - endViewFrame.height
                
                UIView.animate(withDuration: duration, delay: 0.0, options: animationCurve, animations: {
                    self.view.frame = CGRect(x: self.view.frame.origin.x,
                                             y: self.view.frame.origin.y - self.textView.frame.origin.y,
                                             width: self.view.frame.width,
                                             height: self.view.frame.height + viewExpansion)
                }, completion: nil)
            }
        }
    }
    
    @objc private func keyboardWillHide(_ notification: NSNotification) {
        if let frame = originalViewFrame {
            if let userInfo = notification.userInfo {
                let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
                let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber
                let animationCurveRaw = animationCurveRawNSN.uintValue
                let animationCurve  = UIViewAnimationOptions(rawValue: animationCurveRaw)
                
                UIView.animate(withDuration: duration, delay: 0.0, options: animationCurve, animations: {
                    self.view.frame = frame
                }, completion: nil)
            }
        }
    }
    
    // MARK: - TextView delegate
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        fakePlaceholderLabel.isHidden = true
    }
    
    // MARK: - Actions
    
    @IBAction func farLeftPressed(_ sender: UIButton) {
        amountOfStars = 1
    }
    
    @IBAction func leftMidPressed(_ sender: UIButton) {
        amountOfStars = 2
    }
    
    @IBAction func midPressed(_ sender: UIButton) {
        amountOfStars = 3
    }
    
    @IBAction func rightMidPressed(_ sender: UIButton) {
        amountOfStars = 4
    }
    
    @IBAction func farRightPressed(_ sender: UIButton) {
        amountOfStars = 5
    }
    
    @objc private func viewTapped() {
        view.endEditing(false)
    }
    
    @IBAction func wantsToCancel(_ sender: UIButton) {
        dismissParent()
    }
    
    @IBAction func wantsToSubmit(_ sender: UIButton) {
        
        var viewsToShake: [UIView] = []
        
        if amountOfStars == 0 {
            viewsToShake.append(farLeftStar)
            viewsToShake.append(leftMidStar)
            viewsToShake.append(midStar)
            viewsToShake.append(rightMidStar)
            viewsToShake.append(farRightStar)
        }
        
        if textView.text == "" {
            viewsToShake.append(fakePlaceholderLabel)
            fakePlaceholderLabel.isHidden = false
        }
        
        if viewsToShake.count == 0 && fakePlaceholderLabel.isHidden {
            if let uid = FIRAuth.auth()?.currentUser?.uid {
                if let city = KeychainWrapper.standard.string(forKey: "userCity"), let state = KeychainWrapper.standard.string(forKey: "userState") {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "MM/dd/yy HH:mm:ss"
                    formatter.timeZone = TimeZone(identifier: "America/New_York")
                    let now = formatter.string(from: Date())
                    
                    let review: [String: Any] = ["rating": amountOfStars,
                                                 "timeReviewed": now,
                                                 "comment": textView.text,
                                                 "reviewerCity": city,
                                                 "reviewerState": state]
                    
                    let ref = FIRDatabase.database().reference().child("user-reviews").child(userId)
                    let childUpdates = [product.uid: review]
                    ref.child(uid).updateChildValues(childUpdates)
                    
                    if !hasReviewedBefore {
                        ref.child("reviewCount").runTransactionBlock({ (currentData: FIRMutableData) -> FIRTransactionResult in
                            if let count = currentData.value as? Int {
                                currentData.value = count + 1
                                
                                return FIRTransactionResult.success(withValue: currentData)
                            } else {
                                currentData.value = 1
                            }
                            return FIRTransactionResult.success(withValue: currentData)
                        }) { (error, committed, snapshot) in
                            if let error = error {
                                print(error.localizedDescription)
                            }
                        }
                    }
                }
                
                dismissParent()
            }
        } else {
            for view in viewsToShake {
                shakeView(view: view)
            }
        }
        
    }
    
    // MARK: - Helpers
    
    private func formatStar(_ star: UIImageView) {
        star.image = star.image!.withRenderingMode(.alwaysTemplate)
        star.tintColor = #colorLiteral(red: 0.7215686275, green: 0.7607843137, blue: 0.7803921569, alpha: 1)
    }
    
    private func dismissParent() {
        if let parent = parent as? CreateReviewViewController {
            parent.prepareForDismissal {
                parent.dismiss(animated: false, completion: nil)
            }
        }
    }
    
    private func grabProfileDetails() {
        let userRef = FIRDatabase.database().reference().child("users").child(userId).child("fullName")
        userRef.observeSingleEvent(of: .value, with: { snapshot in
            if let name = snapshot.value as? String {
                DispatchQueue.main.async {
                    self.questionLabel.text = "Overall, how would you rate \(name) through the process of your purchase?"
                }
            }
        })
    }
    
    private func checkIfPreviouslyReviewed() {
        if let uid = FIRAuth.auth()?.currentUser?.uid {
            let ref = FIRDatabase.database().reference().child("user-reviews").child(userId).child(uid)
            ref.observeSingleEvent(of: .value, with: { snapshot in
                if let review = snapshot.value as? [String: AnyObject] {
                    if let review = review[self.product.uid] as? [String: Any] {
                        self.hasReviewedBefore = true
                        
                        DispatchQueue.main.async {
                            self.amountOfStars = review["rating"] as! Int
                            self.textView.text = review["comment"] as! String
                            self.fakePlaceholderLabel.isHidden = true
                            
                            self.submitButton.isEnabled = true
                            self.submitButton.backgroundColor = #colorLiteral(red: 0.8470588235, green: 0.337254902, blue: 0.2156862745, alpha: 1)
                        }
                    }
                }
                
                DispatchQueue.main.async {
                    self.submitButton.isEnabled = true
                    self.submitButton.backgroundColor = #colorLiteral(red: 0.8470588235, green: 0.337254902, blue: 0.2156862745, alpha: 1)
                }
            })
        }
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
    
}
