//
//  BuildTrustViewController.swift
//  ThePost
//
//  Created by Andrew Robinson on 4/20/17.
//  Copyright © 2017 The Post. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit
import TwitterKit

class BuildTrustViewController: UIViewController {

    @IBOutlet weak var shieldView: UIView!
    
    @IBOutlet weak var backgroundView: UIView!
    
    @IBOutlet weak var facebookView: UIView!
    @IBOutlet weak var twitterView: UIView!
    @IBOutlet weak var emailView: UIView!
    
    // MARK: - View lifecyle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        shieldView.roundCorners()
        
        backgroundView.roundCorners(radius: 8.0)
        facebookView.roundCorners(radius: 8.0)
        twitterView.roundCorners(radius: 8.0)
        emailView.roundCorners(radius: 8.0)
        
        if let user = FIRAuth.auth()?.currentUser {
            for provider in user.providerData {
                if provider.providerID == "facebook.com" {
                    facebookView.isHidden = true
                } else if provider.providerID == "twitter.com" {
                    twitterView.isHidden = true
                }
            }
            
            if user.email == nil {
                emailView.isHidden = true
            }
            
            if user.isEmailVerified {
                emailView.isHidden = true
            }
        }
        
    }
    
    // MARK: - Actions
    
    @IBAction func facebookButtonPressed(_ sender: UIButton) {
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
                                FIRAuth.auth()?.currentUser?.link(with: credential) { user, error in
                                    if let error = error {
                                        print("Error in Facebook auth: \(error.localizedDescription)")
                                    } else {
                                        if let data = result as? [String: AnyObject] {
                                            if let e = data["email"] as? String {
                                                FIRDatabase.database().reference().child("users").child(FIRAuth.auth()!.currentUser!.uid).child("email").setValue(e)
                                            }
                                        }
                                        
                                        if self.twitterView.isHidden && self.emailView.isHidden {
                                            self.dismissParent()
                                        } else {
                                            UIView.animate(withDuration: 0.25, animations: {
                                                self.facebookView.isHidden = true
                                            })
                                        }
                                    }
                                }
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
    
    @IBAction func twitterButtonPressed(_ sender: UIButton) {
        Twitter.sharedInstance().logIn() { session, error in
            if let session = session {
                
                let credential = FIRTwitterAuthProvider.credential(withToken: session.authToken, secret: session.authTokenSecret)
                FIRAuth.auth()?.currentUser?.link(with: credential) { user, error in
                    if let error = error {
                        print("Error in Twitter auth: \(error.localizedDescription)")
                    } else {
                        UIView.animate(withDuration: 0.25, animations: {
                            if self.facebookView.isHidden && self.emailView.isHidden {
                                self.dismissParent()
                            } else {
                                UIView.animate(withDuration: 0.25, animations: {
                                    self.twitterView.isHidden = true
                                })
                            }
                        })
                    }
                }
                
            } else if let error = error {
                // TODO: Update with error reporting.
                print("Error signing up: \(error.localizedDescription)")
            }
            
        }
    }
    
    @IBAction func emailButtonPressed(_ sender: UIButton) {
        FIRAuth.auth()?.currentUser?.sendEmailVerification() { error in
            if let error = error {
                print("Error in sending verification email: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Helpers
    
    private func dismissParent() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: buildTrustChangeNotificationKey), object: nil, userInfo: nil)
        
        if let parent = parent as? BuildTrustModalViewController {
            parent.prepareForDismissal {
                parent.dismiss(animated: false, completion: nil)
            }
        }
    }

}
