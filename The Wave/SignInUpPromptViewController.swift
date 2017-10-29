//
//  SignInUpPromptViewController.swift
//  ThePost
//
//  Created by Andrew Robinson on 1/5/17.
//  Copyright © 2017 XYello, Inc. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit
import TwitterKit
import SwiftKeychainWrapper
import OneSignal

class SignInUpPromptViewController: UIViewController {

    @IBOutlet weak var container: UIView!
    
    @IBOutlet weak var signUpText: UILabel!
    
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var twitterButton: UIButton!
    @IBOutlet weak var emailButton: UIButton!
    @IBOutlet weak var signInButton: UIButton!
    
    @IBOutlet weak var closeButton: UIButton!
    
    @IBOutlet weak var policyTextView: UITextView!
    
    private var animator: UIDynamicAnimator!
    private var containerOriginalFrame: CGRect!
    
    private var ref: DatabaseReference!
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference().child("users")
        
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
        
        
        let string = NSMutableAttributedString(string: policyTextView.text)
        let touRange = (policyTextView.text as NSString).range(of: "Terms of Use")
        let privacyRange = (policyTextView.text as NSString).range(of: "Privacy Policy")
        
        string.addAttribute(NSLinkAttributeName, value: PolicyLinks.termsOfUse, range: touRange)
        string.addAttribute(NSLinkAttributeName, value: PolicyLinks.privacy, range: privacyRange)
        
        let wholeRange = NSMakeRange(0, string.length)
        let font = UIFont(name: "Lato-LightItalic", size: 12.0)!
        string.addAttribute(NSForegroundColorAttributeName, value: UIColor.black, range: wholeRange)
        string.addAttribute(NSFontAttributeName, value: font, range: wholeRange)
        
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        string.addAttribute(NSParagraphStyleAttributeName, value: style, range: wholeRange)
        
        policyTextView.linkTextAttributes = [NSForegroundColorAttributeName: UIColor.black,
                                             NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue,
                                             NSUnderlineColorAttributeName: UIColor.black,
                                             NSFontAttributeName: font]
        policyTextView.attributedText = string
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
        disableButtons()
        
        FBSDKLoginManager().logIn(withReadPermissions: ["public_profile", "email"], from: self, handler: { result, error in
            if let error = error {
                if (error as NSError).code != 1 {
                    print("Error signing up: \(error.localizedDescription)")
                    SentryManager.shared.sendEvent(withError: error)
                }
                
                self.disableButtons()
            } else {
                if FBSDKAccessToken.current() != nil {
                    let req = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "email,name"], tokenString: FBSDKAccessToken.current().tokenString, version: nil, httpMethod: "GET")
                    if let req = req {
                        
                        req.start() { connection, result, error in
                            if let error = error {
                                print("Error signing up: \(error.localizedDescription)")
                                SentryManager.shared.sendEvent(withError: error)
                                self.disableButtons()
                            } else {
                                let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                                Auth.auth().signIn(with: credential, completion: { user, firError in
                                    if let firError = firError {
                                        print("Error signing up: \(firError.localizedDescription)")
                                        SentryManager.shared.sendEvent(withError: firError)
                                        self.disableButtons()
                                    } else {
                                        if let data = result as? [String: AnyObject] {
                                            var email = ""
                                            if let e = data["email"] as? String {
                                                email = e
                                            }
                                            
                                            self.ref.child(user!.uid).child("isOnline").setValue(true)
                                            
                                            // Check if fullname already exists.
                                            self.ref.child(user!.uid).child("fullName").observeSingleEvent(of: .value, with: { snapshot in
                                                if let _ = snapshot.value as? String {
                                                } else {
                                                    self.ref.child(user!.uid).child("fullName").setValue(data["name"] as! String)
                                                }
                                            })
                                            
                                            self.ref.child(user!.uid).child("verifiedWith").child("Facebook").setValue(true)
                                            self.ref.child(user!.uid).child("email").setValue(email)

                                            let user = User()
                                            user.uid = Auth.auth().currentUser!.uid
                                            user.email = email
                                            SentryManager.shared.addUserCrediantials(withUser: user)

                                            self.saveOneSignalId()
                                            self.performSegue(withIdentifier: "promptToWalkthroughSegue", sender: self)
                                        }
                                    }
                                })
                            }
                        }
                    }
                } else {
                    self.disableButtons()
                }
            }
        })
    }
    
    private func signUpTwitter() {
        disableButtons()
        
        Twitter.sharedInstance().logIn() { session, error in
            if let session = session {
                
                let credential = TwitterAuthProvider.credential(withToken: session.authToken, secret: session.authTokenSecret)
                Auth.auth().signIn(with: credential, completion: { user, firError in
                    if let firError = firError {
                        print("Error signing up: \(firError.localizedDescription)")
                        SentryManager.shared.sendEvent(withError: error!)
                        self.disableButtons()
                    } else {
                        var name = ""
                        if let n = user?.displayName {
                            name = n
                        }
                        
                        KeychainWrapper.standard.set(session.authToken, forKey: TwitterInfoKeys.token)
                        KeychainWrapper.standard.set(session.authTokenSecret, forKey: TwitterInfoKeys.secret)
                        
                        self.ref.child(user!.uid).child("verifiedWith").child("Twitter").setValue(true)
                        self.ref.child(user!.uid).child("isOnline").setValue(true)
                        
                        // Check if fullname already exists
                        self.ref.child(user!.uid).child("fullName").observeSingleEvent(of: .value, with: { snapshot in
                            if let _ = snapshot.value as? String {
                            } else {
                                self.ref.child(user!.uid).child("fullName").setValue(name)
                            }
                        })

                        let user = User()
                        user.uid = Auth.auth().currentUser!.uid
                        SentryManager.shared.addUserCrediantials(withUser: user)
                        
                        self.saveOneSignalId()
                        self.performSegue(withIdentifier: "promptToWalkthroughSegue", sender: self)
                    }
                })
                
            } else if let error = error {
                print("Error signing up: \(error.localizedDescription)")
                SentryManager.shared.sendEvent(withError: error)
                self.disableButtons()
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
        item.addAngularVelocity(-CGFloat.pi / 2, for: container)
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
    
    // MARK: - Helpers
    
    private func disableButtons() {
        if facebookButton.isEnabled {
            closeButton.alpha = 0.75
            facebookButton.alpha = 0.75
            twitterButton.alpha = 0.75
            emailButton.alpha = 0.75
            signInButton.alpha = 0.75
            
            closeButton.isEnabled = false
            facebookButton.isEnabled = false
            twitterButton.isEnabled = false
            emailButton.isEnabled = false
            signInButton.isEnabled = false
        } else {
            closeButton.alpha = 1.0
            facebookButton.alpha = 1.0
            twitterButton.alpha = 1.0
            emailButton.alpha = 1.0
            signInButton.alpha = 1.0
            
            closeButton.isEnabled = true
            facebookButton.isEnabled = true
            twitterButton.isEnabled = true
            emailButton.isEnabled = true
            signInButton.isEnabled = true
        }
    }
    
    // MARK: - Firebase
    
    private func saveOneSignalId() {
        if let id = OneSignal.getPermissionSubscriptionState().subscriptionStatus.userId  {
            let ref = self.ref.child(Auth.auth().currentUser!.uid).child("pushNotificationIds")
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
