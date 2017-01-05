//
//  AppServicesRequestViewController.swift
//  ThePost
//
//  Created by Andrew Robinson on 12/24/16.
//  Copyright © 2016 The Post. All rights reserved.
//

import UIKit

class AppServicesRequestViewController: UIViewController {

    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var requestButton: UIButton!
    
    private var originalContainerFrame: CGRect!
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        requestButton.roundCorners()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        originalContainerFrame = containerView.frame
    }

    // MARK: - Actions

    @IBAction func requestButtonPressed(_ sender: UIButton) {
        if requestButton.currentTitle == "Enable Location" {
            
            
            
            UIView.animate(withDuration: 0.25, animations: {
                self.containerView.frame = CGRect(x: self.containerView.frame.origin.x - 1 * self.containerView.frame.width,
                                                  y: self.containerView.frame.origin.y,
                                                  width: self.containerView.frame.width,
                                                  height: self.containerView.frame.height)
            }, completion: { done in
                self.titleLabel.text = "Push Notifications"
                self.messageLabel.text = "Stay up to date with all that happens in The Post. Enable your notifcations."
                self.imageView.image = UIImage(named: "NotificationRequest")
                self.requestButton.setTitle("Enable Notifications", for: .normal)
                self.containerView.frame = CGRect(x: self.originalContainerFrame.origin.x + 1 * self.containerView.frame.width,
                                                  y: self.containerView.frame.origin.y,
                                                  width: self.containerView.frame.width,
                                                  height: self.containerView.frame.height)
                UIView.animate(withDuration: 0.25, animations: {
                    self.containerView.frame = self.originalContainerFrame
                })
            })
        } else {
            
            
            
        }
    }
    
    @IBAction func skipButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "unwindToPresenting", sender: self)
    }
    
}
