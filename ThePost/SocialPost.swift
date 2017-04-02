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
    
    var imageUrl: String!
    var username: String!
    var likeCount: Int!
    var userid: String!
    var datePosted: Date!
    
    init(withUsername username: String, imageUrl: String, likeCount: Int, userid: String, date: Date) {
        super.init()
        
        defer {
            self.imageUrl = imageUrl
            self.username = username
            self.likeCount = likeCount
            self.userid = userid
            self.datePosted = date
        }
    }

}
