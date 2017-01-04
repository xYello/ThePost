//
//  Product.swift
//  ThePost
//
//  Created by Andrew Robinson on 12/27/16.
//  Copyright © 2016 The Post. All rights reserved.
//

import UIKit

enum Condition: Int {
    case new = 0, used, damaged, remanufactured, other
    
    var description : String {
        switch self {
        case .new: return "New";
        case .used: return "Used";
        case .damaged: return "Damaged";
        case .remanufactured: return "Remanufactured";
        case .other: return "Other";
        }
    }
    
    static var count: Int { return Condition.other.hashValue + 1 }
    
    static func enumFromString(string: String) -> Condition? {
        var i = 0
        while let item = Condition(rawValue: i) {
            if item.description == string { return item }
            i += 1
        }
        return nil
    }
}

class Product: NSObject {
    
    var owner: User!
    
    var images: [UIImage] = []
    
    var name: String!
    var jeepModel: JeepModel!
    var price: Float!
    var condition: Condition!
    var likeCount: Int?
    
    var originalBox = false
    var releaseYear: Int?
    var detailedDescription: String?
    var simplifiedDescription: String {
        get {
            
            var string = "\(condition.description) - "
            
            switch jeepModel! {
            case .wranglerJK:
                string.append("JK")
            case .wranglerTJ:
                string.append("TJ")
            case .wranglerYJ:
                string.append("YJ")
            case .cherokeeXJ:
                string.append("XJ")
            }
            
            return string
        }
    }
    
    var willingToShip = false
    var acceptsPayPal = false
    var acceptsCash = false
    
    override init() {
        super.init()
    }
    
    init(withName name: String, model: JeepModel, price: Float, condition: Condition) {
        super.init()
        
        defer {
            self.name = name
            self.jeepModel = model
            self.price = price
            self.condition = condition
        }
    }

}
