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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    // MARK: - CollectionView datasource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "walkthroughCell", for: indexPath) as! WalkthroughCollectionViewCell
        cell.stepCountLabel.text = "\(indexPath.row + 1)"
        
        if indexPath.row == 0 {
            cell.bottomImageView.image = UIImage(named: "MoneyPower")
        } else if indexPath.row == 1 {
            cell.bottomImageView.image = nil
        } else if indexPath.row == 2 {
            cell.bottomImageView.image = nil
        }
        
        return cell
    }
    
    // MARK: CollectionView delegate
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }

}
