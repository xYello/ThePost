//
//  BadgeStatus.swift
//  The Wave
//
//  Created by Andrew Robinson on 10/29/17.
//  Copyright © 2017 XYello, Inc. All rights reserved.
//

enum BadgeStatus: String {
    case verified = "verified"
    case admin = "admin"
    case unicorn = "unicorn"

    func getImage() -> UIImage {
        switch self {
        case .verified:
            return #imageLiteral(resourceName: "VerifiedBadge")
        case .admin:
            return #imageLiteral(resourceName: "AdminBadge")
        case .unicorn:
            return #imageLiteral(resourceName: "AndrewBadge")
        }
    }
}
