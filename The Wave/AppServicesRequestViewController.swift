//
//  AppServicesRequestViewController.swift
//  ThePost
//
//  Created by Andrew Robinson on 12/24/16.
//  Copyright © 2016 XYello, Inc. All rights reserved.
//

import UIKit
import CoreLocation
import SwiftKeychainWrapper
import OneSignal

class AppServicesRequestViewController: UIViewController {

    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var requestButton: UIButton!
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        requestButton.roundCorners()
    }

    // MARK: - Actions

    @IBAction func requestButtonPressed(_ sender: UIButton) {
        
        OneSignal.promptForPushNotifications() { accepted in
            self.performSegue(withIdentifier: "unwindToPresenting", sender: self)
        }
        
    }
    
    @IBAction func skipButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "unwindToPresenting", sender: self)
    }
    
}
