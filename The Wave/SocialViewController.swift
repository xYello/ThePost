//
//  SocialViewController.swift
//  ThePost
//
//  Created by Andrew Robinson on 1/25/17.
//  Copyright © 2017 XYello, Inc. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorageUI

class SocialViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SocialTableViewCellDelegate {

    @IBOutlet weak var noPostsView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    private var ref: DatabaseReference!
    private var socialRef: DatabaseReference?
    private var socialPosts: [SocialPost]!
        
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        ref = Database.database().reference()
        socialPosts = []
        
        if socialRef == nil {
            socialRef = ref.child("social-posts")

            let lastWeek = (Date().timeIntervalSince1970 * 1000) - 604800000 // Subtract a week in milliseconds.
            let query = socialRef!.queryOrdered(byChild: "datePosted")
                .queryStarting(atValue: lastWeek).queryLimited(toLast: 200)

            query.observe(.childAdded, with: { snapshot in
                if let socialDict = snapshot.value as? [String: AnyObject] {
                    
                    let date = Date(timeIntervalSince1970: Double(truncating: socialDict["datePosted"] as! NSNumber) / 1000)
                    var likes = socialDict["likeCount"] as? Int
                    if let _ = likes {
                    } else {
                        likes = 0
                    }

                    let post = SocialPost(withUid: snapshot.key, imageUrl: socialDict["image"] as! String, ownerId: socialDict["owner"] as! String, date: date, amountOfLikes: likes!)
                    
                    self.placeInOrder(post: post)
                    self.tableView.reloadData()
                }
            })
            
            socialRef!.observe(.childRemoved, with: { snapshot in
                if let socialDict = snapshot.value as? [String: AnyObject] {
                    
                    let date = Date(timeIntervalSince1970: Double(truncating: socialDict["datePosted"] as! NSNumber) / 1000)
                    var likes = socialDict["likeCount"] as? Int
                    if let _ = likes {
                    } else {
                        likes = 0
                    }

                    let post = SocialPost(withUid: snapshot.key, imageUrl: socialDict["image"] as! String, ownerId: socialDict["owner"] as! String, date: date, amountOfLikes: likes!)
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
        let count = socialPosts.count

        if count == 0 {
            tableView.isHidden = true
            noPostsView.isHidden = false
        } else {
            noPostsView.isHidden = true
            tableView.isHidden = false
        }

        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let socialCell = tableView.dequeueReusableCell(withIdentifier: "socialCell", for: indexPath) as! JeepSocialTableViewCell
        let post = socialPosts[indexPath.row]
        
        socialCell.postImageView.image = nil
        socialCell.profileImageView.image = nil
        
        socialCell.likeCountLabel.text = "0 likes"
        socialCell.timeLabel.text = post.relativeDate
        
        socialCell.postKey = post.uid
        socialCell.ownerKey = post.ownerId

        socialCell.delegate = self

        return socialCell
    }
    
    // MARK: - TableView delegate
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let socialCell = cell as? JeepSocialTableViewCell {
            socialCell.grabPostImage(withURL: socialPosts[indexPath.row].imageUrl)
            socialCell.grabProfile(forKey: socialPosts[indexPath.row].ownerId)
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let socialCell = cell as? JeepSocialTableViewCell {
            socialCell.cancelImageLoad()
            socialCell.likesRef.removeAllObservers()
        }
    }

    // MARK: - SocialTableViewCell delegate

    func profileButtonTapped(withProfileId id: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "profileModalViewController") as? ProfileModalViewController {
            vc.modalPresentationStyle = .overCurrentContext
            vc.idToPass = id

            PresentationCenter.manager.present(viewController: vc, sender: tabBarController!)
        }
    }
    
    // MARK: - Helpers

    private func placeInOrder(post: SocialPost) {
        if socialPosts.count == 0 {
            socialPosts.append(post)
        } else {
            // This code will sort the collection view by "most popular" some people didn't like that. Leaving it... just in case.
//            var iteratorIndex = 0
//            var indexToPlaceAt = -1
//            for oldPost in socialPosts {
//                if indexToPlaceAt == -1 {
//                    if post.likes >= oldPost.likes {
//                        indexToPlaceAt = iteratorIndex
//                    }
//                }
//
//                iteratorIndex += 1
//            }
//
//            if indexToPlaceAt == -1 {
//                indexToPlaceAt = socialPosts.count
//            }

            socialPosts.insert(post, at: 0)
        }
    }

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
