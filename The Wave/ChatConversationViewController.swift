//
//  ChatConversationViewController.swift
//  ThePost
//
//  Created by Andrew Robinson on 1/6/17.
//  Copyright © 2017 XYello, Inc. All rights reserved.
//

import UIKit
import Firebase

let tabBarSwitchedToChatConversationNotification = "ktabBarSwitchedToChatConversationNotification"

class ChatConversationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var noChatsView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    var newConversation: Conversation?
    
    private var conversations: [Conversation] = []
    
    private var chatRef: DatabaseReference!
    private var userPresenceIndicatorReferences: [DatabaseReference] = []
    private var conversationReferences: [DatabaseQuery] = []
    private var productReferences: [DatabaseReference] = []
    
    private var hasLoaded = false
    private var totalNumberOfConversations: UInt = 0
    
    private var initialConversationsGrabbed: UInt = 0
    
    private var updateTimer: Timer?
    
    private var userIsViewingConversation: Conversation?
    
    private var shouldUpdateConversationsOnNextView = false
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        if let uid = Auth.auth().currentUser?.uid {
            chatRef = Database.database().reference().child("user-chats").child(uid)
        }
        
        observeConversations()
        
        NotificationCenter.default.addObserver(self, selector: #selector(userHasLoggedOut(notification:)), name: NSNotification.Name(rawValue: logoutNotificationKey), object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if shouldUpdateConversationsOnNextView {
            if let uid = Auth.auth().currentUser?.uid {
                chatRef = Database.database().reference().child("user-chats").child(uid)
                
                conversations.removeAll()
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
                
                observeConversations()
                
                shouldUpdateConversationsOnNextView = false
            }
        }
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
        
        let count = conversations.count
        
        if count == 0 {
            tableView.isHidden = true
            noChatsView.isHidden = false
        } else {
            noChatsView.isHidden = true
            tableView.isHidden = false
        }
        
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "conversationCell", for: indexPath) as! ConversationTableViewCell
        let conversation = conversations[indexPath.row]
        
        cell.profileImageView.sd_setImage(with: conversation.otherPersonProfileImageUrl, placeholderImage: #imageLiteral(resourceName: "DefaultProfilePicture"))
        
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

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let currentUserID = Auth.auth().currentUser?.uid {
                let conversation = conversations[indexPath.row]
                let basicRef = Database.database().reference()

                basicRef.child("user-chats").child(conversation.otherPersonId).child(conversation.id).removeValue()
                basicRef.child("user-chats").child(currentUserID).child(conversation.id).removeValue()
                basicRef.child("chats").child(conversation.id).removeValue()

            }

        }
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
                navigationController!.navigationBar.tintColor = .waveYellow
                
                vc.conversationToPass = conversation
                vc.hidesBottomBarWhenPushed = true
            }
        }
    }
    
    // MARK: - Helpers
    
    private func findAndSetIndex(forPreviousIndex index: Int, conversation: Conversation) -> Int {
        var indexToReturn = compareDates(withConversation: conversation)

        if index != -1 {
            let conversation = conversations.remove(at: index)

            tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            conversations.insert(conversation, at: indexToReturn)
        } else {
            if conversations.count > 1 {
                conversations.insert(conversation, at: indexToReturn)
            } else {
                conversations.append(conversation)
                indexToReturn = 0
            }
        }
        tableView.insertRows(at: [IndexPath(row: indexToReturn, section: 0)], with: .automatic)

        if index != -1 && index != indexToReturn {
            let presenence = userPresenceIndicatorReferences.remove(at: index)
            let conversationRef = conversationReferences.remove(at: index)
            let product = productReferences.remove(at: index)

            userPresenceIndicatorReferences.insert(presenence, at: indexToReturn)
            conversationReferences.insert(conversationRef, at: indexToReturn)
            productReferences.insert(product, at: indexToReturn)
        }

        return indexToReturn
    }

    private func compareDates(withConversation conversation: Conversation) -> Int {
        var iteratorIndex = 0
        var indexToReturn = -1

        for iteratorConversation in conversations {
            if indexToReturn == -1 {
                if let date = iteratorConversation.date {
                    if conversation.date! >= date {
                        indexToReturn = iteratorIndex
                    }
                } else {
                    indexToReturn = iteratorIndex
                }
            }

            iteratorIndex += 1
        }

        return indexToReturn
    }

    private func indexOfConversation(conversation: Conversation) -> Int {
        var i = 0
        var indexOfConversation = -1
        for convo in conversations {
            if convo.id != conversation.id {
                i += 1
            } else {
                indexOfConversation = i
            }
        }

        return indexOfConversation
    }
    
    // MARK: - Firebase observers
    
    private func observeConversations() {
        chatRef.observe(.childAdded, with: { snapshot in
            self.createChatObserver(forKey: snapshot.key)
        })

        chatRef.observe(.childRemoved, with: { snapshot in
            let convo = Conversation()
            convo.id = snapshot.key

            let index = self.indexOfConversation(conversation: convo)
            if index != -1 {
                let presenence = self.userPresenceIndicatorReferences.remove(at: index)
                let conversationRef = self.conversationReferences.remove(at: index)
                let product = self.productReferences.remove(at: index)

                presenence.removeAllObservers()
                conversationRef.removeAllObservers()
                product.removeAllObservers()

                if let viewingConvo = self.userIsViewingConversation {
                    if viewingConvo.id == convo.id {
                        self.navigationController?.popViewController(animated: true)
                    }
                }

                self.conversations.remove(at: index)
                self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            }
        })
    }
    
    private func createChatObserver(forKey key: String) {
        let newConvo = Conversation()
        newConvo.id = key
        
        initialConversationsGrabbed += 1
        let ref = Database.database().reference().child("chats").child(key)
        ref.observeSingleEvent(of: .value, with: { snapshot in
            if let chatDict = snapshot.value as? [String: AnyObject] {
                
                if let productID = chatDict["productID"] as? String {
                    newConvo.productID = productID
                }
                
                if let participantsDict = chatDict["participants"] as? [String: Bool] {
                    
                    self.hasLoaded = true
                    for (key, _) in participantsDict {
                        if key != Auth.auth().currentUser!.uid {
                            
                            let sellerRef = Database.database().reference().child("users").child(key)
                            sellerRef.observeSingleEvent(of: .value, with: { snapshot in
                                if let userDict = snapshot.value as? [String: Any] {
                                    
                                    newConvo.otherPersonId = key
                                    if let fullName = userDict["fullName"] as? String {
                                        newConvo.otherPersonName = fullName
                                    }
                                    if let profileUrl = userDict["profileImage"] as? String {
                                        newConvo.otherPersonProfileImageUrl = URL(string: profileUrl)
                                    }

                                    self.createLastMessageListener(forRef: ref, withConversation: newConvo)
                                    
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
        let userRef = Database.database().reference().child("users").child(key)
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
    
    private func createLastMessageListener(forRef ref: DatabaseReference, withConversation conversation: Conversation) {
        let messagesQueryRef = ref.child("messages").queryLimited(toLast: 1)
        messagesQueryRef.observe(.value, with: { snapshot in
            if let messageDict = snapshot.value as? [String: AnyObject] {
                if let messageData = messageDict.values.first as? [String: String] {
                    if let text = messageData["text"] {
                        conversation.lastSentMessage = text
                        
                        if let sender = messageData["senderId"] {
                            if let viewingConvo = self.userIsViewingConversation, viewingConvo.id == conversation.id {
                            } else {
                                if let _ = conversation.lastSentMessageTime, sender != Auth.auth().currentUser?.uid {
                                    conversation.unreadMessageCount += 1
                                }
                            }
                        }


                        var previousIndex = self.indexOfConversation(conversation: conversation)

                        if let time = messageData["time"] {
                            conversation.lastSentMessageTime = time

                            previousIndex = self.findAndSetIndex(forPreviousIndex: previousIndex, conversation: conversation)
                            self.createPresenceListener(forKey: conversation.otherPersonId, withConversation: conversation)
                            self.getProductDetailsWith(conversationIndex: self.conversations.count - 1, withConversation: conversation)
                        }
                        
                        let indexPath = IndexPath(row: previousIndex, section: 0)
                        self.tableView.reloadRows(at: [indexPath], with: .automatic)
                    }
                }
            }
        })
        conversationReferences.append(messagesQueryRef)
    }
    
    private func getProductDetailsWith(conversationIndex index: Int, withConversation conversation: Conversation) {
        let productRef = Database.database().reference().child("products").child(conversations[index].productID)
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
    
    // MARK: - Notifications
    
    @objc private func userHasLoggedOut(notification: NSNotification) {
        shouldUpdateConversationsOnNextView = true
    }
    
}
