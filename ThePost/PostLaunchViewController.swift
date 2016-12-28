//
//  PostLaunchViewController.swift
//  ThePost
//
//  Created by Andrew Robinson on 12/26/16.
//  Copyright © 2016 The Post. All rights reserved.
//

import UIKit

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
        
        if !didSelectJeep {
            performSegue(withIdentifier: "jeepSelectorSegue", sender: self)
        } else {
            performSegue(withIdentifier: "tabBarControllerSegue", sender: self)
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
