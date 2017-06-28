//
//  User.swift
//  ThePost
//
//  Created by Andrew Robinson on 12/27/16.
//  Copyright © 2016 The Post. All rights reserved.
//

import UIKit

class User: NSObject {

    var uid: String!
    
    var fullName: String = "Seller Name"
    var email: String?
    var profileUrl: URL!
    
    var starRating = 0
    var totalNumberOfReviews = 0
    
    var twitterVerified = false
    var facebookVerified = false
    
}
