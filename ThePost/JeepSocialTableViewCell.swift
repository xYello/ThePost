//
//  JeepSocialTableViewCell.swift
//  ThePost
//
//  Created by Tyler Flowers on 2/14/17.
//  Copyright © 2017 The Post. All rights reserved.
//

import UIKit
import FirebaseStorageUI

class JeepSocialTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var postImageView: UIImageView!
    
    @IBOutlet weak var postNameLabel: UILabel!
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    
    var postKey: String?
    
    // MARK: - View lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profileImageView.clipsToBounds = true
        profileImageView.roundCorners()
    }
    
    // MARK: - Actions

    @IBAction func likeButtonPressed(_ sender: Any) {
 
    }
    
    // MARK: - Firebase
    
    func grabPostImage(forKey key: String, withURL urlString: String) {
        let url = URL(string: urlString)
        
        // Load from cache or download.
        SDWebImageManager.shared().diskImageExists(for: url, completion: { exists in
            if exists {
                SDWebImageManager.shared().loadImage(with: url, options: .scaleDownLargeImages, progress: nil, completed: { image, data, error, cachType, done, url in
                    if key == self.postKey {
                        if let i = image {
                            DispatchQueue.main.async {
                                self.postImageView.image = i
                            }
                        }
                    }
                })
            } else {
                SDWebImageDownloader.shared().downloadImage(with: url, options: .scaleDownLargeImages, progress: nil, completed: { image, error, cacheType, done in
                    if key == self.postKey {
                        if let i = image {
                            DispatchQueue.main.async {
                                self.postImageView.image = i
                            }
                        }
                    }
                })
            }
        })
        
    }
    
}
