//
//  PushNotification.swift
//  ThePost
//
//  Created by Andrew Robinson on 3/24/17.
//  Copyright © 2017 XYello, Inc. All rights reserved.
//

import UIKit
import OneSignal
import Firebase

class PushNotification: NSObject {

    private enum NotificationType: String {
        case chat = "chatNotificationType"
    }
    
    static let sender = PushNotification()

    private let chatAdditionalDataKey = "firebaseMessageID"
    
    private var likeTimer: Timer?
    private var socialLikeTimer: Timer?
    
    private let kLikeTimerInvertal = 2.0

    // MARK: - Helpers

    private func pushNotification(withHeading heading: String?, withMessage message: String, withPlayerIds ids: [String: Bool], withAdditionalData data: [String: Any]? = nil) {
        if let id = OneSignal.getPermissionSubscriptionState().subscriptionStatus.userId {
            var keys = [String]()
            for (key, _) in ids {
                if key != id {
                    keys.append(key)
                }
            }

            if keys.count > 0 {
                var infoDict: [String: Any] = ["contents": ["en": message], "include_player_ids": keys]
                if let heading = heading { infoDict["headings"] = ["en": heading] }
                if let data = data { infoDict["data"] = data }
                
                OneSignal.postNotification(infoDict)
            }
        }
    }

    static func createActionHandler() -> OSHandleNotificationActionBlock {
        return { result in
            if let result = result {
                let payload = result.notification.payload
                if let data = payload?.additionalData {
                    if let typeString = data["type"] as? String, let type = NotificationType(rawValue: typeString) {
                        switch type {
                        case .chat:
                            let userInfo: [String: Any] = [Conversation.conversationIDKey: data[Conversation.conversationIDKey] ?? "",
                                                           Conversation.productIDKey: data[Conversation.productIDKey] ?? "",
                                                           Conversation.productOwnerIDKey: data[Conversation.productOwnerIDKey] ?? "",
                                                           Conversation.otherPersonNameKey: data[Conversation.otherPersonNameKey] ?? ""]

                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: openChatControllerNotificationKey), object: nil, userInfo: userInfo)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Pushers
    
    func pushLiked(withProductName productName: String, withRecipientId id: String) {
        
        if let timer = likeTimer {
            timer.invalidate()
        }
        
        // Timers must be called on the main thread.
        DispatchQueue.main.async {
            
            // Force a delay, so a user can't spam notifications.
            self.likeTimer = Timer.scheduledTimer(withTimeInterval: self.kLikeTimerInvertal, repeats: false, block: { timer in
                
                let rc = RemoteConfig.remoteConfig()
                let headerValue = rc.configValue(forKey: "like_push_notification_heading")
                let messageValue = rc.configValue(forKey: "like_push_notification_message")
                let header = headerValue.stringValue
                let message = messageValue.stringValue
                if var m = message, var h = header {
                    
                    let userRef = Database.database().reference().child("users")
                    userRef.child(Auth.auth().currentUser!.uid).child("fullName").observeSingleEvent(of: .value, with: { snapshot in
                        if let name = snapshot.value as? String {
                            
                            userRef.child(id).child("pushNotificationIds").observeSingleEvent(of: .value, with: { snapshot in
                                if let ids = snapshot.value as? [String: Bool] {
                                    h = h.replacingOccurrences(of: "%USER%", with: name)
                                    
                                    m = m.replacingOccurrences(of: "%PRODUCT%", with: productName)
                                    m = m.replacingOccurrences(of: "%USER%", with: name)
                                    
                                    self.pushNotification(withHeading: h, withMessage: m, withPlayerIds: ids)
                                }
                            })
                            
                        }
                    })
                }
                
            })
        }
    }
    
    func pushLikedSocialPost(withRecipientId id: String) {
        
        if let timer = socialLikeTimer {
            timer.invalidate()
        }
        
        // Timers must be called on the main thread.
        DispatchQueue.main.async {
            
            // Force a delay, so a user can't spam notifications.
            self.socialLikeTimer = Timer.scheduledTimer(withTimeInterval: self.kLikeTimerInvertal, repeats: false, block: { timer in
                
                let rc = RemoteConfig.remoteConfig()
                let messageValue = rc.configValue(forKey: "social_like_push_notification_message")
                let message = messageValue.stringValue
                if var m = message {
                    
                    let userRef = Database.database().reference().child("users")
                    userRef.child(Auth.auth().currentUser!.uid).child("fullName").observeSingleEvent(of: .value, with: { snapshot in
                        if let name = snapshot.value as? String {
                            
                            userRef.child(id).child("pushNotificationIds").observeSingleEvent(of: .value, with: { snapshot in
                                if let ids = snapshot.value as? [String: Bool] {
                                    
                                    m = m.replacingOccurrences(of: "%USER%", with: name)
                                    
                                    self.pushNotification(withHeading: nil, withMessage: m, withPlayerIds: ids)
                                }
                            })
                            
                        }
                    })
                }
                
            })
        }
    }
    
    func pushChat(withMessage text: String, withConversation conversation: Conversation) {
        
        let rc = RemoteConfig.remoteConfig()
        let headerValue = rc.configValue(forKey: "chat_push_notification_heading")
        let messageValue = rc.configValue(forKey: "chat_push_notification_message")
        let header = headerValue.stringValue
        let message = messageValue.stringValue
        if var m = message, var h = header {
            
            let userRef = Database.database().reference().child("users")
            userRef.child(Auth.auth().currentUser!.uid).child("fullName").observeSingleEvent(of: .value, with: { snapshot in
                if let name = snapshot.value as? String {
                    
                    userRef.child(conversation.otherPersonId).child("pushNotificationIds").observeSingleEvent(of: .value, with: { snapshot in
                        if let ids = snapshot.value as? [String: Bool] {
                            h = h.replacingOccurrences(of: "%USER%", with: name)
                            
                            m = m.replacingOccurrences(of: "%MESSAGE%", with: text)

                            self.pushNotification(withHeading: h, withMessage: m, withPlayerIds: ids, withAdditionalData:
                                ["type": NotificationType.chat.rawValue,
                                 Conversation.conversationIDKey: conversation.id,
                                 Conversation.productOwnerIDKey: conversation.otherPersonId,
                                 Conversation.otherPersonNameKey: conversation.otherPersonName,
                                 Conversation.productIDKey: conversation.productID])
                        }
                    })
                    
                }
            })
        }
        
    }
    
    func pushReview(withRating rating: Int, withRecipientId id: String) {
        let rc = RemoteConfig.remoteConfig()
        let headerValue = rc.configValue(forKey: "review_push_notification_heading")
        let messageValue = rc.configValue(forKey: "review_push_notification_message")
        let header = headerValue.stringValue
        let message = messageValue.stringValue
        if var m = message, var h = header {
            
            let userRef = Database.database().reference().child("users")
            userRef.child(Auth.auth().currentUser!.uid).child("fullName").observeSingleEvent(of: .value, with: { snapshot in
                if let name = snapshot.value as? String {
                    
                    userRef.child(id).child("pushNotificationIds").observeSingleEvent(of: .value, with: { snapshot in
                        if let ids = snapshot.value as? [String: Bool] {
                            h = h.replacingOccurrences(of: "%USER%", with: name)
                            
                            var stars = ""
                            for _ in 1...rating {
                                stars += "⭐️"
                            }
                            
                            m = m.replacingOccurrences(of: "%USER%", with: name)
                            m = m.replacingOccurrences(of: "%STARS%", with: stars)
                            
                            self.pushNotification(withHeading: h, withMessage: m, withPlayerIds: ids)
                        }
                    })
                    
                }
            })
        }
    }

}
