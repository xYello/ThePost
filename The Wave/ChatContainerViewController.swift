//
//  ChatContainerViewController.swift
//  ThePost
//
//  Created by Andrew Robinson on 1/9/17.
//  Copyright © 2017 XYello, Inc. All rights reserved.
//

import UIKit

class ChatContainerViewController: UIViewController {
    
    @IBOutlet weak var greenButton: UIButton!
    @IBOutlet weak var outlineButton: UIButton!
    
    @IBOutlet weak var soldContainer: UIView!
    @IBOutlet weak var soldImageView: UIImageView!
    @IBOutlet weak var writeAReviewButton: UIButton!
    
    @IBOutlet weak var soldImageViewMidConstraint: NSLayoutConstraint!
    
    var conversationToPass: Conversation!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = conversationToPass.otherPersonName
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let name = segue.identifier {
            if name == "chat_embed" {
                if let vc = segue.destination as? ChatViewController {
                    vc.conversation = conversationToPass
                    
                    vc.greenButton = greenButton
                    vc.outlineButton = outlineButton
                    
                    vc.soldContainer = soldContainer
                    vc.soldImageView = soldImageView
                    vc.writeAReviewButton = writeAReviewButton
                    
                    vc.soldImageViewMidConstraint = soldImageViewMidConstraint
                }
            }
        }
    }

}
