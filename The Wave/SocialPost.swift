//
//  SocialPost.swift
//  ThePost
//
//  Created by Tyler Flowers on 3/30/17.
//  Copyright © 2017 The Post. All rights reserved.
//

import UIKit
import Firebase

class SocialPost : NSObject {
    
    var uid: String!
    var ownerId: String!
    
    var imageUrl: String!
    var datePosted: Date!

    var likes: Int = 0
    
    var relativeDate: String! {
        get {
            let now = Date()
            
            let components = Calendar.current.dateComponents([.year, .month, .weekOfYear, .day, .hour, .minute, .second], from: datePosted, to: now)
            
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
    
    init(withUid uid: String, imageUrl: String, ownerId: String, date: Date, amountOfLikes: Int) {
        super.init()
        
        defer {
            self.uid = uid
            self.imageUrl = imageUrl
            self.ownerId = ownerId
            self.datePosted = date
            self.likes = amountOfLikes
        }
    }

}
