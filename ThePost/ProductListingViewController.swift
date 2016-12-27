//
//  ProductListingViewController.swift
//  ThePost
//
//  Created by Andrew Robinson on 12/27/16.
//  Copyright © 2016 The Post. All rights reserved.
//

import UIKit

class ProductListingViewController: UIViewController {
    
    var jeepModel: Jeep!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController!.navigationBar.setBackgroundImage(#imageLiteral(resourceName: "ProductListingNavbarBackground"), for: .default)
        if let start = jeepModel.startYear, let end = jeepModel.endYear, let name = jeepModel.name {
            navigationController!.navigationBar.topItem!.title = name + " \(start)-\(end)"
        }
    }

}
