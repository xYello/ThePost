//
//  Product.swift
//  ThePost
//
//  Created by Andrew Robinson on 12/27/16.
//  Copyright © 2016 The Post. All rights reserved.
//

import UIKit

enum Condition {
    case new
    case used
    case broke
    case remanufactured
    case other
    
    var description : String {
        switch self {
        case .new: return "New";
        case .used: return "Used";
        case .broke: return "Broken";
        case .remanufactured: return "Remanufactured";
        case .other: return "Other";
        }
    }
    
     static var count: Int { return Condition.other.hashValue + 1 }
}

class Product: NSObject {
    
    var owner: User!
    
    var images: [UIImage] = []
    
    var name: String!
    var jeepModel: JeepModel!
    var price: Float!
    var condition: Condition!
    var primaryColor: String!
    
    var originalBox = false
    var relaseYear: Int?
    var detailedDescription: String?
    var simplifiedDescription: String {
        get {
            
            var string = "\(condition.description) - "
            
            switch jeepModel! {
            case .wranglerJK:
                string.append("JK - ")
            case .wranglerTJ:
                string.append("TJ - ")
            case .wranglerYJ:
                string.append("YJ - ")
            case .cherokeeXJ:
                string.append("XJ - ")
            }
            
            string.append(primaryColor)
            
            return string
        }
    }
    
    var willingToShip = false
    var acceptsPayPal = false
    var acceptsCash = false
    
    init(withName name: String, model: JeepModel, price: Float, condition: Condition, color: String) {
        super.init()
        
        defer {
            self.name = name
            self.jeepModel = model
            self.price = price
            self.condition = condition
            self.primaryColor = color
        }
    }

}
