//
//  ChatConversationViewController.swift
//  ThePost
//
//  Created by Andrew Robinson on 1/6/17.
//  Copyright © 2017 The Post. All rights reserved.
//

import UIKit

class ChatConversationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let tabBar = tabBarController as? SlidingSelectionTabBarController {
            tabBar.showShadow()
        }
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
    
    // MARK: - TableView delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let tabBar = tabBarController as? SlidingSelectionTabBarController {
            tabBar.hideShadow()
        }
        
        // SE
        // Y31TlLgriYZS6pMqb9Z4MBq141I2
        // Cantalope Robinson
        // -Ka47KEo6QTXclpeenox <- Is this user's product
        
        // Phone
        // kKLTNG4QEvToQeFNFVJpQFEM22D2
        // Andrew Robinson
        // -K_uqmLSqvxav-ykvDxg
        let test = Conversation(id: "someChatID", otherPersonId: "kKLTNG4QEvToQeFNFVJpQFEM22D2", otherPersonName: "Andrew Robinson", productID: "-Ka47KEo6QTXclpeenox")
        performSegue(withIdentifier: "chatViewController", sender: test)
    }
    
    // MARK: - Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if let conversation = sender as? Conversation {
            if let vc = segue.destination as? ChatContainerViewController {
                navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
                navigationController!.navigationBar.tintColor = #colorLiteral(red: 0.7647058824, green: 0.768627451, blue: 0.7137254902, alpha: 1)
                
                vc.conversationToPass = conversation
                vc.hidesBottomBarWhenPushed = true
            }
        }
    }
    
}
