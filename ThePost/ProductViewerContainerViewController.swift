//
//  ProductViewerContainerViewController.swift
//  ThePost
//
//  Created by Andrew Robinson on 1/9/17.
//  Copyright © 2017 The Post. All rights reserved.
//

import UIKit

class ProductViewerContainerViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDataSource, UITableViewDelegate {
    
    private enum CellType {
        case text
        case details
        case seller
        case exCheck
    }

    @IBOutlet weak var priceContainer: UIView!
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var viewsCountLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    private var tableFormat: [[String:CellType]] = []
    
    var favoriteCount = 0 {
        didSet {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            let number = formatter.string(from: NSNumber(value: favoriteCount))
            likeCountLabel.text = "\(number!)"
        }
    }
    var viewsCount = 0 {
        didSet {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            let number = formatter.string(from: NSNumber(value: viewsCount))
            viewsCountLabel.text = "\(number!)"
        }
    }
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.roundCorners(radius: 8.0)
        
        priceContainer.layer.shadowRadius = 3.0
        priceContainer.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor
        priceContainer.roundCorners(radius: 8.0)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        tableView.dataSource = self
        tableView.delegate = self
        
        favoriteCount = 1213
        viewsCount = 12345
        priceLabel.text = "$20,000"
        
        tableFormat = [["Item Name": .text],
                       ["Make & Model": .text],
                       ["Price": .text],
                       ["Condition": .text],
                       ["Details": .details],
                       ["Seller": .seller],
                       ["Willing to Ship Item": .exCheck],
                       ["Accepts PayPal": .exCheck],
                       ["Accepts Cash": .exCheck]]
    }
    
    // MARK: - CollectionView datasource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! ProductViewerImageCollectionViewCell
        return cell
    }
    
    // MARK: - CollectionView delegate
    
    // MARK: - TableView datasource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableFormat.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        
        let dictionary = tableFormat[indexPath.row]
        let descriptionName = Array(dictionary.keys)[0]
        let type = Array(dictionary.values)[0]
        let imageName = evaluateImageName(withDescription: descriptionName)
        
        if type == .text {
            let textCell = tableView.dequeueReusableCell(withIdentifier: "textCell", for: indexPath) as! ProductViewerTextTableViewCell
            
            textCell.sideImageView.image = UIImage(named: imageName)!.withRenderingMode(.alwaysTemplate)
            textCell.sideImageView.tintColor = #colorLiteral(red: 0.9098039216, green: 0.9058823529, blue: 0.8235294118, alpha: 1)
            textCell.detailNameLabel.text = descriptionName
            textCell.textDetailLabel.text = "I need a longer test text. :D"
            
            cell = textCell
        } else if type == .details {
            let detailsCell = tableView.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath) as! ProductViewerDetailsTableViewCell
            
            detailsCell.sideImageView.image = UIImage(named: imageName)!.withRenderingMode(.alwaysTemplate)
            detailsCell.sideImageView.tintColor = #colorLiteral(red: 0.9098039216, green: 0.9058823529, blue: 0.8235294118, alpha: 1)
            detailsCell.detailNameLabel.text = descriptionName
            detailsCell.datePostedLabel.text = "1 hour 14 mins ago"
            detailsCell.releaseYearLabel.text = "2014"
            
            cell = detailsCell
        } else if type == .seller {
            let sellerCell = tableView.dequeueReusableCell(withIdentifier: "sellerCell", for: indexPath) as! ProductViewerSellerTableViewCell
            
            sellerCell.sideImageView.image = UIImage(named: imageName)!.withRenderingMode(.alwaysTemplate)
            sellerCell.sideImageView.tintColor = #colorLiteral(red: 0.9098039216, green: 0.9058823529, blue: 0.8235294118, alpha: 1)
            sellerCell.detailNameLabel.text = descriptionName
            
            cell = sellerCell
        } else if type == .exCheck {
            let exCheckCell = tableView.dequeueReusableCell(withIdentifier: "exCheckCell", for: indexPath) as! ProductViewerExCheckTableViewCell
            
            exCheckCell.sideImageView.image = UIImage(named: imageName)!.withRenderingMode(.alwaysTemplate)
            exCheckCell.sideImageView.tintColor = #colorLiteral(red: 0.9098039216, green: 0.9058823529, blue: 0.8235294118, alpha: 1)
            exCheckCell.detailNameLabel.text = descriptionName
            
            cell = exCheckCell
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let dictionary = tableFormat[indexPath.row]
        let type = Array(dictionary.values)[0]
        
        var height: CGFloat = 35.0
        
        if type == .details {
            height = 237.0
        } else if type == .seller {
            height = 146.0
        }
        
        return height
    }
    
    // MARK: - TableView delegate
    
    // MARK: - Actions
    
    @IBAction func likeButtonTapped(_ sender: UIButton) {
        print("Increment likes")
    }
    
    // MARK: - Helpers
    
    private func evaluateImageName(withDescription description: String) -> String {
        var imageName = ""
        
        switch description {
        case "Make & Model":
            imageName = "PIPMakeModel"
        case "Price":
            imageName = "PIPPrice"
        case "Condition":
            imageName = "PIPCondition"
        case "Details":
            imageName = "PIPDetails"
        case "Seller":
            imageName = "PVSeller"
        case "Willing to Ship Item":
            imageName = "PIPShip"
        case "Accepts PayPal":
            imageName = "PIPPayPal"
        case "Accepts Cash":
            imageName = "PIPCash"
        default:
            imageName = "PIPItemName"
        }
        
        return imageName
    }

}
