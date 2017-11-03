//
//  BuildTrustViewController.swift
//  ThePost
//
//  Created by Andrew Robinson on 4/20/17.
//  Copyright © 2017 XYello, Inc. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit
import TwitterKit

class BuildTrustViewController: UIViewController {

    @IBOutlet weak var shieldView: UIView!
    
    @IBOutlet weak var backgroundView: UIView!
    
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var facebookView: UIView!
    @IBOutlet weak var twitterView: UIView!
    
    // MARK: - View lifecyle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        shieldView.roundCorners()
        
        backgroundView.roundCorners(radius: 8.0)
        facebookView.roundCorners(radius: 8.0)
        twitterView.roundCorners(radius: 8.0)
        
        if let user = Auth.auth().currentUser {
            for provider in user.providerData {
                if provider.providerID == "facebook.com" {
                    facebookView.isHidden = true
                } else if provider.providerID == "twitter.com" {
                    twitterView.isHidden = true
                }
            }
        }
        
    }
    
    // MARK: - Actions
    
    @IBAction func facebookButtonPressed(_ sender: UIButton) {
        FBSDKLoginManager().logIn(withReadPermissions: ["public_profile", "email"], from: self, handler: { result, error in
            if let error = error {
                print("Error signing up: \(error.localizedDescription)")
                SentryManager.shared.sendEvent(withError: error)
            } else {
                if FBSDKAccessToken.current() != nil {
                    let req = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "email,name"], tokenString: FBSDKAccessToken.current().tokenString, version: nil, httpMethod: "GET")
                    if let req = req {
                        
                        req.start() { connection, result, error in
                            if let error = error {
                                print("Error signing up: \(error.localizedDescription)")
                                self.updateText(withError: error)
                                SentryManager.shared.sendEvent(withError: error)
                            } else {
                                let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                                Auth.auth().currentUser?.link(with: credential) { user, error in
                                    if let error = error {
                                        print("Error in Facebook auth: \(error.localizedDescription)")
                                        self.updateText(withError: error)
                                        SentryManager.shared.sendEvent(withError: error)
                                    } else {
                                        
                                        if let data = result as? [String: AnyObject] {
                                            if let e = data["email"] as? String {
                                                Database.database().reference().child("users").child(user!.uid).child("email").setValue(e)
                                            }
                                        }
                                        
                                        Database.database().reference().child("users").child(user!.uid).child("verifiedWith").child("Facebook").setValue(true)
                                        
                                        if self.twitterView.isHidden {
                                            self.dismissParent()
                                        } else {
                                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: buildTrustChangeNotificationKey), object: nil, userInfo: nil)
                                            
                                            UIView.animate(withDuration: 0.25, animations: {
                                                self.facebookView.isHidden = true
                                            })
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        })
    }
    
    @IBAction func twitterButtonPressed(_ sender: UIButton) {
        Twitter.sharedInstance().logIn() { session, error in
            if let session = session {
                
                let credential = TwitterAuthProvider.credential(withToken: session.authToken, secret: session.authTokenSecret)
                Auth.auth().currentUser?.link(with: credential) { user, error in
                    if let error = error {
                        print("Error in Twitter auth: \(error.localizedDescription)")
                        self.updateText(withError: error)
                        SentryManager.shared.sendEvent(withError: error)
                    } else {
                        Database.database().reference().child("users").child(user!.uid).child("verifiedWith").child("Twitter").setValue(true)
                        
                        if self.facebookView.isHidden {
                            self.dismissParent()
                        } else {
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: buildTrustChangeNotificationKey), object: nil, userInfo: nil)
                            
                            UIView.animate(withDuration: 0.25, animations: {
                                self.twitterView.isHidden = true
                            })
                        }
                    }
                }
                
            } else if let error = error {
                print("Error signing up: \(error.localizedDescription)")
                self.updateText(withError: error)
                SentryManager.shared.sendEvent(withError: error)
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

    private func updateText(withError error: Error) {
        let error = error as NSError
        if error.code == 17025 || error.code == 17015 {
            DispatchQueue.main.async {
                self.messageLabel.textColor = .red
                self.messageLabel.text = "Another profile already has that paired!"
            }
        }
    }

}
