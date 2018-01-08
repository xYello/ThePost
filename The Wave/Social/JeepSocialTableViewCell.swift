//
//  JeepSocialTableViewCell.swift
//  ThePost
//
//  Created by Tyler Flowers on 2/14/17.
//  Copyright © 2017 XYello, Inc. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorageUI

protocol SocialTableViewCellDelegate {
    func profileButtonTapped(withProfileId id: String)
}

class JeepSocialTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var badgeImageView: UIImageView!

    @IBOutlet weak var postNameLabel: UILabel!
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    
    var likesRef: DatabaseReference!
    
    var postKey: String? {
        didSet {
            if let key = postKey {
                checkForCurrentUserLike(forKey: key)
                listenForLikeCount(forKey: key)
            }
        }
    }
    var ownerKey: String?

    var delegate: SocialTableViewCellDelegate?
    
    // MARK: - View lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()

        selectionStyle = .none
        
        profileImageView.clipsToBounds = true
        profileImageView.roundCorners()
        
        likeButton.layer.shadowRadius = 2.0
        likeButton.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        likeButton.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor
        likeButton.layer.shadowOpacity = 1.0
    }
    
    // MARK: - Actions

    @IBAction func likeButtonPressed(_ sender: Any) {
        incrementLikes()
    }

    @IBAction func profileButtonPressed(_ sender: UIButton) {
        if let key = ownerKey {
            delegate?.profileButtonTapped(withProfileId: key)
        }
    }

    // MARK: - Image load cancel

    func cancelImageLoad() {
        self.profileImageView.sd_cancelCurrentImageLoad()
        self.postImageView.sd_cancelCurrentImageLoad()
    }

    // MARK: - Firebase
    
    func grabPostImage(withURL urlString: String) {
        let url = URL(string: urlString)
        self.postImageView.sd_setImage(with: url)
    }
    
    func grabProfile(forKey key: String) {
        let ref = Database.database().reference().child("users").child(key)
        ref.observeSingleEvent(of: .value, with: { snapshot in
            if let userDict = snapshot.value as? [String: AnyObject] {
                if let imageUrl = userDict["profileImage"] as? String {
                    if let url = URL(string: imageUrl) {
                        self.profileImageView.image = #imageLiteral(resourceName: "DefaultProfilePicture")
                        self.profileImageView.sd_setImage(with: url)
                    }
                } else {
                    self.profileImageView.image = #imageLiteral(resourceName: "DefaultProfilePicture")
                }
                
                if let name = userDict["fullName"] as? String {
                    self.postNameLabel.text = name
                }

                if let badgeString = userDict["badge"] as? String {
                    if let badge = BadgeStatus(rawValue: badgeString) {
                        self.badgeImageView.isHidden = false
                        self.badgeImageView.image = badge.getImage()
                    } else {
                        self.badgeImageView.isHidden = true
                    }
                } else {
                    self.badgeImageView.isHidden = true
                }
            }
        })
    }
    
    private func incrementLikes() {
        if let key = postKey {
            let ref = Database.database().reference().child("social-posts").child(key)
            
            ref.runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
                if var post = currentData.value as? [String : AnyObject], let uid = Auth.auth().currentUser?.uid {
                    var likes: Dictionary<String, Bool> = post["likes"] as? [String : Bool] ?? [:]
                    var likeCount = post["likeCount"] as? Int ?? 0
                    
                    if let _ = likes[uid] {
                        likeCount -= 1
                        likes.removeValue(forKey: uid)
                        
                        DispatchQueue.main.async {
                            self.likeButton.setImage(#imageLiteral(resourceName: "SocialLikeIcon"), for: .normal)
                        }
                    } else {
                        likeCount += 1
                        likes[uid] = true
                        
                        PushNotification.sender.pushLikedSocialPost(withRecipientId: post["owner"] as! String)
                        
                        DispatchQueue.main.async {
                            self.likeButton.setImage(#imageLiteral(resourceName: "SocialLikeOnIcon"), for: .normal)
                        }
                    }
                    post["likeCount"] = likeCount as AnyObject?
                    post["likes"] = likes as AnyObject?
                    
                    currentData.value = post
                    
                    return TransactionResult.success(withValue: currentData)
                }
                return TransactionResult.success(withValue: currentData)
            }) { (error, committed, snapshot) in
                if let error = error {
                    print(error.localizedDescription)
                    SentryManager.shared.sendEvent(withError: error)
                }
            }
            
        }
        
    }
    
    private func checkForCurrentUserLike(forKey key: String) {
        if let uid = Auth.auth().currentUser?.uid {
            let likesRef = Database.database().reference().child("social-posts").child(key)
            likesRef.observeSingleEvent(of: .value, with: { snapshot in
                var isLiked = false
                if let post = snapshot.value as? [String: AnyObject] {
                    if let likes = post["likes"] as? [String: Bool] {
                        if let _ = likes[uid] {
                            isLiked = true
                        }
                    }
                    
                }
                
                if isLiked {
                    DispatchQueue.main.async {
                        self.likeButton.setImage(#imageLiteral(resourceName: "SocialLikeOnIcon"), for: .normal)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.likeButton.setImage(#imageLiteral(resourceName: "SocialLikeIcon"), for: .normal)
                    }
                }
                
            })
        }
    }
    
    private func listenForLikeCount(forKey key: String) {
        likesRef = Database.database().reference().child("social-posts").child(key).child("likeCount")
        likesRef.observe(.value, with: { snapshot in
            if let count = snapshot.value as? Int {
                DispatchQueue.main.async {
                    if count == 1 {
                        self.likeCountLabel.text = "\(count) like"
                    } else {
                        self.likeCountLabel.text = "\(count) likes"
                    }
                }
            }
        })
    }
    
}
