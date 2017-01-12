//
//  CreateReviewContainerViewController.swift
//  ThePost
//
//  Created by Andrew Robinson on 1/11/17.
//  Copyright © 2017 The Post. All rights reserved.
//

import UIKit

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
    
    private var amountOfStars = 0
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.roundCorners(radius: 8.0)
        view.clipsToBounds = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        imageView.roundCorners()
        
        questionLabel.text = "Overall, how would you rate Ethan Andrews through the process of your purchase?"
        
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
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
                
                let textViewBottomY = textView.frame.origin.y + textView.frame.height
                let distanceToTopKeyboardY = textViewBottomY - keyboardRect.origin.y
                
                UIView.animate(withDuration: duration, delay: 0.0, options: animationCurve, animations: {
                    self.view.frame = CGRect(x: self.view.frame.origin.x,
                                             y: self.view.frame.origin.y - 2 * distanceToTopKeyboardY,
                                             width: self.view.frame.width,
                                             height: self.view.frame.height + 2 * distanceToTopKeyboardY)
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
        farLeftStar.tintColor = #colorLiteral(red: 0.9529411765, green: 0.6274509804, blue: 0.09803921569, alpha: 1)
        
        leftMidStar.tintColor = #colorLiteral(red: 0.7215686275, green: 0.7607843137, blue: 0.7803921569, alpha: 1)
        midStar.tintColor = #colorLiteral(red: 0.7215686275, green: 0.7607843137, blue: 0.7803921569, alpha: 1)
        rightMidStar.tintColor = #colorLiteral(red: 0.7215686275, green: 0.7607843137, blue: 0.7803921569, alpha: 1)
        farRightStar.tintColor = #colorLiteral(red: 0.7215686275, green: 0.7607843137, blue: 0.7803921569, alpha: 1)
        
        amountOfStars = 1
    }
    
    @IBAction func leftMidPressed(_ sender: UIButton) {
        farLeftStar.tintColor = #colorLiteral(red: 0.9529411765, green: 0.6274509804, blue: 0.09803921569, alpha: 1)
        leftMidStar.tintColor = #colorLiteral(red: 0.9529411765, green: 0.6274509804, blue: 0.09803921569, alpha: 1)
        
        midStar.tintColor = #colorLiteral(red: 0.7215686275, green: 0.7607843137, blue: 0.7803921569, alpha: 1)
        rightMidStar.tintColor = #colorLiteral(red: 0.7215686275, green: 0.7607843137, blue: 0.7803921569, alpha: 1)
        farRightStar.tintColor = #colorLiteral(red: 0.7215686275, green: 0.7607843137, blue: 0.7803921569, alpha: 1)
        
        amountOfStars = 2
    }
    
    @IBAction func midPressed(_ sender: UIButton) {
        
        farLeftStar.tintColor = #colorLiteral(red: 0.9529411765, green: 0.6274509804, blue: 0.09803921569, alpha: 1)
        leftMidStar.tintColor = #colorLiteral(red: 0.9529411765, green: 0.6274509804, blue: 0.09803921569, alpha: 1)
        midStar.tintColor = #colorLiteral(red: 0.9529411765, green: 0.6274509804, blue: 0.09803921569, alpha: 1)
        
        rightMidStar.tintColor = #colorLiteral(red: 0.7215686275, green: 0.7607843137, blue: 0.7803921569, alpha: 1)
        farRightStar.tintColor = #colorLiteral(red: 0.7215686275, green: 0.7607843137, blue: 0.7803921569, alpha: 1)
        
        amountOfStars = 3
    }
    
    @IBAction func rightMidPressed(_ sender: UIButton) {
        farLeftStar.tintColor = #colorLiteral(red: 0.9529411765, green: 0.6274509804, blue: 0.09803921569, alpha: 1)
        leftMidStar.tintColor = #colorLiteral(red: 0.9529411765, green: 0.6274509804, blue: 0.09803921569, alpha: 1)
        midStar.tintColor = #colorLiteral(red: 0.9529411765, green: 0.6274509804, blue: 0.09803921569, alpha: 1)
        rightMidStar.tintColor = #colorLiteral(red: 0.9529411765, green: 0.6274509804, blue: 0.09803921569, alpha: 1)
        
        farRightStar.tintColor = #colorLiteral(red: 0.7215686275, green: 0.7607843137, blue: 0.7803921569, alpha: 1)
        
        amountOfStars = 4
    }
    
    @IBAction func farRightPressed(_ sender: UIButton) {
        farLeftStar.tintColor = #colorLiteral(red: 0.9529411765, green: 0.6274509804, blue: 0.09803921569, alpha: 1)
        leftMidStar.tintColor = #colorLiteral(red: 0.9529411765, green: 0.6274509804, blue: 0.09803921569, alpha: 1)
        midStar.tintColor = #colorLiteral(red: 0.9529411765, green: 0.6274509804, blue: 0.09803921569, alpha: 1)
        rightMidStar.tintColor = #colorLiteral(red: 0.9529411765, green: 0.6274509804, blue: 0.09803921569, alpha: 1)
        farRightStar.tintColor = #colorLiteral(red: 0.9529411765, green: 0.6274509804, blue: 0.09803921569, alpha: 1)
        
        amountOfStars = 5
    }
    
    @objc private func viewTapped() {
        view.endEditing(false)
    }
    
    @IBAction func wantsToCancel(_ sender: UIButton) {
        dismissParent()
    }
    
    @IBAction func wantsToSubmit(_ sender: UIButton) {
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
    
}
