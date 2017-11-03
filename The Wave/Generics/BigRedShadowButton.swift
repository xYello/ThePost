//
//  BigRedShadowButton.swift
//  The Wave
//
//  Created by Andrew Robinson on 8/1/17.
//  Copyright © 2017 XYello, Inc. All rights reserved.
//

import UIKit

class BigRedShadowButton: UIButton {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setTitleColor(.white, for: .normal)
        titleLabel?.font = UIFont(name: "Avenir-Heavy", size: 15.0)

        setBackgroundImage(#imageLiteral(resourceName: "BigRedButton"), for: .normal)
    }

}
