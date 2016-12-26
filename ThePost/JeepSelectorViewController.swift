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
        layout.itemSize = CGSize(width: 234, height: 219)
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
