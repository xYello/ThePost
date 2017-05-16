//
//  Jeep.swift
//  ThePost
//
//  Created by Andrew Robinson on 12/26/16.
//  Copyright © 2016 The Post. All rights reserved.
//

import UIKit

enum JeepModel: Int {
    case all = 0, wranglerJK, wranglerTJ, wranglerYJ
    
    var description : String {
        switch self {
        case .all: return "General"
        case .wranglerJK: return "Jeep Wrangler JK"
        case .wranglerTJ: return "Jeep Wrangler TJ"
        case .wranglerYJ: return "Jeep Wrangler YJ"
        }
    }
    
    static var count: Int { return JeepModel.wranglerYJ.hashValue + 1 }
    
    static func enumFromString(string: String) -> JeepModel? {
        var i = 0
        while let item = JeepModel(rawValue: i) {
            if item.description == string { return item }
            i += 1
        }
        return nil
    }
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
    private(set) var endYear: Int?
    private(set) var isInProduction = false {
        didSet {
            if isInProduction {
                let components = Calendar.current.dateComponents([.year], from: Date())
                endYear = components.year
            }
        }
    }
    
    init(withType type: JeepModel) {
        super.init()
        
        defer {
            self.type = type
        }
    }
    
    private func evaluateType(type: JeepModel) {
        switch type {
        case .all:
            image = #imageLiteral(resourceName: "WranglerJK")
            name = "All Jeeps"
        case .wranglerJK:
            image = UIImage(named: "WranglerJK")!
            name = "Jeep Wrangler JK"
            startYear = 2007
            isInProduction = true
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
        }
    }

}
