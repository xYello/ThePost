//
//  ProductListingContentCollectionViewCell.swift
//  ThePost
//
//  Created by Andrew Robinson on 12/27/16.
//  Copyright © 2016 XYello, Inc. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorageUI
import OneSignal
import GeoFire

class ProductListingContentCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!

    @IBOutlet weak var imageView: UIImageView!

    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var likeButton: UIButton!
    
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var locationIcon: UIImageView!
    
    var ref: DatabaseReference?
    var productKey: String? {
        didSet {
            if let key = productKey {
                ref = Database.database().reference().child("products").child(key)
                
                // Grab product images
                grabProductImages(forKey: key)
                grabLocation(for: key)
                
                // Check to see if the current user likes this product
                checkForCurrentUserLike(forKey: key)
            }
        }
    }

    private var imageOperation: SDWebImageOperation?
    private var imageDownloadToken: SDWebImageDownloadToken?
    
    override func awakeFromNib() {
        super.awakeFromNib()

        clipsToBounds = true
        roundCorners(radius: 8.0)
        
        imageView.clipsToBounds = true

        priceLabel.textColor = .waveGreen
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if Auth.auth().currentUser == nil {
            likeButton.isHidden = true
        } else {
            likeButton.isHidden = false
        }
    }
    
    // MARK: - Actions
    
    @IBAction func likedProduct(_ sender: UIButton) {
        if let ref = ref {
            incrementLikes(forRef: ref)
        }
    }
    
    // MARK: - Helpers
    
    private func incrementLikes(forRef ref: DatabaseReference) {
        
        ref.runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
            if var product = currentData.value as? [String : AnyObject], let uid = Auth.auth().currentUser?.uid {
                var likes: Dictionary<String, Bool> = product["likes"] as? [String : Bool] ?? [:]
                var likeCount = product["likeCount"] as? Int ?? 0
                
                let userLikesRef = Database.database().reference().child("user-likes").child(uid)
                
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
                    
                    PushNotification.sender.pushLiked(withProductName: product["name"] as! String, withProductID: self.productKey!, withRecipientId: product["owner"] as! String)
                    
                    DispatchQueue.main.async {
                        self.likeButton.setImage(#imageLiteral(resourceName: "LikeIconLiked"), for: .normal)
                    }
                }
                product["likeCount"] = likeCount as AnyObject?
                product["likes"] = likes as AnyObject?
                
                currentData.value = product
                
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
    
    private func grabProductImages(forKey key: String) {
        let firstImageRef = Database.database().reference().child("products").child(key).child("images").child("1")
        firstImageRef.observeSingleEvent(of: .value, with: { snapshot in
            if let urlString = snapshot.value as? String {
                let url = URL(string: urlString)
                self.imageView.sd_setImage(with: url)
            } else {
                self.imageView.image = nil
            }
        })
    }
    
    private func checkForCurrentUserLike(forKey key: String) {
        if let uid = Auth.auth().currentUser?.uid {
            let likesRef = Database.database().reference().child("products").child(key)
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

    private func grabLocation(for key: String) {
        let ref = Database.database().reference().child("product-locations")
        let geo = GeoFire(firebaseRef: ref)
        geo?.getLocationForKey(key, withCallback: { location, error in
            if let location = location, let last = Location.manager.lastLocation {
                let distance = Int(location.distance(from: last)).toMiles()
                DispatchQueue.main.async {
                    if distance == 1 {
                        self.locationLabel.text = "\(distance) mile"
                    } else {
                        self.locationLabel.text = "\(distance) miles"
                    }
                }
            }
        })
    }

    func cancelImageLoad() {
        self.imageView.sd_cancelCurrentImageLoad()
    }
    
}
