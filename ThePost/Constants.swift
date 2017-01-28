//
//  Constants.swift
//  ThePost
//
//  Created by Michael Blades on 1/13/17.
//  Copyright © 2017 The Post. All rights reserved.
//

import UIKit

class Constants: NSObject {
    
    enum UserInfoKeys : String {
        case UserCity = "userCity"
        case UserState = "userState"
        case UserPass = "userPass"
        case UserSelectedJeep = "userSelectedJeep"
    }
    
    enum TwitterInfoKeys: String {
        case token = "twitterToken"
        case secret = "twitterTokenSecret"
    }

}
