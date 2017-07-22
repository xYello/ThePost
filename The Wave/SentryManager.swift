//
//  SentryManager.swift
//  The Wave
//
//  Created by Andrew Robinson on 6/27/17.
//  Copyright © 2017 XYello, Inc. All rights reserved.
//

import UIKit
import Sentry
import SwiftKeychainWrapper

class SentryManager: NSObject {

    static let shared = SentryManager()

    private var sentry: Client! {
        get {
            return Client.shared!
        }
    }

    // MARK: - Register and clears

    func registerWithSentry() {
        do {
            Client.shared = try Client(dsn: "***REMOVED***")
            try Client.shared?.startCrashHandler()
            addExtras()
        } catch let error {
            print("\(error)")
            // Wrong DSN or KSCrash not installed
        }
    }

    func addUserCrediantials(withUser user: User) {
        let sentryUser = Sentry.User(userId: user.uid)
        sentryUser.email = user.email
        sentry.user = sentryUser

        addExtras()
    }

    func clearUserCredentials() {
        sentry.clearContext()

        addExtras()
    }

    // MARK: - Send events

    func sendEvent(withError error: Error) {
        let ns = error as NSError

        let event = Event(level: .debug)
        event.message = "Error: \(error.localizedDescription)"
        event.tags = [
            "Code": String(ns.code),
            "Message": error.localizedDescription,
            "Domain": String(ns.domain),
            "User Info": ns.userInfo.description
        ]

        sentry.send(event: event)
    }

    func sendEvent(withMessage message: String) {
        let event = Event(level: .debug)
        event.message = message

        sentry.send(event: event)
    }

    // MARK: - Privates

    private func addExtras() {
        var viewType = ProductListingType.small
        if let type = KeychainWrapper.standard.string(forKey: ProductListingType.key) {
            if type == ProductListingType.wide {
                viewType = ProductListingType.wide
            }
        }

        sentry.extra = [
            "Selected Jeep": KeychainWrapper.standard.string(forKey: UserInfoKeys.UserSelectedJeep) ?? "",
            "Product Listing View Type": viewType
        ]
    }

}
