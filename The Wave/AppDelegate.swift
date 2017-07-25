//
//  AppDelegate.swift
//  ThePost
//
//  Created by Andrew Robinson on 12/23/16.
//  Copyright © 2016 XYello, Inc. All rights reserved.
//

import UIKit
import Firebase
import Fabric
import Crashlytics
import TwitterKit
import SwiftKeychainWrapper
import FBSDKCoreKit
import OneSignal
import ReachabilitySwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    private var userRef: FIRDatabaseReference?
    private let reachability = Reachability()!

    // MARK: - Application delegate

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        FIRApp.configure()
    
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        Fabric.with([Answers.self, Crashlytics.self, Twitter.self])
        
        OneSignal.initWithLaunchOptions(launchOptions, appId: OneSignalKeys.appId, handleNotificationAction: nil, settings: ["kOSSettingsKeyAutoPrompt": false])
        OneSignal.inFocusDisplayType = .none

        SentryManager.shared.registerWithSentry()

        self.window = UIWindow(frame: UIScreen.main.bounds)
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        self.window!.rootViewController = mainStoryboard.instantiateViewController(withIdentifier: "slidingSelectionTabBarController") as! SlidingSelectionTabBarController
        self.window!.makeKeyAndVisible()
        
        if reachability.isReachable {
            reauthenticate()
        } else {
            reachability.whenReachable = { reachability in
                self.reauthenticate()
            }
            do { try reachability.startNotifier() } catch {
                SentryManager.shared.sendEvent(withMessage: "Reachability has failed to initialize its notifications!")
            }
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        if let uid = FIRAuth.auth()?.currentUser?.uid {
            FIRDatabase.database().reference().child("users").child(uid).child("isOnline").removeValue()
        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        
        if let uid = FIRAuth.auth()?.currentUser?.uid {
            FIRDatabase.database().reference().child("users").child(uid).child("isOnline").setValue(true)
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        Twitter.sharedInstance().application(app, open: url, options: options)
        return FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: options[.sourceApplication] as! String!, annotation: options[.annotation])
    }
    
    // MARK: - OneSignal && Firebase
    
    private func saveOneSignalId() {
        if let id = OneSignal.getPermissionSubscriptionState().subscriptionStatus.userId {
            let ref = FIRDatabase.database().reference().child("users").child(FIRAuth.auth()!.currentUser!.uid).child("pushNotificationIds")
            ref.observeSingleEvent(of: .value, with: { snapshot in
                if var ids = snapshot.value as? [String: Bool] {
                    ids[id] = true
                    ref.updateChildValues(ids)
                } else {
                    let ids = [id: true]
                    ref.updateChildValues(ids)
                }
            })
        }
    }

    private func reauthenticate() {
        if let pass = KeychainWrapper.standard.string(forKey: UserInfoKeys.UserPass), let email = FIRAuth.auth()?.currentUser?.email {
            let credential = FIREmailPasswordAuthProvider.credential(withEmail: email, password: pass)
            FIRAuth.auth()!.currentUser!.reauthenticate(with: credential, completion: { error in
                if let error = error {
                    print("Error reauthenticating: \(error.localizedDescription)")
                    SentryManager.shared.sendEvent(withError: error)
                    do {
                        try FIRAuth.auth()?.signOut()
                    } catch {
                        print("Error signing out")
                        SentryManager.shared.sendEvent(withError: error)
                    }
                } else {
                    self.userRef = FIRDatabase.database().reference().child("users").child(FIRAuth.auth()!.currentUser!.uid).child("isOnline")
                    self.userRef!.onDisconnectRemoveValue()
                    self.userRef!.setValue(true)
                    self.saveOneSignalId()
                }

            })
        } else if FBSDKAccessToken.current() != nil {
            let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
            FIRAuth.auth()?.currentUser?.reauthenticate(with: credential, completion: { error in
                if let error = error {
                    print("Error reauthenticating: \(error.localizedDescription)")
                    SentryManager.shared.sendEvent(withError: error)
                    do {
                        try FIRAuth.auth()?.signOut()
                    } catch {
                        print("Error signing out")
                        SentryManager.shared.sendEvent(withError: error)
                    }
                } else {
                    self.userRef = FIRDatabase.database().reference().child("users").child(FIRAuth.auth()!.currentUser!.uid).child("isOnline")
                    self.userRef!.onDisconnectRemoveValue()
                    self.userRef!.setValue(true)
                    self.saveOneSignalId()
                }

            })
        } else if let token = KeychainWrapper.standard.string(forKey: TwitterInfoKeys.token), let secret = KeychainWrapper.standard.string(forKey: TwitterInfoKeys.secret) {
            let credential = FIRTwitterAuthProvider.credential(withToken: token, secret: secret)
            FIRAuth.auth()?.currentUser?.reauthenticate(with: credential, completion: { error in
                if let error = error {
                    print("Error reauthenticating: \(error.localizedDescription)")
                    SentryManager.shared.sendEvent(withError: error)
                    do {
                        try FIRAuth.auth()?.signOut()
                    } catch {
                        print("Error signing out")
                        SentryManager.shared.sendEvent(withError: error)
                    }
                } else {
                    self.userRef = FIRDatabase.database().reference().child("users").child(FIRAuth.auth()!.currentUser!.uid).child("isOnline")
                    self.userRef!.onDisconnectRemoveValue()
                    self.userRef!.setValue(true)
                    self.saveOneSignalId()
                }

            })
        } else {
            do {
                try FIRAuth.auth()?.signOut()
            } catch {
                print("Error signing out")
                SentryManager.shared.sendEvent(withError: error)
            }
        }

        let rc = FIRRemoteConfig.remoteConfig()
        rc.fetch(completionHandler: { status, error in
            if let er = error {
                // TODO: Update with error reporting.
                print("Error getting remote config: \(er.localizedDescription)")
                SentryManager.shared.sendEvent(withError: er)
            }
            rc.activateFetched()
        })
    }
    
}

