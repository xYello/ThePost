//
//  SentryManager.swift
//  The Wave
//
//  Created by Andrew Robinson on 6/27/17.
//  Copyright © 2017 The Post. All rights reserved.
//

import UIKit
import Sentry

class SentryManager: NSObject {

    static let shared = SentryManager()

    private var sentry: Client!

    func registerWithSentry() {
        do {
            Client.shared = try Client(dsn: "***REMOVED***")
            try Client.shared?.startCrashHandler()
            sentry = Client.shared!
        } catch let error {
            print("\(error)")
            // Wrong DSN or KSCrash not installed
        }
    }

}
