//
//  JeepSelectorViewController.swift
//  ThePost
//
//  Created by Andrew Robinson on 12/26/16.
//  Copyright © 2016 The Post. All rights reserved.
//

import UIKit
import UPCarouselFlowLayout

class JeepSelectorViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    private var pageSize: CGSize {
        let layout = collectionView.collectionViewLayout as! UPCarouselFlowLayout
        var pageSize = layout.itemSize
        pageSize.width += layout.minimumLineSpacing
        return pageSize
    }
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout = UPCarouselFlowLayout()
        
        // These ratios that are defined here are values defined in the Sketch file. Cell size / screen size
        layout.itemSize = CGSize(width: floor(view.frame.width * (350/414)), height: floor(view.frame.height * (326/736)))
        
        layout.spacingMode = UPCarouselFlowLayoutSpacingMode.overlap(visibleOffset: 120)
        layout.scrollDirection = .horizontal
        layout.sideItemScale = 1.0
        layout.sideItemAlpha = 0.3
        layout.sideItemShift = 25.0
        collectionView.collectionViewLayout = layout
        
        if #available(iOS 10.0, *) {
            collectionView.isPrefetchingEnabled = false
        }
        
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    // MARK: - CollectionView datasource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "jeepSelectorCell", for: indexPath) as! JeepSelectorCollectionViewCell
        
        switch indexPath.row {
        case 0:
            cell.modelImage.image = UIImage(named: "WranglerJK")
            cell.modelLabel.text = "Jeep Wrangler JK"
            cell.modelYearLabel.text = "2007-2016"
        case 1:
            cell.modelImage.image = UIImage(named: "WranglerTJ")
            cell.modelLabel.text = "Jeep Wrangler TJ"
            cell.modelYearLabel.text = "1997-2006"
        case 2:
            cell.modelImage.image = UIImage(named: "WranglerYJ")
            cell.modelLabel.text = "Jeep Wrangler YJ"
            cell.modelYearLabel.text = "1987-1995"
        default:
            cell.modelImage.image = UIImage(named: "CherokeeXJ")
            cell.modelLabel.text = "Jeep Cherokee XJ"
            cell.modelYearLabel.text = "1984-2001"
        }
        
        return cell
    }
    
    // MARK: - CollectionView delegate
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let layout = collectionView.collectionViewLayout as! UPCarouselFlowLayout
        let pageSide = (layout.scrollDirection == .horizontal) ? pageSize.width : pageSize.height
        let offset = (layout.scrollDirection == .horizontal) ? scrollView.contentOffset.x : scrollView.contentOffset.y
        
        pageControl.currentPage = Int(floor((offset - pageSide / 2) / pageSide) + 1)
    }

}
