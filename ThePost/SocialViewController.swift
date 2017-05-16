//
//  SocialViewController.swift
//  ThePost
//
//  Created by Andrew Robinson on 1/25/17.
//  Copyright © 2017 The Post. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorageUI
import DateToolsSwift

class SocialViewController: UIViewController, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    private var ref: FIRDatabaseReference!
    private var socialRef: FIRDatabaseReference?
    private var socialPosts: [SocialPost]!
        
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        ref = FIRDatabase.database().reference()
        socialPosts = []
        
        if socialRef == nil {
            socialRef = ref.child("social-posts")
            
            let query = socialRef!.queryOrdered(byChild: "datePosted").queryLimited(toLast: 200)
            query.observe(.childAdded, with: { snapshot in
                if let socialDict = snapshot.value as? [String: AnyObject] {
                    var socialPost: SocialPost!
                    
                    let date = Date.init(timeIntervalSince1970: Double(socialDict["datePosted"] as! NSNumber) / 1000)
                    
                    socialPost = SocialPost.init(withUsername: socialDict["name"] as! String, imageUrl: socialDict["image"] as! String, likeCount: 0, userid: socialDict["userid"] as! String, date:date)
                    socialPost.uid = snapshot.key
                    
                    self.socialPosts.insert(socialPost, at: 0)
                    self.tableView.reloadData()
                }
            })
            
            socialRef!.observe(.childRemoved, with: { snapshot in
                if let socialDict = snapshot.value as? [String: AnyObject] {
                    
                    let date = Date(timeIntervalSince1970: Double(socialDict["datePosted"] as! NSNumber) / 1000)
                    let post = SocialPost(withUsername: socialDict["name"] as! String, imageUrl: socialDict["image"] as! String, likeCount: 0, userid: socialDict["userid"] as! String, date:date)
                    post.uid = snapshot.key
                    let index = self.indexOfPost(post)
                    
                    if index != -1 {
                        self.socialPosts.remove(at: index)
                        self.tableView.reloadData()
                    }
                    
                }
            })
        }

    }
    
    
    // MARK: - TableView datasource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return socialPosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let socialCell = tableView.dequeueReusableCell(withIdentifier: "socialCell", for: indexPath) as! JeepSocialTableViewCell
        
        socialCell.likeCountLabel.text = socialPosts[indexPath.row].likeCount.description
        socialCell.postNameLabel.text = socialPosts[indexPath.row].username
        socialCell.timeLabel.text = socialPosts[indexPath.row].datePosted.timeAgoSinceNow
        
        let imageUrl = URL(string: socialPosts[indexPath.row].imageUrl)
        
        // Load from cache or download.
        SDWebImageManager.shared().diskImageExists(for: imageUrl, completion: { exists in
            if exists {
                SDWebImageManager.shared().loadImage(with: imageUrl, options: .scaleDownLargeImages, progress: nil, completed: { image, data, error, cachType, done, url in
                    if let i = image {
                        DispatchQueue.main.async {
                            socialCell.postImageView.image = i
                        }
                    }
                })
            } else {
                SDWebImageDownloader.shared().downloadImage(with: imageUrl, options: .scaleDownLargeImages, progress: nil, completed: { image, error, cacheType, done in
                    if let i = image {
                        DispatchQueue.main.async {
                            socialCell.postImageView.image = i
                        }
                    }
                })
            }
        })
        
        let userID = socialPosts[indexPath.row].userid
        let ref = FIRDatabase.database().reference().child("users").child(userID!).child("profileImage")
        ref.observeSingleEvent(of: .value, with: { snapshot in
            if let urlString = snapshot.value as? String {
                let profileImageUrl = URL(string: urlString)
                
                // Load from cache or download.
                SDWebImageManager.shared().diskImageExists(for: imageUrl, completion: { exists in
                    if exists {
                        SDWebImageManager.shared().loadImage(with: profileImageUrl, options: .scaleDownLargeImages, progress: nil, completed: { image, data, error, cachType, done, url in
                            if let i = image {
                                DispatchQueue.main.async {
                                    socialCell.profileImageView.image = i
                                }
                            }
                        })
                    } else {
                        SDWebImageDownloader.shared().downloadImage(with: profileImageUrl, options: .scaleDownLargeImages, progress: nil, completed: { image, error, cacheType, done in
                            if let i = image {
                                DispatchQueue.main.async {
                                    socialCell.profileImageView.image = i
                                }
                            }
                        })
                    }
                })
            } else {
                socialCell.profileImageView.image = #imageLiteral(resourceName: "DefaultProfilePicture")
            }
        })
        
        return socialCell
    }
    
    // MARK: - Helpers
    
    private func indexOfPost(_ snapshot: SocialPost) -> Int {
        var index = 0
        for post in socialPosts {
            
            if snapshot.uid == post.uid {
                return index
            }
            index += 1
        }
        return -1
    }

}
