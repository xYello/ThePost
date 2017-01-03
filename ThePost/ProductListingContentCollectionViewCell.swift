//
//  ProductListingContentCollectionViewCell.swift
//  ThePost
//
//  Created by Andrew Robinson on 12/27/16.
//  Copyright © 2016 The Post. All rights reserved.
//

import UIKit
import Firebase

class ProductListingContentCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeCountLabel: UILabel!
    
    var ref: FIRDatabaseReference?
    var likesListenerRef: FIRDatabaseReference?
    var productKey: String? {
        didSet {
            if let key = productKey {
                ref = FIRDatabase.database().reference().child("products").child(key)
                likesListenerRef = ref!
                
                // Setup the observer to listen for like count changes for this product
                likesListenerRef!.observe(.childChanged, with: { snapshot in
                    if let likeCount = snapshot.value as? Int {
                        DispatchQueue.main.async {
                            self.likeCountLabel.text = "\(likeCount)"
                        }
                    }
                })
                
                // Check to see if the current user likes this product
                if let uid = FIRAuth.auth()?.currentUser?.uid {
                    var color = #colorLiteral(red: 0.2235294118, green: 0.2235294118, blue: 0.2235294118, alpha: 0.2034658138)
                    let likesRef = FIRDatabase.database().reference().child("products").child(key)
                    likesRef.observeSingleEvent(of: .value, with: { snapshot in
                        if let product = snapshot.value as? [String: AnyObject] {
                            if let likes = product["likes"] as? [String: Bool] {
                                if let _ = likes[uid] {
                                    color = #colorLiteral(red: 0.9019607843, green: 0.2980392157, blue: 0.2352941176, alpha: 1)
                                }
                            }
                            
                        }
                        
                        DispatchQueue.main.async {
                            self.likeButton.imageView!.tintColor = color
                        }
                        
                    })
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if let image = likeButton.imageView?.image {
            likeButton.setImage(image.withRenderingMode(.alwaysTemplate), for: .normal)
            likeButton.imageView!.tintColor = #colorLiteral(red: 0.2235294118, green: 0.2235294118, blue: 0.2235294118, alpha: 0.2034658138)
        }
    }
    
    // MARK: - Actions
    
    @IBAction func likedProduct(_ sender: UIButton) {
        if let ref = ref {
            
            if let imageView = likeButton.imageView {
                if imageView.tintColor == #colorLiteral(red: 0.9019607843, green: 0.2980392157, blue: 0.2352941176, alpha: 1) {
                    imageView.tintColor = #colorLiteral(red: 0.2235294118, green: 0.2235294118, blue: 0.2235294118, alpha: 0.2034658138)
                } else {
                    imageView.tintColor = #colorLiteral(red: 0.9019607843, green: 0.2980392157, blue: 0.2352941176, alpha: 1)
                }
            }
            
            incrementLikes(forRef: ref)
            ref.observeSingleEvent(of: .value, with: { snapshot in
                let value = snapshot.value as? NSDictionary
                if let uid = value?["owner"] as? String {
                    let userProductRef = FIRDatabase.database().reference().child("user-products").child(uid).child(self.productKey!)
                    self.incrementLikes(forRef: userProductRef)
                }
            })
        }
    }
    
    // MARK: - Helpers
    
    func incrementLikes(forRef ref: FIRDatabaseReference) {
        
        ref.runTransactionBlock({ (currentData: FIRMutableData) -> FIRTransactionResult in
            if var product = currentData.value as? [String : AnyObject], let uid = FIRAuth.auth()?.currentUser?.uid {
                var likes: Dictionary<String, Bool> = product["likes"] as? [String : Bool] ?? [:]
                var likeCount = product["likeCount"] as? Int ?? 0
                if let _ = likes[uid] {
                    likeCount -= 1
                    likes.removeValue(forKey: uid)
                } else {
                    likeCount += 1
                    likes[uid] = true
                }
                product["likeCount"] = likeCount as AnyObject?
                product["likes"] = likes as AnyObject?
                
                DispatchQueue.main.sync {
                    self.likeCountLabel.text = "\(likeCount)"
                }
                
                currentData.value = product
                
                return FIRTransactionResult.success(withValue: currentData)
            }
            return FIRTransactionResult.success(withValue: currentData)
        }) { (error, committed, snapshot) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
        // [END post_stars_transaction]
    }
    
}
