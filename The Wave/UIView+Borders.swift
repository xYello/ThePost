//
//  UIView+Borders.swift
//  The Wave
//
//  Created by Andrew Robinson on 8/6/17.
//  Copyright © 2017 XYello, Inc. All rights reserved.
//

extension UIView {

    func addBorder(withWidth width: CGFloat, color: UIColor) {
        layer.borderColor = color.cgColor
        layer.borderWidth = width
    }

}
