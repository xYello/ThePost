//
//  Conversation.swift
//  ThePost
//
//  Created by Andrew Robinson on 1/8/17.
//  Copyright © 2017 The Post. All rights reserved.
//

import UIKit

class Conversation: NSObject {
    
    var id: String!
    
    var otherPersonId: String!
    var otherPersonName: String!
    var isOtherPersonOnline = false
    
    var productID: String!
    
    var firstMessage: String?
    
    var lastSentMessage: String?
    var lastSentMessageTime: String?
    var date: Date? {
        get {
            var dateToReturn: Date?
            
            if let dateString = lastSentMessageTime {
                let formatter = DateFormatter()
                formatter.dateFormat = "MM/dd/yy HH:mm:ss"
                formatter.timeZone = TimeZone(identifier: "America/New_York")
                dateToReturn = formatter.date(from: dateString)
            }
            
            return dateToReturn
        }
    }
    var relativeDate: String! {
        get {
            if let date = date {
                let now = Date()
                
                let components = Calendar.current.dateComponents([.year, .month, .weekOfYear, .day, .hour, .minute, .second], from: date, to: now)
                
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
                    guard days > 1 else { return "yesterday" }
                    
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
                
                return "Now"
            }
            
            return ""
        }
    }
    
    var isProductSold = false
    var productName = ""
    
    init(id: String, otherPersonId: String, otherPersonName: String, productID: String) {
        self.id = id
        self.otherPersonId = otherPersonId
        self.otherPersonName = otherPersonName
        self.productID = productID
    }
    
    override init() {
        super.init()
    }

}
