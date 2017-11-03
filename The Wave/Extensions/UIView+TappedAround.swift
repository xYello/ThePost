//
//  UIView+TappedAround.swift
//  The Wave
//
//  Created by Andrew Robinson on 8/2/17.
//  Copyright © 2017 XYello, Inc. All rights reserved.
//

extension UIView {

    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapped))
        tap.cancelsTouchesInView = false
        addGestureRecognizer(tap)
    }

    @objc func tapped() {
        endEditing(false)
    }
}
