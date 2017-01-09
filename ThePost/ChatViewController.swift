//
//  ChatViewController.swift
//  ThePost
//
//  Created by Andrew Robinson on 1/8/17.
//  Copyright © 2017 The Post. All rights reserved.
//

import UIKit
import Firebase
import JSQMessagesViewController

class ChatViewController: JSQMessagesViewController {
    
    @IBOutlet weak var testView: UIView!
    
    private var conversationRef: FIRDatabaseReference!
    private var messageRef: FIRDatabaseReference!
    private var messageQueryRef: FIRDatabaseQuery!
    private var userTypingRef: FIRDatabaseReference!
    private var otherUserTypingQueryRef: FIRDatabaseQuery!
    
    var conversation: Conversation! {
        didSet {
            title = conversation.otherPersonName
        }
    }
    
    private var messages = [JSQMessage]()
    
    private var outgoingBubble: JSQMessagesBubbleImage!
    private var incomingBubble: JSQMessagesBubbleImage!
    
    private var localTyping = false
    private var isTyping: Bool {
        get {
            return localTyping
        }
        set {
            localTyping = newValue
            userTypingRef.setValue(newValue)
        }
    }
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        senderId = FIRAuth.auth()!.currentUser!.uid
        senderDisplayName = conversation.otherPersonName
        
        conversationRef = FIRDatabase.database().reference().child("chats").child(conversation.id)
        messageRef = conversationRef.child("messages")
        userTypingRef = conversationRef.child("typingIndicator").child(senderId)
        otherUserTypingQueryRef = conversationRef.child("typingIndicator").child(conversation.otherPersonId)
        
        collectionView.backgroundColor = #colorLiteral(red: 0.1882352941, green: 0.2196078431, blue: 0.2784313725, alpha: 1)
        
        inputToolbar.contentView.backgroundColor = #colorLiteral(red: 0.9098039216, green: 0.9058823529, blue: 0.8235294118, alpha: 1)
        inputToolbar.contentView.textView.backgroundColor = #colorLiteral(red: 0.1882352941, green: 0.2196078431, blue: 0.2784313725, alpha: 1)
        inputToolbar.contentView.textView.textColor = #colorLiteral(red: 0.9098039216, green: 0.9058823529, blue: 0.8235294118, alpha: 1)
        
        outgoingBubble = setupOutgoingBubble()
        incomingBubble = setupIncomingBubble()
        
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = .zero
        collectionView!.collectionViewLayout.incomingAvatarViewSize = .zero
        
        observeMessages()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        collectionView.collectionViewLayout.springinessEnabled = true
        
        observeTyping()
    }
    
    deinit {
        messageQueryRef.removeAllObservers()
        otherUserTypingQueryRef.removeAllObservers()
    }
    
    // MARK: - JSQCollectionView datasource
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.row]
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        let message = messages[indexPath.row]
        
        if message.senderId == senderId {
            cell.textView!.textColor = UIColor.white
        } else {
            cell.textView!.textColor = UIColor.black
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        var imageToReturn: JSQMessageBubbleImageDataSource
        if messages[indexPath.row].senderId == senderId {
            imageToReturn = outgoingBubble
        } else {
            imageToReturn = incomingBubble
        }
        
        return imageToReturn
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    // MARK: - JSQBubble Colors
    
    private func setupOutgoingBubble() -> JSQMessagesBubbleImage {
        return JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImage(with: #colorLiteral(red: 0.8470588235, green: 0.337254902, blue: 0.2156862745, alpha: 1))
    }
    
    private func setupIncomingBubble() -> JSQMessagesBubbleImage {
        return JSQMessagesBubbleImageFactory().incomingMessagesBubbleImage(with: #colorLiteral(red: 0.9098039216, green: 0.9058823529, blue: 0.8235294118, alpha: 1))
    }
    
    // MARK: - JSQMessages Actions
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        let itemRef = messageRef.childByAutoId()
        
        let messageItem = ["senderId": senderId, "senderName": senderDisplayName, "text": text] as [String: String]
        
        itemRef.setValue(messageItem)
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        finishSendingMessage()
        
        isTyping = false
    }
    
    override func textViewDidChange(_ textView: UITextView) {
        super.textViewDidChange(textView)
        
        isTyping = textView.text != ""
    }
    
    // MARK: - Helpers
    
    private func addMessage(withId id: String, name: String, text: String) {
        if let message = JSQMessage(senderId: id, displayName: name, text: text) {
            messages.append(message)
        }
    }
    
    private func observeMessages() {
        messageQueryRef = messageRef.queryLimited(toLast: 25)
        
        messageQueryRef.observe(.childAdded, with: { snapshot in
            if let messageDict = snapshot.value as? [String: String] {
                if let id = messageDict["senderId"], let name = messageDict["senderName"], let text = messageDict["text"] {
                    self.addMessage(withId: id, name: name, text: text)
                    self.finishReceivingMessage()
                }
            }
        })
        
    }
    
    private func observeTyping() {
        userTypingRef.onDisconnectRemoveValue()
        
        otherUserTypingQueryRef.observe(.value, with: { snapshot in
            if let isTyping = snapshot.value as? Bool {
                self.showTypingIndicator = isTyping
                self.scrollToBottom(animated: true)
            }
        })
    }
    
}
