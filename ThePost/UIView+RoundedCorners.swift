//
//  UIView+RoundedCorners.swift
//  ThePost
//
//  Created by Andrew Robinson on 12/24/16.
//  Copyright © 2016 The Post. All rights reserved.
//

import UIKit

extension UIView {
    func roundCorners() {
        layer.cornerRadius = frame.height / 2.0
    }
}
