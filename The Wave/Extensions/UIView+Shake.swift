//
//  UIView+Shake.swift
//  The Wave
//
//  Created by Andrew Robinson on 8/17/17.
//  Copyright © 2017 XYello, Inc. All rights reserved.
//

extension UIView {
    func shake() {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.08
        animation.repeatCount = 2
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: center.x - 10, y: center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: center.x + 10, y: center.y))
        layer.add(animation, forKey: "position")
    }
}
