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
    private var conversationReferences: [FIRDatabaseQuery] = []
    
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
            
            performSegue(withIdentifier: "chatViewController", sender: new)
            newConversation = nil
        } else {
            if let tabBar = tabBarController as? SlidingSelectionTabBarController {
                tabBar.showShadow()
            }
        }
    }
    
    deinit {
        chatRef.removeAllObservers()
        for ref in conversationReferences {
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
        
        if let lastMessage = conversation.lastSentMessage {
            cell.recentMessageLabel.text = lastMessage
        } else {
            cell.recentMessageLabel.text = ""
        }
        
        cell.timeLabel.text = "Now"
        
        return cell
    }
    
    // MARK: - TableView delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let tabBar = tabBarController as? SlidingSelectionTabBarController {
            tabBar.hideShadow()
        }
        
        let conversation = conversations[indexPath.row]
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
    
    // MARK: - Firebase observers
    
    private func observeConversations() {
        chatRef.observe(.childAdded, with: { snapshot in
            self.createChatObserver(forKey: snapshot.key)
        })
    }
 
    private func createChatObserver(forKey key: String) {
        let newConvo = Conversation()
        newConvo.id = key
 
        let ref = FIRDatabase.database().reference().child("chats").child(key)
        ref.observeSingleEvent(of: .value, with: { snapshot in
            if let chatDict = snapshot.value as? [String: AnyObject] {
                
                if let productID = chatDict["productID"] as? String {
                    newConvo.productID = productID
                }
                
                if let participantsDict = chatDict["participants"] as? [String: Bool] {
                    
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
                                    self.createLastMessageListener(forRef: ref, withConversationIndex: index)
                                }
                            })
                            
                        }
                    }
                    
                }
                
            }
        })
    }
    
    private func createLastMessageListener(forRef ref: FIRDatabaseReference, withConversationIndex index: Int) {
        let messagesQueryRef = ref.child("messages").queryLimited(toLast: 1)
        messagesQueryRef.observe(.value, with: { snapshot in
            if let messageDict = snapshot.value as? [String: AnyObject] {
                if let messageData = messageDict.values.first as? [String: String] {
                    if let text = messageData["text"] {
                        let conversation = self.conversations[index]
                        conversation.lastSentMessage = text
                        
                        let indexPath = IndexPath(row: index, section: 0)
                        self.tableView.reloadRows(at: [indexPath], with: .automatic)
                    }
                }
            }
        })
        conversationReferences.append(messagesQueryRef)
    }
    
}
