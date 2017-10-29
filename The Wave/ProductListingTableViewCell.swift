//
//  ProductListingTableViewCell.swift
//  ThePost
//
//  Created by Andrew Robinson on 1/7/17.
//  Copyright © 2017 XYello, Inc. All rights reserved.
//

import UIKit
import Firebase

class ProductListingTableViewCell: UITableViewCell {

    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var simplifiedDescriptionLabel: UILabel!
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var likeImageView: UIImageView!
    @IBOutlet weak var soldImageView: UIImageView!
    
    var likesListenerRef: DatabaseReference!
    
    var product: Product? {
        didSet {
            if let key = product?.uid {
                likesListenerRef = Database.database().reference().child("products").child(key)
                
                // Grab the number of likes because this may be out of sync
                likesListenerRef!.child("likeCount").observeSingleEvent(of: .value, with: { snapshot in
                    if let likeCount = snapshot.value as? Int {
                        DispatchQueue.main.async {
                            self.likeCountLabel.text = "\(likeCount)"
                            self.product!.likeCount = likeCount
                        }
                    }
                })
                
                // Grab product images
                grabProductImages(forKey: key)
                
                // Setup the observer to listen for like count changes for this product
                setupListenerForLikeCount()
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        likeImageView.image = #imageLiteral(resourceName: "LikeIcon").withRenderingMode(.alwaysTemplate)
        likeImageView.tintColor = #colorLiteral(red: 0.9529411765, green: 0.6274509804, blue: 0.09803921569, alpha: 1)
        
        soldImageView.isHidden = true
    }
    
    // MARK: - Helpers
    
    private func grabProductImages(forKey key: String) {
        let firstImageRef = Database.database().reference().child("products").child(key).child("images").child("1")
        firstImageRef.observeSingleEvent(of: .value, with: { snapshot in
            if let urlString = snapshot.value as? String {
                let url = URL(string: urlString)
                self.productImageView.sd_setImage(with: url)
            } else {
                self.productImageView.image = nil
            }
        })
    }
    
    private func setupListenerForLikeCount() {
        likesListenerRef!.observe(.childChanged, with: { snapshot in
            if snapshot.key == "likeCount" {
                if let likeCount = snapshot.value as? Int {
                    DispatchQueue.main.async {
                        self.likeCountLabel.text = "\(likeCount)"
                    }
                }
            }
        })
    }

}
