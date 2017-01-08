//
//  ProfileViewController.swift
//  ThePost
//
//  Created by Andrew Robinson on 1/6/17.
//  Copyright © 2017 The Post. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class ProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private enum ProductViewing {
        case selling
        case sold
        case liked
    }
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileNameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var numberOfReviewsLabel: UILabel!
    
    @IBOutlet weak var sellingProductTypeButton: UIButton!
    @IBOutlet weak var bottomMostSeperator: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    
    private var previouslySelectedButton: UIButton!
    private var selectionBar: UIView?
    
    private var productViewType: ProductViewing = .selling {
        didSet {
            tableView.reloadData()
        }
    }
    
    private var sellingProducts: [Product] = []
    private var soldProducts: [Product] = []
    private var likedProducts: [Product] = []
    
    private var userProductsRef: FIRDatabaseReference!

    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let uid = FIRAuth.auth()!.currentUser!.uid
        userProductsRef = FIRDatabase.database().reference().child("user-products").child(uid)
        setupProductListeners()
        
        getUserProfile(with: uid)
        
        if let city = KeychainWrapper.standard.string(forKey: "userCity"), let state = KeychainWrapper.standard.string(forKey: "userState") {
            locationLabel.text = "\(city), \(state)"
        } else {
            locationLabel.text = "(No location provided)"
        }
        
        numberOfReviewsLabel.text = "\(0) reviews"
        
        tableView.dataSource = self
        tableView.delegate = self
        
        previouslySelectedButton = sellingProductTypeButton
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if selectionBar == nil {
            selectionBar = UIView()
            selectionBar!.frame = CGRect(x: sellingProductTypeButton.frame.origin.x - 4, y: self.bottomMostSeperator.frame.origin.y - 1, width: sellingProductTypeButton.frame.width + 8, height: 2)
            selectionBar!.backgroundColor = #colorLiteral(red: 0.8470588235, green: 0.337254902, blue: 0.2156862745, alpha: 1)
            selectionBar!.isUserInteractionEnabled = false
            view.addSubview(selectionBar!)
        }
    }
    
    deinit {
        userProductsRef.removeAllObservers()
    }
    
    // MARK: - TableView datasource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productArray().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "productListingTableCell", for: indexPath) as! ProductListingTableViewCell
        let product = productArray()[indexPath.row]
        
        if let likeCount = product.likeCount {
            cell.likeCountLabel.text = "\(likeCount)"
        } else {
            cell.likeCountLabel.text = "0"
        }
        
        cell.nameLabel.text = product.name
        cell.simplifiedDescriptionLabel.text = product.simplifiedDescription
        
        if product.price == 0.00 {
            cell.priceLabel.text = "Free"
        } else {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            let string = formatter.string(from: floor(product.price) as NSNumber)
            let endIndex = string!.index(string!.endIndex, offsetBy: -3)
            let truncated = string!.substring(to: endIndex) // Remove the .00 from the price.
            cell.priceLabel.text = truncated
        }
        
        if product.isSold {
            cell.productImageView.alpha = 0.2
            cell.soldImageView.isHidden = false
            cell.nameLabel.alpha = 0.2
            cell.priceLabel.alpha = 0.2
            cell.simplifiedDescriptionLabel.alpha = 0.2
            cell.likeImageView.tintColor = #colorLiteral(red: 0.9098039216, green: 0.9058823529, blue: 0.8235294118, alpha: 1)
            cell.likeImageView.alpha = 0.2
            cell.likeCountLabel.alpha = 0.2
            
            let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: cell.priceLabel.text!)
            attributeString.addAttribute(NSStrikethroughStyleAttributeName, value: 2, range: NSMakeRange(0, attributeString.length))
            cell.priceLabel.attributedText = attributeString
        }
        
        return cell
    }
    
    // MARK: - TableView delegate
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let productCell = cell as? ProductListingTableViewCell {
            productCell.product = productArray()[indexPath.row]
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let productCell = cell as? ProductListingTableViewCell {
            if let likesListener = productCell.likesListenerRef {
                likesListener.removeAllObservers()
            }
        }
    }
    
    // MARK: - Actions

    @IBAction func productListingButtonTapped(_ sender: UIButton) {
        
        if sender.titleColor(for: .normal) != #colorLiteral(red: 0.8470588235, green: 0.337254902, blue: 0.2156862745, alpha: 1) {
            sender.setTitleColor(#colorLiteral(red: 0.8470588235, green: 0.337254902, blue: 0.2156862745, alpha: 1), for: .normal)
            previouslySelectedButton.setTitleColor(#colorLiteral(red: 0.9098039216, green: 0.9058823529, blue: 0.8235294118, alpha: 1), for: .normal)
            previouslySelectedButton = sender
            
            if sender.currentTitle == "Selling" {
                productViewType = .selling
            } else if sender.currentTitle == "Sold" {
                productViewType = .sold
            } else if sender.currentTitle == "Liked" {
                productViewType = .liked
            }
            
            UIView.animate(withDuration: 0.25, delay: 0.1, options: .curveEaseOut, animations: {
                self.selectionBar!.frame = CGRect(x: sender.frame.origin.x - 4, y: self.bottomMostSeperator.frame.origin.y - 1, width: sender.frame.width + 8, height: 2)
            }, completion: nil)
            
        }
    }
    
    @IBAction func settingsButtonPressed(_ sender: UIButton) {
        do {
            try FIRAuth.auth()?.signOut()
        } catch {
            print("Error signing out")
        }
    }
    
    // MARK: - Helpers
    
    private func productArray() -> [Product] {
        var arrayToReturn: [Product]
        switch productViewType {
        case .selling:
            arrayToReturn = sellingProducts
        case .sold:
            arrayToReturn = soldProducts
        case .liked:
            arrayToReturn = likedProducts
        }
        
        return arrayToReturn
    }
    
    private func getUserProfile(with uid: String) {
        if let name = FIRAuth.auth()?.currentUser?.displayName {
            profileNameLabel.text = name
        } else {
            let ref = FIRDatabase.database().reference().child(uid).child("fullName")
            ref.observeSingleEvent(of: .value, with: { snapshot in
                if let fullName = snapshot.value as? String {
                    DispatchQueue.main.async {
                        self.profileNameLabel.text = fullName
                    }
                }
            })
        }
    }
    
    private func setupProductListeners() {
        userProductsRef.observe(.childAdded, with: { snapshot in
            if let productDict = snapshot.value as? [String: Any] {
                if let jeepModel = JeepModel.enumFromString(string: productDict["jeepModel"] as! String) {
                    if let condition = Condition.enumFromString(string: productDict["condition"] as! String) {
                        let product = Product(withName: productDict["name"] as! String,
                                              model: jeepModel,
                                              price: productDict["price"] as! Float,
                                              condition: condition)
                        
                        product.uid = snapshot.key
                        
                        if let likeCount = productDict["likeCount"] as? Int {
                            product.likeCount = likeCount
                        }
                        
                        if let isSold = productDict["isSold"] as? Bool {
                            product.isSold = isSold
                            if isSold {
                                self.soldProducts.append(product)
                            } else {
                                self.sellingProducts.append(product)
                            }
                        } else {
                            self.sellingProducts.append(product)
                        }
                        
                        self.tableView.reloadData()
                    }
                }
            }
        })
        
        userProductsRef.observe(.childRemoved, with: { snapshot in
            if let productDict = snapshot.value as? [String: Any] {
                if let jeepModel = JeepModel.enumFromString(string: productDict["jeepModel"] as! String) {
                    if let condition = Condition.enumFromString(string: productDict["condition"] as! String) {
                        let product = Product(withName: productDict["name"] as! String,
                                              model: jeepModel,
                                              price: productDict["price"] as! Float,
                                              condition: condition)
                        product.uid = snapshot.key
                        
                        let index = self.indexOfMessage(product)
                        if let isSold = productDict["isSold"] as? Bool {
                            if isSold {
                                self.soldProducts.remove(at: index)
                            } else {
                                self.sellingProducts.remove(at: index)
                            }
                        } else {
                            self.sellingProducts.remove(at: index)
                        }
                        
                        self.tableView.reloadData()
                    }
                }
            }
        })
    }
    
    private func indexOfMessage(_ snapshot: Product) -> Int {
        var index = 0
        for product in productArray() {
            
            if snapshot.uid == product.uid {
                return index
            }
            index += 1
        }
        return -1
    }
    
}
