//
//  AppServicesRequestViewController.swift
//  ThePost
//
//  Created by Andrew Robinson on 12/24/16.
//  Copyright © 2016 The Post. All rights reserved.
//

import UIKit
import CoreLocation
import SwiftKeychainWrapper

class AppServicesRequestViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var requestButton: UIButton!
    
    private var originalContainerFrame: CGRect!
    
    private var manager: CLLocationManager!
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        manager = CLLocationManager()
        manager.delegate = self
        
        requestButton.roundCorners()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        originalContainerFrame = containerView.frame
    }

    // MARK: - Actions

    @IBAction func requestButtonPressed(_ sender: UIButton) {
        if requestButton.currentTitle == "Enable Location" {
            
            if CLLocationManager.locationServicesEnabled() {
                manager.requestWhenInUseAuthorization()
            }
            
            UIView.animate(withDuration: 0.25, animations: {
                self.containerView.frame = CGRect(x: self.containerView.frame.origin.x - 1 * self.containerView.frame.width,
                                                  y: self.containerView.frame.origin.y,
                                                  width: self.containerView.frame.width,
                                                  height: self.containerView.frame.height)
            }, completion: { done in
                self.titleLabel.text = "Push Notifications"
                self.messageLabel.text = "Stay up to date with all that happens in The Post. Enable your notifcations."
                self.imageView.image = #imageLiteral(resourceName: "PhoneRing")
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
            performSegue(withIdentifier: "unwindToPresenting", sender: self)
        }
    }
    
    @IBAction func skipButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "unwindToPresenting", sender: self)
    }
    
    // MARK: - CLLocationManager delegates
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            manager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = manager.location {
            CLGeocoder().reverseGeocodeLocation(location, completionHandler: { placemarks, error in
                if let marks = placemarks {
                    KeychainWrapper.standard.set(marks[0].locality!, forKey: Constants.UserInfoKeys.UserCity.rawValue)
                    KeychainWrapper.standard.set(marks[0].administrativeArea!, forKey: Constants.UserInfoKeys.UserState.rawValue)
                }
            })
        }
    }
    
}
