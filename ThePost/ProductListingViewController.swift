//
//  ProductListingViewController.swift
//  ThePost
//
//  Created by Andrew Robinson on 12/27/16.
//  Copyright © 2016 The Post. All rights reserved.
//

import UIKit
import Firebase

class ProductListingViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var jeepModel: Jeep!

    @IBOutlet weak var collectionView: UICollectionView!
    
    private var products: [Product] = []
    
    private var ref: FIRDatabaseReference!
    private var productRef: FIRDatabaseReference?
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
                
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: floor(view.frame.width * (190/414)), height: floor(view.frame.height * (235/736)))
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        if let start = jeepModel.startYear, let end = jeepModel.endYear, let name = jeepModel.name {
            navigationController!.navigationBar.topItem!.title = name + " \(start)-\(end)"
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if productRef == nil {
            productRef = ref.child("products")
            
            productRef!.observe(.childAdded, with: { snapshot in
                if let productDict = snapshot.value as? [String: Any] {
                    if let jeepModel = JeepModel.enumFromString(string: productDict["jeepModel"] as! String) {
                        if let condition = Condition.enumFromString(string: productDict["condition"] as! String) {
                            let product = Product(withName: productDict["name"] as! String,
                                                  model: jeepModel,
                                                  price: productDict["price"] as! Float,
                                                  condition: condition)
                            
                            product.uid = snapshot.key
                            product.ownerId = productDict["owner"] as! String
                            
                            product.dateString = productDict["datePosted"] as! String
                            
                            if let likeCount = productDict["likeCount"] as? Int {
                                product.likeCount = likeCount
                            }
                            
                            product.originalBox = productDict["originalBox"] as! Bool
                            if let year = productDict["releaseYear"] as? Int {
                                product.releaseYear = year
                            }
                            if let desc = productDict["detailedDescription"] as? String {
                                product.detailedDescription = desc
                            }
                            
                            product.willingToShip = productDict["willingToShip"] as! Bool
                            product.acceptsPayPal = productDict["acceptsPayPal"] as! Bool
                            product.acceptsCash = productDict["acceptsCash"] as! Bool
                            
                            if let isSold = productDict["isSold"] as? Bool {
                                product.isSold = isSold
                            }
                            
                            self.products.insert(product, at: 0)
                            
                            self.collectionView.performBatchUpdates({
                                self.collectionView.reloadSections(IndexSet(integer: 0))
                            }, completion: nil)
                        }
                    }
                }
            })
            
            productRef!.observe(.childRemoved, with: { snapshot in
                if let productDict = snapshot.value as? [String: Any] {
                    if let jeepModel = JeepModel.enumFromString(string: productDict["jeepModel"] as! String) {
                        if let condition = Condition.enumFromString(string: productDict["condition"] as! String) {
                            let product = Product(withName: productDict["name"] as! String,
                                                  model: jeepModel,
                                                  price: productDict["price"] as! Float,
                                                  condition: condition)
                            
                            product.uid = snapshot.key
                            
                            let index = self.indexOfMessage(product)
                            self.products.remove(at: index)
                            
                            self.collectionView.performBatchUpdates({
                                self.collectionView.reloadSections(IndexSet(integer: 0))
                            }, completion: nil)
                        }
                    }
                }
            })
        }
    }
    
    deinit {
        ref.removeAllObservers()
        
        if let productRef = productRef {
            productRef.removeAllObservers()
        }
    }
    
    // MARK: - CollectionView datasource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "plpContentCell", for: indexPath) as! ProductListingContentCollectionViewCell
        let product = products[indexPath.row]
        
        if let likeCount = product.likeCount {
            cell.likeCountLabel.text = "\(likeCount)"
        } else {
            cell.likeCountLabel.text = "0"
        }
        
        cell.descriptionLabel.text = product.simplifiedDescription
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        
        if product.price == 0.00 {
            cell.priceLabel.text = "Free"
        } else {
            let string = formatter.string(from: floor(product.price) as NSNumber)
            let endIndex = string!.index(string!.endIndex, offsetBy: -3)
            let truncated = string!.substring(to: endIndex) // Remove the .00 from the price.
            cell.priceLabel.text = truncated
        }
        
        cell.nameLabel.text = product.name
        
        return cell
    }
    
    // MARK: - CollectionView delegate
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let productCell = cell as? ProductListingContentCollectionViewCell {
            productCell.productKey = products[indexPath.row].uid
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let productCell = cell as? ProductListingContentCollectionViewCell {
            if let likesListener = productCell.likesListenerRef {
                likesListener.removeAllObservers()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "viewProductInfo") as? ProductViewerViewController {
            vc.modalPresentationStyle = .overCurrentContext
            
            let product = products[indexPath.row]
            vc.product = product
            
            if let tabController = tabBarController {
                tabController.present(vc, animated: false, completion: nil)
            }
        }
    }
    
    // MARK: - Helpers
    
    private func indexOfMessage(_ snapshot: Product) -> Int {
        var index = 0
        for product in self.products {
            
            if snapshot.uid == product.uid {
                return index
            }
            index += 1
        }
        return -1
    }

}
