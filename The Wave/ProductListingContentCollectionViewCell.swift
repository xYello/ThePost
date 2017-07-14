//
//  ProductListingContentCollectionViewCell.swift
//  ThePost
//
//  Created by Andrew Robinson on 12/27/16.
//  Copyright © 2016 The Post. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorageUI
import OneSignal

class ProductListingContentCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!

    @IBOutlet weak var priceContainer: UIView!
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var likeButton: UIButton!
    
    @IBOutlet weak var imageViewAspectRatioConstraint: NSLayoutConstraint!
    
    var ref: FIRDatabaseReference?
    var productKey: String? {
        didSet {
            if let key = productKey {
                ref = FIRDatabase.database().reference().child("products").child(key)
                
                // Grab product images
                grabProductImages(forKey: key)
                
                // Check to see if the current user likes this product
                checkForCurrentUserLike(forKey: key)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imageView.clipsToBounds = true
        
        likeButton.layer.shadowRadius = 2.0
        likeButton.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        likeButton.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor
        likeButton.layer.shadowOpacity = 1.0

        priceContainer.roundCorners(radius: 8.0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if FIRAuth.auth()?.currentUser == nil {
            likeButton.isHidden = true
        } else {
            likeButton.isHidden = false
        }
        
        imageView.removeConstraint(imageViewAspectRatioConstraint)
        if frame.width > frame.height {
            imageViewAspectRatioConstraint = NSLayoutConstraint(item: imageView, attribute: .height, relatedBy: .equal, toItem: imageView, attribute: .width, multiplier: 140/393, constant: 1.0)
        } else {
            imageViewAspectRatioConstraint = NSLayoutConstraint(item: imageView, attribute: .height, relatedBy: .equal, toItem: imageView, attribute: .width, multiplier: 3024/4032, constant: 1.0)
        }
        imageView.addConstraint(imageViewAspectRatioConstraint)
    }
    
    // MARK: - Actions
    
    @IBAction func likedProduct(_ sender: UIButton) {
        if let ref = ref {
            incrementLikes(forRef: ref)
        }
    }
    
    // MARK: - Helpers
    
    private func incrementLikes(forRef ref: FIRDatabaseReference) {
        
        ref.runTransactionBlock({ (currentData: FIRMutableData) -> FIRTransactionResult in
            if var product = currentData.value as? [String : AnyObject], let uid = FIRAuth.auth()?.currentUser?.uid {
                var likes: Dictionary<String, Bool> = product["likes"] as? [String : Bool] ?? [:]
                var likeCount = product["likeCount"] as? Int ?? 0
                
                let userLikesRef = FIRDatabase.database().reference().child("user-likes").child(uid)
                
                if let _ = likes[uid] {
                    likeCount -= 1
                    likes.removeValue(forKey: uid)
                    userLikesRef.child(self.productKey!).removeValue()
                    
                    DispatchQueue.main.async {
                        self.likeButton.setImage(#imageLiteral(resourceName: "LikeIconNotLiked"), for: .normal)
                    }
                } else {
                    likeCount += 1
                    likes[uid] = true
                    
                    let userLikesUpdate = [self.productKey!: true]
                    userLikesRef.updateChildValues(userLikesUpdate)
                    
                    PushNotification.sender.pushLiked(withProductName: product["name"] as! String, withRecipientId: product["owner"] as! String)
                    
                    DispatchQueue.main.async {
                        self.likeButton.setImage(#imageLiteral(resourceName: "LikeIconLiked"), for: .normal)
                    }
                }
                product["likeCount"] = likeCount as AnyObject?
                product["likes"] = likes as AnyObject?
                
                currentData.value = product
                
                return FIRTransactionResult.success(withValue: currentData)
            }
            return FIRTransactionResult.success(withValue: currentData)
        }) { (error, committed, snapshot) in
            if let error = error {
                print(error.localizedDescription)
                SentryManager.shared.sendEvent(withError: error)
            }
        }
        
    }
    
    private func grabProductImages(forKey key: String) {
        let firstImageRef = FIRDatabase.database().reference().child("products").child(key).child("images").child("1")
        firstImageRef.observeSingleEvent(of: .value, with: { snapshot in
            if let urlString = snapshot.value as? String {
                let url = URL(string: urlString)
                
                // Load from cache or download.
                SDWebImageManager.shared().diskImageExists(for: url, completion: { exists in
                    if exists {
                        SDWebImageManager.shared().loadImage(with: url, options: .scaleDownLargeImages, progress: nil, completed: { image, data, error, cachType, done, url in
                            if key == self.productKey {
                                if let i = image {
                                    DispatchQueue.main.async {
                                        self.imageView.image = i
                                    }
                                }
                            }
                        })
                    } else {
                        SDWebImageDownloader.shared().downloadImage(with: url, options: .scaleDownLargeImages, progress: nil, completed: { image, error, cacheType, done in
                            if key == self.productKey {
                                if let i = image {
                                    DispatchQueue.main.async {
                                        self.imageView.image = i
                                    }
                                }
                            }
                        })
                    }
                })
            } else {
                self.imageView.image = nil
            }
        })
    }
    
    private func checkForCurrentUserLike(forKey key: String) {
        if let uid = FIRAuth.auth()?.currentUser?.uid {
            let likesRef = FIRDatabase.database().reference().child("products").child(key)
            likesRef.observeSingleEvent(of: .value, with: { snapshot in
                var isLiked = false
                if let product = snapshot.value as? [String: AnyObject] {
                    if let likes = product["likes"] as? [String: Bool] {
                        if let _ = likes[uid] {
                            isLiked = true
                        }
                    }
                    
                }
                
                if isLiked {
                    DispatchQueue.main.async {
                        self.likeButton.setImage(#imageLiteral(resourceName: "LikeIconLiked"), for: .normal)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.likeButton.setImage(#imageLiteral(resourceName: "LikeIconNotLiked"), for: .normal)
                    }
                }
                
            })
        }
    }
    
    
}
