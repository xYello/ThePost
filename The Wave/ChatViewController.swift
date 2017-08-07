//
//  ChatViewController.swift
//  ThePost
//
//  Created by Andrew Robinson on 1/8/17.
//  Copyright © 2017 XYello, Inc. All rights reserved.
//

import UIKit
import Firebase
import JSQMessagesViewController

class ChatViewController: JSQMessagesViewController, UIDynamicAnimatorDelegate {
    
    var conversation: Conversation! {
        didSet {
            title = conversation.otherPersonName
        }
    }
    
    var greenButton: UIButton!
    var outlineButton: UIButton!
    
    var soldContainer: UIView!
    var soldImageView: UIImageView!
    var writeAReviewButton: UIButton!
    
    var soldImageViewMidConstraint: NSLayoutConstraint!
    
    private var conversationRef: FIRDatabaseReference? {
        didSet {
            messageRef = conversationRef!.child("messages")
            userTypingRef = conversationRef!.child("typingIndicator").child(senderId)
            otherUserTypingQueryRef = conversationRef!.child("typingIndicator").child(conversation.otherPersonId)
            
            observeMessages()
        }
    }
    private var messageRef: FIRDatabaseReference!
    private var messageQueryRef: FIRDatabaseQuery?
    private var userTypingRef: FIRDatabaseReference?
    private var otherUserTypingQueryRef: FIRDatabaseQuery?
    
    private var productIsSoldRef: FIRDatabaseReference!
    
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
            if conversationRef != nil {
                userTypingRef!.setValue(newValue)
            }
        }
    }
    
    private var animator: UIDynamicAnimator!
    
    private var isProductOwner = false
    private var isProductSold = false {
        didSet {
            if isProductSold {
                
                let ogCenter = soldImageView.center
                let containerOgFrame = soldContainer.frame
                soldImageViewMidConstraint.constant = -soldContainer.frame.width
                soldContainer.frame = CGRect(x: soldContainer.frame.origin.x,
                                             y: soldContainer.frame.origin.y,
                                             width: 0,
                                             height: soldContainer.frame.height)
                
                UIView.animate(withDuration: 0.5, animations: {
                    self.greenButton.alpha = 0.0
                    self.outlineButton.alpha = 0.0
                    
                    self.soldContainer.alpha = 1.0
                    self.soldImageView.alpha = 1.0
                    
                    self.soldContainer.frame = containerOgFrame
                    self.view.layoutIfNeeded()
                }, completion: { done in
                    let snap = UISnapBehavior(item: self.soldImageView, snapTo: ogCenter)
                    snap.damping = 1.0
                    self.animator.addBehavior(snap)
                })
                
            } else {
                let originalContainerFrame = soldContainer.frame
                UIView.animate(withDuration: 0.25, animations: {
                    self.greenButton.alpha = 1.0
                    self.outlineButton.alpha = 1.0
                    self.soldContainer.frame = CGRect(x: self.soldContainer.frame.origin.x,
                                                      y: self.soldContainer.frame.origin.y - self.soldContainer.frame.height,
                                                      width: self.soldContainer.frame.width,
                                                      height: self.soldContainer.frame.height)
                }, completion: { done in
                    self.soldContainer.alpha = 0.0
                    self.soldContainer.frame = originalContainerFrame
                })
            }
        }
    }
    
    private var inputBarDefaultHeight: CGFloat?
    
    private var product: Product!
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        animator = UIDynamicAnimator()
        animator.delegate = self
        
        senderId = FIRAuth.auth()!.currentUser!.uid
        senderDisplayName = conversation.otherPersonName
        
        if conversation.id != "" {
            conversationRef = FIRDatabase.database().reference().child("chats").child(conversation.id)
        }
        
        productIsSoldRef = FIRDatabase.database().reference().child("products").child(conversation.productID).child("isSold")
        getProductDetails()
        
        collectionView.backgroundColor = #colorLiteral(red: 0.1870684326, green: 0.2210902572, blue: 0.2803535461, alpha: 1)
        
        inputToolbar.contentView.leftBarButtonItem = nil
        
        if let message = conversation.firstMessage, message != "" {
            inputToolbar.contentView.textView.text = message
            inputToolbar.toggleSendButtonEnabled()
            
            inputBarDefaultHeight = inputToolbar.preferredDefaultHeight
            inputToolbar.preferredDefaultHeight = 120.0
        }
        
        outgoingBubble = setupOutgoingBubble()
        incomingBubble = setupIncomingBubble()
        
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = .zero
        collectionView!.collectionViewLayout.incomingAvatarViewSize = .zero
        
        greenButton.roundCorners(radius: 8.0)
        greenButton.alpha = 0.0
        
        outlineButton.roundCorners(radius: 8.0)
        outlineButton.alpha = 0.0
        outlineButton.layer.borderColor = outlineButton.titleLabel!.textColor.cgColor
        outlineButton.layer.borderWidth = 1.0
        outlineButton.isEnabled = false
        
        soldContainer.alpha = 0.0
        soldImageView.alpha = 0.0
        
        writeAReviewButton.alpha = 0.0
        writeAReviewButton.roundCorners(radius: 8.0)
        writeAReviewButton.layer.borderColor = outlineButton.titleLabel!.textColor.cgColor
        writeAReviewButton.layer.borderWidth = 1.0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        collectionView.collectionViewLayout.springinessEnabled = true
        
        if conversation.id != "" {
            observeTyping()
        }
    }
    
    deinit {
        if let messageQuery = messageQueryRef {
            messageQuery.removeAllObservers()
        }
        
        if let typingQuery = otherUserTypingQueryRef {
            typingQuery.removeAllObservers()
        }
        
        productIsSoldRef.removeAllObservers()
    }
    
    // MARK: - Animator delegate
    
    func dynamicAnimatorDidPause(_ animator: UIDynamicAnimator) {
        if !isProductOwner {
            writeAReviewButton.addTarget(self, action: #selector(writeAReviewButtonPressed), for: .touchUpInside)
            
            UIView.animate(withDuration: 0.25, animations: {
                self.soldImageView.alpha = 0.0
                self.writeAReviewButton.alpha = 1.0
            })
        }
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
        
        if conversationRef == nil {
            conversationRef = FIRDatabase.database().reference().child("chats").childByAutoId()
            
            let participants = [conversation.otherPersonId: true,
                                senderId: true]
            conversationRef!.child("participants").updateChildValues(participants)
            
            let productID = ["productID": conversation.productID] as [String: String]
            conversationRef!.updateChildValues(productID)
            
            let userChatsRef = FIRDatabase.database().reference().child("user-chats")
            let childUpdate = [conversationRef!.key: true]
            
            userChatsRef.child(conversation.otherPersonId).updateChildValues(childUpdate)
            userChatsRef.child(senderId).updateChildValues(childUpdate)
            
            if let height = inputBarDefaultHeight {
                inputToolbar.preferredDefaultHeight = height
            }
        }
        
        let itemRef = messageRef.childByAutoId()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yy HH:mm:ss"
        formatter.timeZone = TimeZone(identifier: "America/New_York")
        let now = formatter.string(from: Date())
        
        let messageItem = ["senderId": senderId, "text": text, "time": now] as [String: String]
        
        PushNotification.sender.pushChat(withMessage: text, withRecipientId: conversation.otherPersonId)
        itemRef.setValue(messageItem)
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        finishSendingMessage()
        
        isTyping = false
    }
    
    override func textViewDidChange(_ textView: UITextView) {
        super.textViewDidChange(textView)
        
        isTyping = textView.text != ""
    }
    
    // MARK: - Other Actions
    
    @objc private func greenButtonPressed() {
        if greenButton.currentTitle == "Mark Sold" {
            let productRef = FIRDatabase.database().reference()
            let childUpdates: [String: Any] = ["products/\(conversation.productID!)/isSold": true,
                                               "products/\(conversation.productID!)/soldModel": "SOLD" + product.jeepModel.name]
            
            productRef.updateChildValues(childUpdates)
        } else if greenButton.currentTitle == "View Profile" {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let vc = storyboard.instantiateViewController(withIdentifier: "profileModalViewController") as? ProfileModalViewController {
                vc.modalPresentationStyle = .overCurrentContext
                vc.idToPass = conversation.otherPersonId
                
                PresentationCenter.manager.present(viewController: vc, sender: self)
            }
        }
    }
    
    @objc private func outlinedButtonPressed() {
        if outlineButton.currentTitle == "View Product" {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let vc = storyboard.instantiateViewController(withIdentifier: "viewProductInfo") as? ProductViewerViewController {
                vc.modalPresentationStyle = .overCurrentContext
                vc.product = product
                vc.chatOpen = true
                
                PresentationCenter.manager.present(viewController: vc, sender: self)
            }
        }
    }
    
    @objc private func writeAReviewButtonPressed() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "createAReviewController") as? CreateReviewViewController {
            vc.modalPresentationStyle = .overCurrentContext
            vc.product = product
            vc.userId = conversation.otherPersonId
            
            present(vc, animated: false, completion: nil)
        }
    }
    
    // MARK: - Helpers
    
    private func addMessage(withId id: String, name: String, text: String) {
        if let message = JSQMessage(senderId: id, displayName: name, text: text) {
            messages.append(message)
        }
    }
    
    private func observeMessages() {
        messageQueryRef = messageRef.queryLimited(toLast: 200)
        
        messageQueryRef!.observe(.childAdded, with: { snapshot in
            if let messageDict = snapshot.value as? [String: String] {
                if let id = messageDict["senderId"], let text = messageDict["text"] {
                    self.addMessage(withId: id, name: "", text: text)
                    self.finishReceivingMessage()
                }
            }
        })
        
    }
    
    private func observeTyping() {
        userTypingRef!.onDisconnectRemoveValue()
        
        otherUserTypingQueryRef!.observe(.value, with: { snapshot in
            if let isTyping = snapshot.value as? Bool {
                self.showTypingIndicator = isTyping
                self.scrollToBottom(animated: true)
            }
        })
    }
    
    private func getProductDetails() {
        let productRef = FIRDatabase.database().reference().child("products").child(conversation.productID)
        productRef.observeSingleEvent(of: .value, with: { snapshot in
            if let productDict = snapshot.value as? [String: Any] {
                
                let jeepModel = JeepModel.enumFromString(string: productDict["jeepModel"] as! String)
                if let condition = Condition.enumFromString(string: productDict["condition"] as! String) {
                    let product = Product(withName: productDict["name"] as! String,
                                          model: jeepModel,
                                          price: productDict["price"] as! Float,
                                          condition: condition)
                    
                    product.uid = snapshot.key
                    product.ownerId = productDict["owner"] as! String

                    product.postedDate = Date(timeIntervalSince1970: productDict["datePosted"] as! TimeInterval / 1000)

                    if let likeCount = productDict["likeCount"] as? Int {
                        product.likeCount = likeCount
                    }

                    product.originalBox = productDict["originalBox"] as! Bool
                    if let year = productDict["releaseYear"] as? Int {
                        product.releaseYear = year
                    }
                    if let desc = productDict["detailedDescription"] as? String {
                        product.detailedDescription = desc
                    }

                    product.willingToShip = productDict["willingToShip"] as! Bool
                    product.acceptsPayPal = productDict["acceptsPayPal"] as! Bool
                    product.acceptsCash = productDict["acceptsCash"] as! Bool

                    if let isSold = productDict["isSold"] as? Bool {
                        product.isSold = isSold
                    }

                    var greenText = ""
                    var outlineText = ""
                    if product.ownerId == self.senderId {
                        greenText = "Mark Sold"
                        outlineText = "View Product"
                        self.isProductOwner = true
                    } else {
                        greenText = "View Profile"
                        outlineText = "View Product"
                    }

                    if let isSold = productDict["isSold"] as? Bool {
                        if isSold {
                            self.isProductSold = true
                        } else {
                            self.isProductSold = false
                        }
                    } else {
                        self.isProductSold = false
                    }

                    if !self.isProductSold {
                        self.setupIsSoldObserver()
                    }

                    self.greenButton.addTarget(self, action: #selector(self.greenButtonPressed), for: .touchUpInside)
                    self.outlineButton.addTarget(self, action: #selector(self.outlinedButtonPressed), for: .touchUpInside)

                    self.outlineButton.isEnabled = true
                    self.product = product

                    DispatchQueue.main.async {
                        self.greenButton.setTitle(greenText, for: .normal)
                        self.outlineButton.setTitle(outlineText, for: .normal)
                    }

                }
            }
        })
    }
    
    private func setupIsSoldObserver() {
        productIsSoldRef.observe(.value, with: { snapshot in
            if let isSold = snapshot.value as? Bool {
                if isSold  {
                    self.isProductSold = true
                }
            }
        })
    }
    
}
