//
//  SignInUpPromptViewController.swift
//  ThePost
//
//  Created by Andrew Robinson on 1/5/17.
//  Copyright © 2017 The Post. All rights reserved.
//

import UIKit

class SignInUpPromptViewController: UIViewController {

    @IBOutlet weak var container: UIView!
    
    @IBOutlet weak var signUpText: UILabel!
    
    @IBOutlet weak var signInButton: UIButton!
    
    private var animator: UIDynamicAnimator!
    private var containerOriginalFrame: CGRect!
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        container.alpha = 0.0
        container.roundCorners(radius: 8.0)
        
        signInButton.layer.borderWidth = 1.0
        signInButton.layer.borderColor = signInButton.titleLabel!.textColor!.cgColor
        
        animator = UIDynamicAnimator()
        
        let attributedString = NSMutableAttributedString(attributedString: signUpText.attributedText!)
        attributedString.addAttributes([NSFontAttributeName: UIFont(name: "Lato-Bold", size: 30)!], range: NSRange(location: 0, length: 67))
        attributedString.addAttributes([NSForegroundColorAttributeName: #colorLiteral(red: 0.7215686275, green: 0.3137254902, blue: 0.2156862745, alpha: 1)], range: NSRange(location: 0, length: 8))
        attributedString.addAttributes([NSForegroundColorAttributeName: #colorLiteral(red: 0.1411764706, green: 0.1647058824, blue: 0.2117647059, alpha: 1)], range: NSRange(location: 8, length: 59))
        attributedString.addAttributes([NSFontAttributeName: UIFont(name: "Lato-BoldItalic", size: 30)!], range: NSRange(location: 14, length: 8))
        signUpText.attributedText = attributedString
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if container.alpha != 1.0 {
            let point = CGPoint(x: container.frame.midX, y: container.frame.midY)
            let snap = UISnapBehavior(item: container, snapTo: point)
            snap.damping = 1.0
            
            container.frame = CGRect(x: container.frame.origin.x + view.frame.width, y: -container.frame.origin.y - view.frame.height, width: container.frame.width, height: container.frame.height)
            container.alpha = 1.0
            
            animator.addBehavior(snap)
            
            UIView.animate(withDuration: 0.25, animations: {
                self.view.backgroundColor = #colorLiteral(red: 0.4705882353, green: 0.4705882353, blue: 0.4705882353, alpha: 0.7527527265)
            })
        }
    }
    
    // MARK: - Unwind
    
    @IBAction func unwindToSignInUpPrompt(_ segue: UIStoryboardSegue) {
        dismiss(animated: false, completion: nil)
    }

}
