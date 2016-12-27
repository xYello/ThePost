//
//  WalkthroughViewController.swift
//  ThePost
//
//  Created by Andrew Robinson on 12/24/16.
//  Copyright © 2016 The Post. All rights reserved.
//

import UIKit

class WalkthroughViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    // MARK: - Actions
    
    @IBAction func skipButtonPressed(_ sender: UIButton) {
        // TODO: Skip...
    }
    
    // MARK: - CollectionView datasource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "walkthroughCell", for: indexPath) as! WalkthroughCollectionViewCell
        cell.stepCountLabel.text = "\(indexPath.row + 1)"
        
        if indexPath.row == 0 {
            cell.titleLabel.text = "Buy/Sell/Trade"
            cell.messageLabel.text = "Yes, we’re making it easy to buy, sell and swap your Jeep parts."
            cell.bottomImageView.image = UIImage(named: "MoneyPower")
            cell.imageToBottomConstraint.constant = -8
            
        } else if indexPath.row == 1 {
            cell.titleLabel.text = "Message"
            cell.messageLabel.text = "Once you’ve found the perfect part you can message the seller and ask to buy."
            cell.bottomImageView.image = UIImage(named: "LikeConversation")
            
            cell.bottomImageView.removeConstraint(cell.imageAspectRatioConstraint)
            cell.imageAspectRatioConstraint = NSLayoutConstraint(item: cell.bottomImageView,
                                                                 attribute: .width,
                                                                 relatedBy: .equal,
                                                                 toItem: cell.bottomImageView,
                                                                 attribute: .height,
                                                                 multiplier: 214.0/223.0,
                                                                 constant: 0.0)
            cell.addConstraint(cell.imageAspectRatioConstraint)
            
        } else if indexPath.row == 2 {
            cell.titleLabel.text = "Rate & Review"
            cell.messageLabel.text = "Rating the seller/buyer is the best way to keep our community growing."
            cell.bottomImageView.image = UIImage(named: "FavoriteProfile")
            
            cell.bottomImageView.removeConstraint(cell.imageAspectRatioConstraint)
            cell.imageAspectRatioConstraint = NSLayoutConstraint(item: cell.bottomImageView,
                                                                 attribute: .width,
                                                                 relatedBy: .equal,
                                                                 toItem: cell.bottomImageView,
                                                                 attribute: .height,
                                                                 multiplier: 180.0/174.0,
                                                                 constant: 0.0)
            cell.addConstraint(cell.imageAspectRatioConstraint)
        }
        
        return cell
    }
    
    // MARK: CollectionView delegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        pageControl.currentPage = Int(collectionView.contentOffset.x / collectionView.frame.width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }

}
