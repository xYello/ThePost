//
//  WalkthroughViewController.swift
//  ThePost
//
//  Created by Andrew Robinson on 12/24/16.
//  Copyright © 2016 XYello, Inc. All rights reserved.
//

import UIKit
import OneSignal

class WalkthroughViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var circleView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var skipButton: UIButton!
    
    var indexPath:IndexPath?
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
    }
    
    
    override func viewWillLayoutSubviews() {
        let circlePath = CAShapeLayer()
        circlePath.path = UIBezierPath(roundedRect: circleView.bounds, byRoundingCorners: [.bottomLeft, .bottomRight], cornerRadii: CGSize(width: circleView.bounds.width / 2, height: circleView.bounds.height / 2)).cgPath
        
        circleView.layer.mask = circlePath
    }
    
    // MARK: - Actions
    
    @IBAction func skipButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "appServicesRequestSegue", sender: self)
    }
    
    // MARK: - CollectionView datasource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "walkthroughCell", for: indexPath) as! WalkthroughCollectionViewCell
        self.indexPath = indexPath
        
        if indexPath.row == 0 {
            cell.titleLabel.text = "Buy/Sell/Trade"
            cell.messageLabel.text = "Yes, we’re making it easy to buy, sell and swap your Jeep parts."
            cell.bottomImageView.image = #imageLiteral(resourceName: "PriceTag ")
            cell.nextButton.addTarget(self, action: #selector(nextButtonPressed), for: .touchUpInside)
            
        } else if indexPath.row == 1 {
            cell.titleLabel.text = "Message"
            cell.messageLabel.text = "Once you’ve found the perfect part you can message the seller and ask to buy."
            cell.bottomImageView.image = #imageLiteral(resourceName: "LikeConversation ")
            cell.nextButton.addTarget(self, action: #selector(nextButtonPressed), for: .touchUpInside)
            
        } else if indexPath.row == 2 {
            cell.titleLabel.text = "Rate & Review"
            cell.nextButton.setTitle("Finish", for: .normal)
            cell.messageLabel.text = "Rating the seller/buyer is the best way to keep our community growing."
            cell.bottomImageView.image = #imageLiteral(resourceName: "FavoriteProfile")
            cell.nextButton.addTarget(self, action: #selector(finishedButtonPressed), for: .touchUpInside)
        }
        
        return cell
    }
    
    // MARK: - CollectionView delegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if Int(collectionView.contentOffset.x / collectionView.frame.width) == 2 {
            skipButton.isHidden = true
        } else {
            skipButton.isHidden = false
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    // MARK: - Actions
    
    @objc func nextButtonPressed() {
        
        //get cell size
        let cellSize = CGSize(width: self.view.frame.width, height: self.view.frame.height)
        
        //get current content Offset of the Collection view
        let contentOffset = collectionView.contentOffset
        
        //scroll to next cell
        collectionView.scrollRectToVisible(CGRect(x: contentOffset.x + cellSize.width, y: contentOffset.y, width: cellSize.width, height: cellSize.height),animated: true)
        
        
    }
    
    @objc func finishedButtonPressed() {
        if OneSignal.getPermissionSubscriptionState().permissionStatus.status != .notDetermined {
            performSegue(withIdentifier: "unwindToPresenting", sender: self)
        } else {
            performSegue(withIdentifier: "appServicesRequestSegue", sender: self)
        }
    }

}
