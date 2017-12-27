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

    var mainVC: UIViewController?
    
    private var userRef: DatabaseReference?
    private let reachability = Reachability()!

    // MARK: - Application delegate

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        FirebaseApp.configure()
    
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        Fabric.with([Answers.self, Crashlytics.self])
        Twitter.sharedInstance().start(withConsumerKey: TwitterInfoKeys.consumer, consumerSecret: TwitterInfoKeys.consumerSecret)
        
        OneSignal.initWithLaunchOptions(launchOptions, appId: OneSignalKeys.appId, handleNotificationAction: nil, settings: ["kOSSettingsKeyAutoPrompt": false])
        OneSignal.inFocusDisplayType = .none

        SentryManager.shared.registerWithSentry()

        self.window = UIWindow(frame: UIScreen.main.bounds)
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)

        mainVC = mainStoryboard.instantiateViewController(withIdentifier: "slidingSelectionTabBarController")
        self.window!.rootViewController = mainVC!
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
        
        if let uid = Auth.auth().currentUser?.uid {
            Database.database().reference().child("users").child(uid).child("isOnline").removeValue()
        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        
        if let uid = Auth.auth().currentUser?.uid {
            Database.database().reference().child("users").child(uid).child("isOnline").setValue(true)
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

    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {

        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
            let url = userActivity.webpageURL,
            let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
                return false
        }

        let parameters = components.path.split(separator: "/", maxSplits: 10, omittingEmptySubsequences: false)
        if parameters.count == 2 && parameters[0] == "product/" {
            print("\(parameters[1])")
        }

        application.open(url, options: [:], completionHandler: nil)

        return false
    }

    // MARK: - Helpers

    func topNavController() -> UIViewController? {
        guard let tab = mainVC else { return nil }

        var top: UIViewController? = tab
        while top?.presentedViewController != nil {
            top = top?.presentedViewController
        }

        return top
    }
    
    // MARK: - OneSignal && Firebase
    
    private func saveOneSignalId() {
        if let id = OneSignal.getPermissionSubscriptionState().subscriptionStatus.userId {
            let ref = Database.database().reference().child("users").child(Auth.auth().currentUser!.uid).child("pushNotificationIds")
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
        if let pass = KeychainWrapper.standard.string(forKey: UserInfoKeys.UserPass), let email = Auth.auth().currentUser?.email {
            let credential = EmailAuthProvider.credential(withEmail: email, password: pass)
            Auth.auth().currentUser!.reauthenticate(with: credential, completion: { error in
                if let error = error {
                    print("Error reauthenticating: \(error.localizedDescription)")
                    SentryManager.shared.sendEvent(withError: error)
                } else {
                    self.userRef = Database.database().reference().child("users").child(Auth.auth().currentUser!.uid).child("isOnline")
                    self.userRef!.onDisconnectRemoveValue()
                    self.userRef!.setValue(true)
                    self.saveOneSignalId()

                    let user = User()
                    user.uid = Auth.auth().currentUser!.uid
                    SentryManager.shared.addUserCrediantials(withUser: user)
                }

            })
        } else if FBSDKAccessToken.current() != nil {
            let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
            Auth.auth().currentUser?.reauthenticate(with: credential, completion: { error in
                if let error = error {
                    print("Error reauthenticating: \(error.localizedDescription)")
                    SentryManager.shared.sendEvent(withError: error)
                } else {
                    self.userRef = Database.database().reference().child("users").child(Auth.auth().currentUser!.uid).child("isOnline")
                    self.userRef!.onDisconnectRemoveValue()
                    self.userRef!.setValue(true)
                    self.saveOneSignalId()

                    let user = User()
                    user.uid = Auth.auth().currentUser!.uid
                    SentryManager.shared.addUserCrediantials(withUser: user)
                }

            })
        } else if let token = KeychainWrapper.standard.string(forKey: TwitterInfoKeys.token), let secret = KeychainWrapper.standard.string(forKey: TwitterInfoKeys.secret) {
            let credential = TwitterAuthProvider.credential(withToken: token, secret: secret)
            Auth.auth().currentUser?.reauthenticate(with: credential, completion: { error in
                if let error = error {
                    print("Error reauthenticating: \(error.localizedDescription)")
                    SentryManager.shared.sendEvent(withError: error)
                } else {
                    self.userRef = Database.database().reference().child("users").child(Auth.auth().currentUser!.uid).child("isOnline")
                    self.userRef!.onDisconnectRemoveValue()
                    self.userRef!.setValue(true)
                    self.saveOneSignalId()

                    let user = User()
                    user.uid = Auth.auth().currentUser!.uid
                    SentryManager.shared.addUserCrediantials(withUser: user)
                }

            })
        } else {
            do {
                try Auth.auth().signOut()
            } catch {
                print("Error signing out")
                SentryManager.shared.sendEvent(withError: error)
            }
        }

        let rc = RemoteConfig.remoteConfig()
        rc.fetch(completionHandler: { status, error in
            if let er = error {
                print("Error getting remote config: \(er.localizedDescription)")
                SentryManager.shared.sendEvent(withError: er)
            }
            rc.activateFetched()
        })
    }
    
}

