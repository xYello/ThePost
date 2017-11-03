//
//  LocationPermissionRequestViewController.swift
//  The Wave
//
//  Created by Andrew Robinson on 11/2/17.
//  Copyright © 2017 XYello, Inc. All rights reserved.
//

import UIKit

class LocationPermissionRequestViewController: UIViewController {

    @IBOutlet weak var requestButton: UIButton!

    // MARK: - View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        requestButton.roundCorners()
    }

    // MARK: - Actions

    @IBAction func requestButtonPressed(_ sender: UIButton) {
        Location.manager.startGatheringAndRequestPermission()
        performSegue(withIdentifier: "unwindToPresenting", sender: self)
    }

    @IBAction func skipButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "unwindToPresenting", sender: self)
    }
}
