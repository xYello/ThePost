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

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if !didSelectJeep {
            performSegue(withIdentifier: "jeepSelectorSegue", sender: self)
        } else {
            performSegue(withIdentifier: "walkthroughSegue", sender: self)
        }
    }
    
    // MARK: - Actions
    
    @IBAction func unwindToSelf(_ segue: UIStoryboardSegue) {
        if let vc = segue.source as? CategorySelectorViewController {
            print("Selected Jeep was: \(vc.jeepModel.name!)")
            didSelectJeep = true
        }
    }

}
