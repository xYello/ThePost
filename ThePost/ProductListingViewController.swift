//
//  ProductListingViewController.swift
//  ThePost
//
//  Created by Andrew Robinson on 12/27/16.
//  Copyright © 2016 The Post. All rights reserved.
//

import UIKit
import Firebase

class ProductListingViewController: UIViewController, UICollectionViewDataSource {
    
    var jeepModel: Jeep!

    @IBOutlet weak var collectionView: UICollectionView!
    
    private var products: [Product] = []
    
    private var ref: FIRDatabaseReference!
    private var productRef: FIRDatabaseReference!
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        productRef = ref.child("products")
                
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: floor(view.frame.width * (190/414)), height: floor(view.frame.height * (235/736)))
        
        collectionView.dataSource = self
        
        if let start = jeepModel.startYear, let end = jeepModel.endYear, let name = jeepModel.name {
            navigationController!.navigationBar.topItem!.title = name + " \(start)-\(end)"
        }
        
        // TODO: Remove
        addFakeData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        products.removeAll()
        productRef.observe(.childAdded, with: { snapshot in
            if let productDict = snapshot.value as? [String: Any] {
                if let jeepModel = JeepModel.enumFromString(string: productDict["jeepModel"] as! String) {
                    if let condition = Condition.enumFromString(string: productDict["condition"] as! String) {
                        let product = Product(withName: productDict["name"] as! String,
                                              model: jeepModel,
                                              price: productDict["price"] as! Float,
                                              condition: condition)
                        self.products.append(product)
                        self.collectionView.reloadData()
                    }
                }
            }
        })
        
        productRef.observe(.childRemoved, with: { snapshot in
            if let productDict = snapshot.value as? [String: Any] {
                if let jeepModel = JeepModel.enumFromString(string: productDict["jeepModel"] as! String) {
                    if let condition = Condition.enumFromString(string: productDict["condition"] as! String) {
                        let product = Product(withName: productDict["name"] as! String,
                                              model: jeepModel,
                                              price: productDict["price"] as! Float,
                                              condition: condition)
                        
                        let index = self.indexOfMessage(product)
                        self.products.remove(at: index)
                        
                        self.collectionView.reloadData()
                    }
                }
            }
        })
    }
    
    private func addFakeData() {
        let product1 = Product(withName: "This is my part. :D", model: jeepModel.type, price: 40.24, condition: .new)
        product1.images.append(#imageLiteral(resourceName: "ProductSample1"))
        products.append(product1)
        
        let product2 = Product(withName: "Jeep Bundle", model: jeepModel.type, price: 683.0, condition: .used)
        product2.images.append(#imageLiteral(resourceName: "ProductSample1"))
        products.append(product2)
        
        let product5 = Product(withName: "My Jeep", model: jeepModel.type, price: 11000.0, condition: .broke)
        product5.images.append(#imageLiteral(resourceName: "ProductSample2"))
        product5.images.append(#imageLiteral(resourceName: "ProductSample1"))
        product5.images.append(#imageLiteral(resourceName: "ProductSample2"))
        product5.images.append(#imageLiteral(resourceName: "ProductSample1"))
        products.append(product5)
        
        let product3 = Product(withName: "Jeep Wrangler JK soft top parts 2 door OEM mopar", model: jeepModel.type,  price: 175.0, condition: .remanufactured)
        product3.images.append(#imageLiteral(resourceName: "ProductSample2"))
        products.append(product3)
        
        let product4 = Product(withName: "Custom spoked rims", model: jeepModel.type, price: 1000.0, condition: .other)
        product4.images.append(#imageLiteral(resourceName: "ProductSample1"))
        products.append(product4)
    }
    
    // MARK: - CollectionView datasource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "plpContentCell", for: indexPath) as! ProductListingContentCollectionViewCell
        let product = products[indexPath.row]
        
        cell.favoriteCountLabel.text = "4"
        cell.descriptionLabel.text = product.simplifiedDescription
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        
        let string = formatter.string(from: floor(product.price) as NSNumber)
        let endIndex = string!.index(string!.endIndex, offsetBy: -3)
        let truncated = string!.substring(to: endIndex) // Remove the .00 from the price.
        cell.priceLabel.text = truncated
        
        if product.images.count > 0 {
            cell.imageView.image = product.images[0]
        }
        
        cell.nameLabel.text = product.name
        
        return cell
    }
    
    // MARK: - Helpers
    
    func indexOfMessage(_ snapshot: Product) -> Int {
        var index = 0
        for product in self.products {
            
            // TODO: This check can be true for more than one product...
            if snapshot.name == product.name {
                return index
            }
            index += 1
        }
        return -1
    }

}
