//
//  CategorySelectorViewController.swift
//  ThePost
//
//  Created by Andrew Robinson on 12/26/16.
//  Copyright © 2016 The Post. All rights reserved.
//

import UIKit

class CategorySelectorViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var jeepModel: Jeep!
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        
        // These ratios that are defined here are values defined in the Sketch file. Cell size / screen size
        layout.itemSize = CGSize(width: floor(view.frame.width * (335/414)), height: floor(view.frame.height * (200/736)))
        
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    // MARK: - CollectionView datasource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "categorySelectorCell", for: indexPath) as! CategorySelectorCollectionViewCell
        
        switch indexPath.row {
        case 0:
            cell.backgroundImage = UIImage(named: "Wheels&Tires")!.image(withInsets: UIEdgeInsets(top: 0, left: 70, bottom: 0, right: 70))
            cell.categoryTitle = "Wheels & Tires"
            cell.numberOfItems = 132
        case 1:
            cell.backgroundImage = UIImage(named: "Lifts&Shocks")!.image(withInsets: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10))
            cell.categoryTitle = "Lifts & Shocks"
            cell.numberOfItems = 332
        default:
            cell.backgroundImage = UIImage(named: "Bumpers")!.image(withInsets: UIEdgeInsets(top: 0, left: 25, bottom: 0, right: 25))
            cell.categoryTitle = "Bumpers"
            cell.numberOfItems = 49
        }
        
        return cell
    }
    
    // MARK: - CollectionView delegate
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? CategorySelectorCollectionViewCell {
            cell.backgroundColor = #colorLiteral(red: 0.8470588235, green: 0.337254902, blue: 0.2156862745, alpha: 1)
            cell.categoryTitleLabel.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            cell.numberOfItemsLabel.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? CategorySelectorCollectionViewCell {
            cell.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            cell.categoryTitleLabel.textColor = #colorLiteral(red: 0.1490196078, green: 0.1647058824, blue: 0.1882352941, alpha: 1)
            cell.numberOfItemsLabel.textColor = #colorLiteral(red: 0.1411764706, green: 0.1647058824, blue: 0.2117647059, alpha: 1)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? CategorySelectorCollectionViewCell {
            cell.backgroundColor = #colorLiteral(red: 0.8470588235, green: 0.337254902, blue: 0.2156862745, alpha: 1)
            cell.categoryTitleLabel.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            cell.numberOfItemsLabel.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        }
        performSegue(withIdentifier: "unwindToPostLaunchSegue", sender: self)
    }

}
