//
//  PriceChooseViewController.swift
//  The Wave
//
//  Created by Andrew Robinson on 8/1/17.
//  Copyright © 2017 XYello, Inc. All rights reserved.
//

import UIKit

class PriceChooseViewController: SeletectedImageViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func present(fromVc: UIViewController) {
        modalPresentationStyle = .overCurrentContext
        super.present(fromVc: fromVc)
    }

}
