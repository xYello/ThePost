//
//  ActivityViewController.swift
//  ThePost
//
//  Created by Andrew Robinson on 1/25/17.
//  Copyright © 2017 The Post. All rights reserved.
//

import UIKit

class ActivityViewController: UIViewController, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
        
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
    }
    
    // MARK: - TableView datasource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let socialCell = tableView.dequeueReusableCell(withIdentifier: "socialCell", for: indexPath) as! JeepSocialTableViewCell
    
        socialCell.likeCountLabel.text = "125,857,323 likes"
        socialCell.postNameLabel.text = "Ethan Andrews"
        socialCell.profileImageView.image = #imageLiteral(resourceName: "ETHANPROFILESAMPLE")
        socialCell.timeLabel.text = "5 hours ago"
        socialCell.postImageView.image = #imageLiteral(resourceName: "jeepImage")
        
        return socialCell
    }

}
