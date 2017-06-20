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
    
    var uid: String!
    
    var ownerId: String!
    
    var images: [String] = []
    
    var name: String!
    var jeepModel: JeepModel!
    var price: Float!
    var condition: Condition!
    var likeCount: Int?
    var postedDate: Date!
    var relativeDate: String! {
        get {
            let now = Date()
            
            let components = Calendar.current.dateComponents([.year, .month, .weekOfYear, .day, .hour, .minute, .second], from: postedDate, to: now)
            
            if let years = components.year, years > 0 {
                return "\(years) year\(years == 1 ? "" : "s") ago"
            }
            
            if let months = components.month, months > 0 {
                return "\(months) month\(months == 1 ? "" : "s") ago"
            }
            
            if let weeks = components.weekOfYear, weeks > 0 {
                return "\(weeks) week\(weeks == 1 ? "" : "s") ago"
            }
            if let days = components.day, days > 0 {
                guard days > 1 else { return "Yesterday" }
                
                return "\(days) day\(days == 1 ? "" : "s") ago"
            }
            
            if let hours = components.hour, hours > 0 {
                return "\(hours) hour\(hours == 1 ? "" : "s") ago"
            }
            
            if let minutes = components.minute, minutes > 0 {
                return "\(minutes) minute\(minutes == 1 ? "" : "s") ago"
            }
            
            if let seconds = components.second, seconds > 30 {
                return "\(seconds) second\(seconds == 1 ? "" : "s") ago"
            }
            
            return "Just now"
        }
    }
    
    var originalBox = false
    var releaseYear: Int?
    var detailedDescription: String?
    var simplifiedDescription: String {
        get {
            
            var string = "\(condition.description) - "
            
            switch jeepModel! {
            case .all:
                string = string.replacingOccurrences(of: " - ", with: "")
            case .wranglerJK:
                string.append("JK")
            case .wranglerTJ:
                string.append("TJ")
            case .wranglerYJ:
                string.append("YJ")
            case .cherokeeCJ:
                string.append("CJ")
            case .cherokeeXJ:
                string.append("XJ")
            }
            
            return string
        }
    }
    
    var willingToShip = false
    var acceptsPayPal = false
    var acceptsCash = false
    
    var isSold = false
    
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
    
    static func createProduct(with productDict: [String: AnyObject], with key: String) -> Product? {
        var product: Product?
        
        if let jeepModel = JeepModel.enumFromString(string: productDict["jeepModel"] as! String) {
            if let condition = Condition.enumFromString(string: productDict["condition"] as! String) {
                product = Product(withName: productDict["name"] as! String,
                                  model: jeepModel,
                                  price: productDict["price"] as! Float,
                                  condition: condition)
                
                product!.uid = key
                product!.ownerId = productDict["owner"] as! String
                
                product!.postedDate = Date(timeIntervalSince1970: productDict["datePosted"] as! TimeInterval / 1000)
                
                if let likeCount = productDict["likeCount"] as? Int {
                    product!.likeCount = likeCount
                }
                
                product!.originalBox = productDict["originalBox"] as! Bool
                if let year = productDict["releaseYear"] as? Int {
                    product!.releaseYear = year
                }
                if let desc = productDict["detailedDescription"] as? String {
                    product!.detailedDescription = desc
                }
                
                product!.willingToShip = productDict["willingToShip"] as! Bool
                product!.acceptsPayPal = productDict["acceptsPayPal"] as! Bool
                product!.acceptsCash = productDict["acceptsCash"] as! Bool
                
                if let isSold = productDict["isSold"] as? Bool {
                    product!.isSold = isSold
                }
            }
        }
        
        return product
    }

}
