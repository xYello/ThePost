//
//  UIView+RoundedCorners.swift
//  ThePost
//
//  Created by Andrew Robinson on 12/24/16.
//  Copyright © 2016 XYello, Inc. All rights reserved.
//

import UIKit

extension UIView {
    
    func roundCorners() {
        layer.cornerRadius = frame.height / 2.0
    }
    
    func roundCorners(radius: CGFloat) {
        layer.cornerRadius = radius
    }

    func round(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()

        mask.path = path.cgPath
        layer.mask = mask
    }
    
}
