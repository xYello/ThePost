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
    
    private var jeeps:[Jeep] = []
    
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
        
        jeeps.append(Jeep(withType: JeepModel.wranglerJK))
        jeeps.append(Jeep(withType: JeepModel.wranglerTJ))
        jeeps.append(Jeep(withType: JeepModel.wranglerYJ))
        jeeps.append(Jeep(withType: JeepModel.cherokeeXJ))
        
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
        return jeeps.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "jeepSelectorCell", for: indexPath) as! JeepSelectorCollectionViewCell
        
        if cell.selectButton.allTargets.count < 1 {
            cell.selectButton.addTarget(self, action: #selector(selectedJeepCategory), for: .touchUpInside)
        }
        
        if let image = jeeps[indexPath.row].image {
            cell.modelImage.image = image
        }
        if let name = jeeps[indexPath.row].name {
            cell.modelLabel.text = name
        }
        
        if jeeps[indexPath.row].endYear == -1 {
            let components = Calendar.current.dateComponents([.year], from: Date())
            if let start = jeeps[indexPath.row].startYear, let end = components.year {
                cell.modelYearLabel.text = "\(start)-\(end)"
            }
        } else {
            if let start = jeeps[indexPath.row].startYear, let end = jeeps[indexPath.row].endYear {
                cell.modelYearLabel.text = "\(start)-\(end)"
            }
        }
        
        cell.selectButton.jeepModel = jeeps[indexPath.row]
        
        return cell
    }
    
    // MARK: - CollectionView delegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let layout = collectionView.collectionViewLayout as! UPCarouselFlowLayout
        let pageSide = (layout.scrollDirection == .horizontal) ? pageSize.width : pageSize.height
        let offset = (layout.scrollDirection == .horizontal) ? scrollView.contentOffset.x : scrollView.contentOffset.y
        
        pageControl.currentPage = Int(floor((offset - pageSide / 2) / pageSide) + 1)
    }
    
    // MARK: - Actions
    
    @objc private func selectedJeepCategory(sender: JeepModelButton) {
        print(sender.jeepModel.name!)
    }

}
