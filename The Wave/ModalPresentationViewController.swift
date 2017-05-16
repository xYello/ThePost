//
//  ModalPresentationViewController.swift
//  ThePost
//
//  Created by Andrew Robinson on 1/19/17.
//  Copyright © 2017 The Post. All rights reserved.
//

import UIKit

class ModalPresentationViewController: UIViewController {
    
    var shouldAnimateBackgroundColor = true
    
    weak var modalContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    internal func removeFromPresentationStack() {
        PresentationCenter.manager.popPresentationStack()
    }

}
