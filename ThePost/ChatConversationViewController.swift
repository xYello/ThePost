//
//  ChatConversationViewController.swift
//  ThePost
//
//  Created by Andrew Robinson on 1/6/17.
//  Copyright © 2017 The Post. All rights reserved.
//

import UIKit
import Firebase

let tabBarSwitchedToChatConversationNotification = "ktabBarSwitchedToChatConversationNotification"

class ChatConversationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var newConversation: Conversation?
    
    private var conversations: [Conversation] = []
    
    private var chatRef: FIRDatabaseReference!
    private var userPresenceIndicatorReferences: [FIRDatabaseReference] = []
    private var conversationReferences: [FIRDatabaseQuery] = []
    private var productReferences: [FIRDatabaseReference] = []
    
    private var hasLoaded = false
    private var totalNumberOfConversations: UInt = 0
    
    private var initialConversationsGrabbed: UInt = 0
    
    private var updateTimer: Timer?
    
    private var userIsViewingConversation: Conversation?
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        if let uid = FIRAuth.auth()?.currentUser?.uid {
            chatRef = FIRDatabase.database().reference().child("user-chats").child(uid)
        }
        
        observeConversations()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let new = newConversation {
            if let tabBar = tabBarController as? SlidingSelectionTabBarController {
                tabBar.hideShadow()
            }
            
            for convo in conversations {
                if convo.otherPersonId == new.otherPersonId && convo.productID == new.productID {
                    newConversation = nil
                    performSegue(withIdentifier: "chatViewController", sender: convo)
                }
            }
            
            chatRef.observeSingleEvent(of: .value, with: { snapshot in
                self.totalNumberOfConversations = snapshot.childrenCount
                if !snapshot.hasChildren() {
                    self.newConversation = nil
                    self.performSegue(withIdentifier: "chatViewController", sender: new)
                } else {
                    if let convoStillExists = self.newConversation, self.hasLoaded {
                        self.newConversation = nil
                        self.performSegue(withIdentifier: "chatViewController", sender: convoStillExists)
                    }
                }
            })
        } else {
            if let tabBar = tabBarController as? SlidingSelectionTabBarController {
                tabBar.showShadow()
            }
        }
        
        if let timer = updateTimer {
            tableView.reloadSections([0], with: .automatic)
            timer.invalidate()
        }
        updateTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true, block: { timer in
            self.tableView.reloadSections([0], with: .automatic)
        })
        
        userIsViewingConversation = nil
    }
    
    deinit {
        chatRef.removeAllObservers()
        for ref in conversationReferences {
            ref.removeAllObservers()
        }
        for ref in productReferences {
            ref.removeAllObservers()
        }
        for ref in userPresenceIndicatorReferences {
            ref.removeAllObservers()
        }
    }
    
    // MARK: - TableView datasource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "conversationCell", for: indexPath) as! ConversationTableViewCell
        let conversation = conversations[indexPath.row]
        
        cell.profileImageView.image = #imageLiteral(resourceName: "ETHANPROFILESAMPLE")
        
        cell.personNameLabel.text = conversation.otherPersonName
        
        cell.messageCountUnread = conversation.unreadMessageCount
        if let lastMessage = conversation.lastSentMessage {
            cell.recentMessageLabel.text = lastMessage
        } else {
            cell.recentMessageLabel.text = ""
        }
        cell.timeLabel.text = conversation.relativeDate
        
        cell.presenceIndicator.isHidden = !conversation.isOtherPersonOnline
        
        cell.isProductSold = conversation.isProductSold
        if conversation.isProductSold {
            cell.profileImageView.alpha = 0.2
        } else {
            cell.profileImageView.alpha = 1.0
        }
        
        return cell
    }
    
    // MARK: - TableView delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let tabBar = tabBarController as? SlidingSelectionTabBarController {
            tabBar.hideShadow()
        }
        
        let conversation = conversations[indexPath.row]
        conversation.unreadMessageCount = 0
        userIsViewingConversation = conversation
        performSegue(withIdentifier: "chatViewController", sender: conversation)
    }
    
    // MARK: - Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if let conversation = sender as? Conversation {
            if let vc = segue.destination as? ChatContainerViewController {
                navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
                navigationController!.navigationBar.tintColor = #colorLiteral(red: 0.7647058824, green: 0.768627451, blue: 0.7137254902, alpha: 1)
                
                vc.conversationToPass = conversation
                vc.hidesBottomBarWhenPushed = true
            }
        }
    }
    
    // MARK: - Helpers
    
    private func findAndSetIndex(forPreviousIndex index: Int) {
        if conversations.count > 1 {
            let conversation = conversations.remove(at: index)
            tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            
            var iteratorIndex = 0
            var indexToPlaceAt = -1
            for iteratorConversation in conversations {
                if indexToPlaceAt == -1 {
                    if let date = iteratorConversation.date {
                        if conversation.date! >= date {
                            indexToPlaceAt = iteratorIndex
                        }
                    } else {
                        indexToPlaceAt = iteratorIndex
                    }
                }
                
                iteratorIndex += 1
            }
            
            conversations.insert(conversation, at: indexToPlaceAt)
            tableView.insertRows(at: [IndexPath(row: indexToPlaceAt, section: 0)], with: .automatic)
        }
    }
    
    // MARK: - Firebase observers
    
    private func observeConversations() {
        chatRef.observe(.childAdded, with: { snapshot in
            self.createChatObserver(forKey: snapshot.key)
        })
    }
    
    private func createChatObserver(forKey key: String) {
        let newConvo = Conversation()
        newConvo.id = key
        
        initialConversationsGrabbed += 1
        let ref = FIRDatabase.database().reference().child("chats").child(key)
        ref.observeSingleEvent(of: .value, with: { snapshot in
            if let chatDict = snapshot.value as? [String: AnyObject] {
                
                if let productID = chatDict["productID"] as? String {
                    newConvo.productID = productID
                }
                
                if let participantsDict = chatDict["participants"] as? [String: Bool] {
                    
                    self.hasLoaded = true
                    for (key, _) in participantsDict {
                        if key != FIRAuth.auth()!.currentUser!.uid {
                            
                            let userRef = FIRDatabase.database().reference().child("users").child(key).child("fullName")
                            userRef.observeSingleEvent(of: .value, with: { snapshot in
                                if let name = snapshot.value as? String {
                                    newConvo.otherPersonId = key
                                    newConvo.otherPersonName = name
                                    
                                    self.conversations.append(newConvo)
                                    self.tableView.reloadData()
                                    
                                    let index = self.conversations.count - 1
                                    self.createPresenceListener(forKey: key, withConversation: newConvo)
                                    self.createLastMessageListener(forRef: ref, withConversation: newConvo)
                                    self.getProductDetailsWith(conversationIndex: index, withConversation: newConvo)
                                    
                                    if let preLaunchConvo = self.newConversation {
                                        if newConvo.otherPersonId == preLaunchConvo.otherPersonId && newConvo.productID == preLaunchConvo.productID {
                                            self.newConversation = nil
                                            self.performSegue(withIdentifier: "chatViewController", sender: newConvo)
                                        } else if self.initialConversationsGrabbed == self.totalNumberOfConversations {
                                            self.newConversation = nil
                                            self.performSegue(withIdentifier: "chatViewController", sender: preLaunchConvo)
                                        }
                                    }
                                }
                            })
                            
                        }
                    }
                    
                }
                
            }
        })
    }
    
    private func createPresenceListener(forKey key: String, withConversation conversation: Conversation) {
        let userRef = FIRDatabase.database().reference().child("users").child(key)
        userRef.child("isOnline").observe(.value, with: { snapshot in
            if let isOnline = snapshot.value as? Bool {
                var iteratorIndex = 0
                var indexPathsToUpdate: [IndexPath] = []
                for convo in self.conversations {
                    if convo.otherPersonId == key {
                        convo.isOtherPersonOnline = isOnline
                        indexPathsToUpdate.append(IndexPath(row: iteratorIndex, section: 0))
                    }
                    
                    iteratorIndex += 1
                }
                
                self.tableView.reloadRows(at: indexPathsToUpdate, with: .automatic)
            } else {
                var iteratorIndex = 0
                var indexPathsToUpdate: [IndexPath] = []
                for convo in self.conversations {
                    if convo.otherPersonId == key {
                        convo.isOtherPersonOnline = false
                        indexPathsToUpdate.append(IndexPath(row: iteratorIndex, section: 0))
                    }
                    
                    iteratorIndex += 1
                }
                
                self.tableView.reloadRows(at: indexPathsToUpdate, with: .automatic)
            }
        })
        userPresenceIndicatorReferences.append(userRef)
    }
    
    private func createLastMessageListener(forRef ref: FIRDatabaseReference, withConversation conversation: Conversation) {
        let messagesQueryRef = ref.child("messages").queryLimited(toLast: 1)
        messagesQueryRef.observe(.value, with: { snapshot in
            if let messageDict = snapshot.value as? [String: AnyObject] {
                if let messageData = messageDict.values.first as? [String: String] {
                    if let text = messageData["text"] {
                        var iteratorIndex = 0
                        var conversationIndex = -1
                        for convo in self.conversations {
                            if convo.id == conversation.id {
                                conversationIndex = iteratorIndex
                            }
                            
                            iteratorIndex += 1
                        }
                        
                        conversation.lastSentMessage = text
                        
                        if let sender = messageData["senderId"] {
                            if let viewingConvo = self.userIsViewingConversation, viewingConvo.id == conversation.id {
                            } else {
                                if let _ = conversation.lastSentMessageTime, sender != FIRAuth.auth()?.currentUser?.uid {
                                    conversation.unreadMessageCount += 1
                                }
                            }
                        }
                        
                        if let time = messageData["time"] {
                            conversation.lastSentMessageTime = time
                            
                            // Order conversations based on last sent
                            self.findAndSetIndex(forPreviousIndex: conversationIndex)
                        }
                        
                        let indexPath = IndexPath(row: conversationIndex, section: 0)
                        self.tableView.reloadRows(at: [indexPath], with: .automatic)
                    }
                }
            }
        })
        conversationReferences.append(messagesQueryRef)
    }
    
    private func getProductDetailsWith(conversationIndex index: Int, withConversation conversation: Conversation) {
        let productRef = FIRDatabase.database().reference().child("products").child(conversations[index].productID)
        productRef.observe(.value, with: { snapshot in
            if let productDict = snapshot.value as? [String: Any] {
                var iteratorIndex = 0
                var conversationIndex = -1
                for convo in self.conversations {
                    if convo.id == conversation.id {
                        conversationIndex = iteratorIndex
                    }
                    
                    iteratorIndex += 1
                }
                
                if let name = productDict["name"] as? String {
                    // TODO: Product Name?
                    conversation.productName = name
                }
                
                if let isSold = productDict["isSold"] as? Bool {
                    if isSold {
                        conversation.isProductSold = true
                    }
                }
                
                let indexPath = IndexPath(row: conversationIndex, section: 0)
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        })
        productReferences.append(productRef)
    }
    
}
