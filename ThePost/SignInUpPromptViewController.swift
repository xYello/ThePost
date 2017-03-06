//
//  SignInUpPromptViewController.swift
//  ThePost
//
//  Created by Andrew Robinson on 1/5/17.
//  Copyright © 2017 The Post. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit
import TwitterKit
import SwiftKeychainWrapper

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
    
    // MARK: - Actions
    
    @IBAction func connectWithFacebook(_ sender: UIButton) {
        signUpFacebook()
    }
    
    @IBAction func connectWithTwitter(_ sender: UIButton) {
        signUpTwitter()
    }
    
    @IBAction func dismissSignUpPrompt(_ sender: UIButton) {
        prepareForDismissal {
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    // MARK: - Sign up helpers
    
    private func signUpFacebook() {
        FBSDKLoginManager().logIn(withReadPermissions: ["public_profile", "email"], from: self, handler: { result, error in
            if let error = error {
                // TODO: Update with error reporting.
                print("Error signing up: \(error.localizedDescription)")
            } else {
                if FBSDKAccessToken.current() != nil {
                    let req = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "email,name"], tokenString: FBSDKAccessToken.current().tokenString, version: nil, httpMethod: "GET")
                    if let req = req {
                        
                        req.start() { connection, result, error in
                            if let error = error {
                                // TODO: Update with error reporting.
                                print("Error signing up: \(error.localizedDescription)")
                            } else {
                                let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                                FIRAuth.auth()?.signIn(with: credential, completion: { user, firError in
                                    if let firError = firError {
                                        // TODO: Update with error reporting.
                                        print("Error signing up: \(firError.localizedDescription)")
                                    } else {
                                        if let data = result as? [String: AnyObject] {
                                            var email = ""
                                            if let e = data["email"] as? String {
                                                email = e
                                            }
                                            
                                            FIRDatabase.database().reference().child("users").child(FIRAuth.auth()!.currentUser!.uid).child("isOnline").setValue(true)
                                            FIRDatabase.database().reference().child("users").child(user!.uid).setValue(["fullName": data["name"] as! String, "email": email])
                                            self.performSegue(withIdentifier: "promptToWalkthroughSegue", sender: self)
                                        }
                                    }
                                })
                            }
                        }
                    }
                } else {
                    // TODO: Update with error reporting.
                    print("Did not actually sign up with Facebook.")
                }
            }
        })
    }
    
    private func signUpTwitter() {
        Twitter.sharedInstance().logIn() { session, error in
            if let session = session {
                
                let credential = FIRTwitterAuthProvider.credential(withToken: session.authToken, secret: session.authTokenSecret)
                FIRAuth.auth()?.signIn(with: credential, completion: { user, firError in
                    if let firError = firError {
                        // TODO: Update with error reporting.
                        print("Error signing up: \(firError.localizedDescription)")
                    } else {
                        var name = ""
                        if let n = user?.displayName {
                            name = n
                        }
                        
                        KeychainWrapper.standard.set(session.authToken, forKey: TwitterInfoKeys.token)
                        KeychainWrapper.standard.set(session.authTokenSecret, forKey: TwitterInfoKeys.secret)
                        
                        FIRDatabase.database().reference().child("users").child(FIRAuth.auth()!.currentUser!.uid).child("isOnline").setValue(true)
                        FIRDatabase.database().reference().child("users").child(user!.uid).setValue(["fullName": name])
                        self.performSegue(withIdentifier: "promptToWalkthroughSegue", sender: self)
                    }
                })
                
            } else if let error = error {
                // TODO: Update with error reporting.
                print("Error signing up: \(error.localizedDescription)")
            }
        
        }
        
    }
    
    // MARK: - Dismissal
    
    func prepareForDismissal(dismissCompletion: @escaping () -> Void) {
        animator.removeAllBehaviors()
        
        let gravity = UIGravityBehavior(items: [container])
        gravity.gravityDirection = CGVector(dx: 0.0, dy: 9.8)
        animator.addBehavior(gravity)
        
        let item = UIDynamicItemBehavior(items: [container])
        item.addAngularVelocity(-CGFloat(M_PI_2), for: container)
        animator.addBehavior(item)
        
        UIView.animate(withDuration: 0.25, animations: {
            self.container.alpha = 0.0
            self.view.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        }, completion: { done in
            dismissCompletion()
        })
    }
    
    // MARK: - Unwind
    
    @IBAction func unwindToSignInUpPrompt(_ segue: UIStoryboardSegue) {
        prepareForDismissal {
            self.dismiss(animated: false, completion: nil)
        }
    }

}
