//
//  ActivityViewController.swift
//  ThePost
//
//  Created by Andrew Robinson on 1/25/17.
//  Copyright © 2017 The Post. All rights reserved.
//

import UIKit

class ActivityViewController: UIViewController, UITableViewDataSource {
    
    private enum ActivityType {
        case review
        case sold
        case like
    }

    @IBOutlet weak var tableView: UITableView!
    
    private var activityData: [ActivityType] = []
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityData = [.review, .sold, .like]
        
        tableView.dataSource = self
    }
    
    // MARK: - TableView datasource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activityData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        
        let activityType = activityData[indexPath.row]
        
        if activityType == .review {
            let reviewCell = tableView.dequeueReusableCell(withIdentifier: "reviewCell", for: indexPath) as! NewReviewActivityTableViewCell
            
            reviewCell.profileImageView.image = #imageLiteral(resourceName: "DefaultProfilePicture")
            
            cell = reviewCell
        } else if activityType == .sold {
            let soldCell = tableView.dequeueReusableCell(withIdentifier: "soldCell", for: indexPath) as! SoldActivityTableViewCell
            
            soldCell.profileImageView.image = #imageLiteral(resourceName: "DefaultProfilePicture")
            
            cell = soldCell
        } else if activityType == .like {
            let likeCell = tableView.dequeueReusableCell(withIdentifier: "likeCell", for: indexPath) as! LikedProductActivityTableViewCell
            
            likeCell.profileImageView.image = #imageLiteral(resourceName: "DefaultProfilePicture")
            
            likeCell.nameLabel.text = "CALEB ANDREWS"
            
            cell = likeCell
        }
        
        return cell
    }

}
