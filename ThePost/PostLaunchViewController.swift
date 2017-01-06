//
//  PostLaunchViewController.swift
//  ThePost
//
//  Created by Andrew Robinson on 12/26/16.
//  Copyright © 2016 The Post. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class PostLaunchViewController: UIViewController {
    
    private var didSelectJeep = false
    
    private var jeepModel: Jeep!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        // TODO: Remove this.
        didSelectJeep = true
        jeepModel = Jeep(withType: JeepModel.wranglerJK)
        
        if let pass = KeychainWrapper.standard.string(forKey: "userPass") {
            if let email = FIRAuth.auth()?.currentUser?.email {
                
                let credential = FIREmailPasswordAuthProvider.credential(withEmail: email, password: pass)
                FIRAuth.auth()!.currentUser!.reauthenticate(with: credential, completion: { error in
                    if let error = error {
                        print("Error reauthenticating: \(error.localizedDescription)")
                        do {
                            try FIRAuth.auth()?.signOut()
                        } catch {
                            print("Error signing out")
                        }
                    }
                    
                    self.decideWhichSegueToPerform()
                })
            } else {
                self.decideWhichSegueToPerform()
            }
        } else {
            do {
                try FIRAuth.auth()?.signOut()
                self.decideWhichSegueToPerform()
            } catch {
                print("Error signing out")
            }
        }
    }
    
    // MARK: - Actions
    
    @IBAction func unwindToSelf(_ segue: UIStoryboardSegue) {
        if let vc = segue.source as? CategorySelectorViewController {
            print("Selected Jeep was: \(vc.jeepModel.name!)")
            jeepModel = vc.jeepModel
            didSelectJeep = true
        }
    }
    
    // MARK: - Helpers
    
    private func decideWhichSegueToPerform() {
        if !self.didSelectJeep {
            self.performSegue(withIdentifier: "jeepSelectorSegue", sender: self)
        } else {
            self.performSegue(withIdentifier: "tabBarControllerSegue", sender: self)
        }
    }
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let tab = segue.destination as? UITabBarController {
            if let navbar = tab.viewControllers![0] as? UINavigationController {
                if let vc = navbar.viewControllers[0] as? ProductListingViewController {
                    vc.jeepModel = jeepModel
                }
            }
        }
    }

}
