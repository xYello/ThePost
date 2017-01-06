//
//  ChatConversationViewController.swift
//  ThePost
//
//  Created by Andrew Robinson on 1/6/17.
//  Copyright © 2017 The Post. All rights reserved.
//

import UIKit

class ChatConversationViewController: UIViewController, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
    }
    
    // MARK: - TableView datasource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "conversationCell", for: indexPath) as! ConversationTableViewCell
        
        cell.profileImageView.image = #imageLiteral(resourceName: "MeanJeep")
        
        cell.personNameLabel.text = "Grayson Pierce"
        
        cell.recentMessageLabel.text = "haha, I beat you Jason! let’s see who wins this time ;)"
        
        cell.timeLabel.text = "Now"
        
        return cell
    }
    
}
