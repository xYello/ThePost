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
    
    var imageUrl: String!
    var userid: String!
    var datePosted: Date!
    
    init(withUid uid: String, imageUrl: String, userid: String, date: Date) {
        super.init()
        
        defer {
            self.uid = uid
            self.imageUrl = imageUrl
            self.userid = userid
            self.datePosted = date
        }
    }

}
