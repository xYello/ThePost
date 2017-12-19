//
//  Constants.swift
//  ThePost
//
//  Created by Michael Blades on 1/13/17.
//  Copyright © 2017 XYello, Inc. All rights reserved.
//

let openChatControllerNotificationKey = "kOpenChatControllerNotification"

let logoutNotificationKey = "kLogoutNotificationKey"
let nameChangeNotificationKey = "kNameChangeNotificationKey"
let buildTrustChangeNotificationKey = "kBuildTrustHasUpdateNotificationKey"

struct UserInfoKeys {
    static let UserPass = "userPass"
    static let UserSelectedJeep = "userSelectedJeep"
    static let UserSelectedRadius = "userSelectedRadius"
}

struct TwitterInfoKeys {
    static let token = "twitterToken"
    static let secret = "twitterTokenSecret"

    static let consumer = "***REMOVED***"
    static let consumerSecret = "***REMOVED***"
}

struct ProductListingType {
    static let small = "kProductListingTypeSmall"
    static let wide = "kProductListingTypeWide"
    
    static let key = "kProductListingViewType"
}

struct OneSignalKeys {
    static let appId = "***REMOVED***"
}

struct PolicyLinks {
    static let privacy = "https://www.iubenda.com/privacy-policy/8125887"
    static let termsOfUse = "https://termsfeed.com/terms-conditions/51d3180f8e157ed280d55d34bc6b5d41"
}

struct CornerRadius {
    static let constant: CGFloat = 8.0
}

struct WebsiteLinks {
    static let main = "thewaveapp.com/"
    static let products = "thewaveapp.com/prouducts/"
}
