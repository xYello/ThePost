//
//  ProductListingViewController.swift
//  ThePost
//
//  Created by Andrew Robinson on 12/27/16.
//  Copyright © 2016 The Post. All rights reserved.
//

import UIKit

class ProductListingViewController: UIViewController, UICollectionViewDataSource {
    
    var jeepModel: Jeep!

    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: floor(view.frame.width * (190/414)), height: floor(view.frame.height * (235/736)))
        
        collectionView.dataSource = self
        
        navigationController!.navigationBar.setBackgroundImage(#imageLiteral(resourceName: "ProductListingNavbarBackground"), for: .default)
        if let start = jeepModel.startYear, let end = jeepModel.endYear, let name = jeepModel.name {
            navigationController!.navigationBar.topItem!.title = name + " \(start)-\(end)"
        }
    }
    
    // MARK: - CollectionView datasource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "plpContentCell", for: indexPath) as! ProductListingContentCollectionViewCell
        
        cell.favoriteCountLabel.text = "4"
        cell.descriptionLabel.text = "Used - JK - Black"
        
        if indexPath.row != 0 {
            cell.priceLabel.text = "$00,000"
            cell.imageView.image = #imageLiteral(resourceName: "ProductSample2")
            if let _ = jeepModel.name {
                cell.nameLabel.text = "Jeep Wrangler Jk soft top parts 2 door OEM mopar 4 door"
            }
        } else {
            cell.priceLabel.text = "$00"
            cell.imageView.image = #imageLiteral(resourceName: "ProductSample1")
            if let name = jeepModel.name {
                cell.nameLabel.text = name
            }
        }
        
        return cell
    }

}
