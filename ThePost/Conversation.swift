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
