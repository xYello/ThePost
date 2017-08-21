//
//  PercentageBar.swift
//  ThePost
//
//  Created by Andrew Robinson on 1/13/17.
//  Copyright © 2017 XYello, Inc. All rights reserved.
//

import UIKit

class PercentageBar: UIView {
    
    private var bar: UIView!
    private var topBarConstraint: NSLayoutConstraint!
    
    var value: CGFloat = 0.0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        roundCorners(radius: frame.width / 2.0)
        
        bar = UIView()
        bar.backgroundColor = .waveYellow
        bar.roundCorners(radius: frame.width / 2.0)
        bar.translatesAutoresizingMaskIntoConstraints = false
        addSubview(bar)
        
        addConstraint(NSLayoutConstraint(item: bar, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0.0))
        addConstraint(NSLayoutConstraint(item: bar, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 0.0))
        addConstraint(NSLayoutConstraint(item: bar, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0))
        
        topBarConstraint = NSLayoutConstraint(item: bar, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: frame.height)
        addConstraint(topBarConstraint)
    }
    
    func animateValueChanges() {
        topBarConstraint.constant = frame.height - (value * frame.height)
        
        UIView.animate(withDuration: 0.25, animations: {
            self.layoutIfNeeded()
        })
    }

}
