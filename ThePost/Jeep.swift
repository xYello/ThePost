//
//  Jeep.swift
//  ThePost
//
//  Created by Andrew Robinson on 12/26/16.
//  Copyright © 2016 The Post. All rights reserved.
//

import UIKit

enum JeepModel {
    case wranglerJK
    case wranglerTJ
    case wranglerYJ
    case cherokeeXJ
}

class Jeep: NSObject {
    
    var type: JeepModel! {
        didSet {
            evaluateType(type: type)
        }
    }
    
    private(set) var image: UIImage?
    private(set) var name: String?
    private(set) var startYear: Int?
    
    // -1 is present.
    private(set) var endYear: Int?
    
    init(withType type: JeepModel) {
        super.init()
        
        defer {
            self.type = type
        }
    }
    
    private func evaluateType(type: JeepModel) {
        switch type {
        case .wranglerJK:
            image = UIImage(named: "WranglerJK")!
            name = "Jeep Wrangler JK"
            startYear = 2007
            endYear = -1
        case .wranglerTJ:
            image = UIImage(named: "WranglerTJ")!
            name = "Jeep Wrangler TJ"
            startYear = 1997
            endYear = 2006
        case .wranglerYJ:
            image = UIImage(named: "WranglerYJ")!
            name = "Jeep Wrangler YJ"
            startYear = 1987
            endYear = 1995
        case .cherokeeXJ:
            image = UIImage(named: "CherokeeXJ")!
            name = "Jeep Cherokee XJ"
            startYear = 1984
            endYear = 2001
        }
    }

}
