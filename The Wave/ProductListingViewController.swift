//
//  ProductListingViewController.swift
//  ThePost
//
//  Created by Andrew Robinson on 12/27/16.
//  Copyright © 2016 XYello, Inc. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class ProductListingViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate {
    
    var jeepModel: Jeep!

    @IBOutlet weak var jeepTypeLabel: UILabel!
    @IBOutlet weak var numberOfProductsLabel: UILabel!
    
    @IBOutlet weak var productViewTypeView: UIView!
    @IBOutlet weak var smallProductSortButton: UIButton!
    @IBOutlet weak var wideProductSortButton: UIButton!
    
    @IBOutlet weak var noProductView: UIView!
    
    private var selectionBar: UIView?
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var products: [Product] = []
    private var searchedProducts: [Product] = []
    
    private var ref: FIRDatabaseReference!
    private var productRef: FIRDatabaseReference?
    
    private var amountOfProducts = 0 {
        didSet {
            if amountOfProducts == 0 {
                numberOfProductsLabel.text = "No products to display"
            } else if amountOfProducts == 1 {
                numberOfProductsLabel.text = "Viewing 1 product"
            } else {
                numberOfProductsLabel.text = "Viewing \(amountOfProducts) products"
            }
        }
    }
    
    private var searchedAmountOfProducts = 0 {
        didSet {
            if searchedAmountOfProducts == 0 {
                numberOfProductsLabel.text = "No products to display"
            } else if searchedAmountOfProducts == 1 {
                numberOfProductsLabel.text = "Viewing 1 product"
            } else {
                numberOfProductsLabel.text = "Viewing \(searchedAmountOfProducts) products"
            }
        }
    }
    
    private var isSearching = false
    private var isWideViewType = false
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        
        smallProductSortButton.setImage(#imageLiteral(resourceName: "SmallProducts").withRenderingMode(.alwaysTemplate), for: .normal)
        smallProductSortButton.imageView!.tintColor = UIColor.white
        
        wideProductSortButton.setImage(#imageLiteral(resourceName: "WideProducts").withRenderingMode(.alwaysTemplate), for: .normal)
        wideProductSortButton.imageView!.tintColor = #colorLiteral(red: 0.9098039216, green: 0.9058823529, blue: 0.8235294118, alpha: 0.5)
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let viewType = KeychainWrapper.standard.string(forKey: ProductListingType.key)
        if viewType == nil || viewType == ProductListingType.small {
            layout.itemSize = CGSize(width: floor(view.frame.width * (190/414)), height: floor(view.frame.height * (235/736)))
        } else {
            isWideViewType = true
            layout.itemSize = CGSize(width: floor(view.frame.width * (394/414)), height: floor(view.frame.height * (235/736)))
        }
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        if let navBar = navigationController?.navigationBar {
            navBar.clipsToBounds = true
        }
        
        FIRAuth.auth()?.addStateDidChangeListener() { auth, user in
            self.collectionView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let selectedJeepDescription = KeychainWrapper.standard.string(forKey: UserInfoKeys.UserSelectedJeep) ?? ""
        let jeepType = JeepModel.enumFromString(string: selectedJeepDescription)
        
        if productRef == nil || jeepType != jeepModel.type {
            products.removeAll()
            amountOfProducts = 0
            
            // Reload the collectionView just in case there are no products
            collectionView.performBatchUpdates({
                self.collectionView.reloadSections(IndexSet(integer: 0))
            }, completion: nil)

            jeepModel = Jeep(withType: jeepType)

            if let name = jeepModel.name {
                jeepTypeLabel.text = name
            }
            
            productRef = ref.child("products")
            
            var query = productRef!.queryOrdered(byChild: "soldModel")
                .queryStarting(atValue: "SELLING").queryEnding(atValue: "SELLING\u{f8ff}").queryLimited(toLast: 200)
            if jeepModel.type != .all {
                query = productRef!.queryOrdered(byChild: "soldModel")
                    .queryStarting(atValue: "SELLING" + jeepModel.type.description)
                    .queryEnding(atValue: "SELLING" + jeepModel.type.description)
                    .queryLimited(toLast: 200)
            }
            query.observe(.childAdded, with: { snapshot in
                if let productDict = snapshot.value as? [String: AnyObject] {
                    if let product = Product.createProduct(with: productDict, with: snapshot.key) {
                        
                        self.amountOfProducts += 1
                        
                        self.placeInOrder(product: product)
                        
                        if !self.isSearching {
                            self.collectionView.performBatchUpdates({
                                self.collectionView.reloadSections(IndexSet(integer: 0))
                            }, completion: nil)
                        }
                        
                    }
                }
            })
            
            query.observe(.childRemoved, with: { snapshot in
                if let productDict = snapshot.value as? [String: AnyObject] {
                    if let product = Product.createProduct(with: productDict, with: snapshot.key) {
                        let index = self.indexOfProduct(product)
                        
                        if index != -1 {
                            self.amountOfProducts -= 1
                            self.products.remove(at: index)
                            
                            if !self.isSearching {
                                self.collectionView.performBatchUpdates({
                                    self.collectionView.reloadSections(IndexSet(integer: 0))
                                }, completion: nil)
                            }
                        }
                        
                    }
                }
            })
            
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if selectionBar == nil {
            selectionBar = UIView()
            if isWideViewType {
                selectionBar!.frame = CGRect(x: wideProductSortButton.frame.origin.x, y: wideProductSortButton.frame.origin.y + wideProductSortButton.frame.height - 2, width: wideProductSortButton.frame.width, height: 2)
                wideProductSortButton.sendActions(for: .touchUpInside)
            } else {
                selectionBar!.frame = CGRect(x: smallProductSortButton.frame.origin.x, y: smallProductSortButton.frame.origin.y + smallProductSortButton.frame.height - 2, width: smallProductSortButton.frame.width, height: 2)
            }
            selectionBar!.backgroundColor = UIColor.white
            productViewTypeView.addSubview(selectionBar!)
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
        if productArray().count == 0 {
            UIView.animate(withDuration: 0.25, animations: { done in
                self.noProductView.alpha = 1.0
            })
        } else {
            self.noProductView.alpha = 0.0
        }
        
        return productArray().count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "plpContentCell", for: indexPath) as! ProductListingContentCollectionViewCell
        let product = productArray()[indexPath.row]
        
        cell.descriptionLabel.text = product.jeepModel.description
        
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
        
        cell.imageView.image = nil
        
        return cell
    }
    
    // MARK: - CollectionView delegate
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let productCell = cell as? ProductListingContentCollectionViewCell {
            productCell.productKey = productArray()[indexPath.row].uid
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "viewProductInfo") as? ProductViewerViewController {
            vc.modalPresentationStyle = .overCurrentContext
            
            let product = productArray()[indexPath.row]
            vc.product = product
            
            if let tabController = tabBarController {
                PresentationCenter.manager.present(viewController: vc, sender: tabController)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "productListingSearchBarHeader", for: indexPath) as! ProductListingCollectionReusableView
            
            header.searchBar.delegate = self
            header.filterButton.addTarget(self, action: #selector(filterButtonPressed), for: .touchUpInside)
            
            header.searchBar.layer.borderWidth = 1.0
            header.searchBar.layer.borderColor = header.searchBar.barTintColor?.cgColor
            
            if isSearching {
                header.filterButton.setImage(nil, for: .normal)
                header.filterButton.setTitle("Cancel", for: .normal)
            }
            
            return header
        default:
            assert(false, "Supplementary view type not configured.")
        }
        return UICollectionReusableView()
    }
    
    // MARK: - SearchBar delegate
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        let indexPath = IndexPath(row: 0, section: 0)
        let header = collectionView.supplementaryView(forElementKind: UICollectionElementKindSectionHeader, at: indexPath) as! ProductListingCollectionReusableView
        
        header.filterButton.setImage(nil, for: .normal)
        header.filterButton.setTitle("Cancel", for: .normal)
        
        isSearching = true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let indexPath = IndexPath(row: 0, section: 0)
        let header = collectionView.supplementaryView(forElementKind: UICollectionElementKindSectionHeader, at: indexPath) as! ProductListingCollectionReusableView
        
        header.searchBar.resignFirstResponder()
        
        self.searchedProducts.removeAll()
        self.searchedAmountOfProducts = 0
        
        if let text = header.searchBar.text {
            let query = FIRDatabase.database().reference().child("products").queryOrdered(byChild: "name").queryStarting(atValue: text).queryEnding(atValue: text + "\u{f8ff}").queryLimited(toFirst: 500)
            query.observeSingleEvent(of: .value, with: { snapshot in
                if let productsDict = snapshot.value as? [String: AnyObject] {
                    for (key, value) in productsDict {
                        if let productDict = value as? [String: AnyObject] {
                            
                            if let product = Product.createProduct(with: productDict, with: key) {
                                self.searchedProducts.append(product)
                                self.searchedAmountOfProducts += 1
                            }
                            
                        }
                    }
                    
                    self.collectionView.performBatchUpdates({
                        self.collectionView.reloadSections(IndexSet(integer: 0))
                    }, completion: { done in
                        let indexPath = IndexPath(row: 0, section: 0)
                        let header = self.collectionView.supplementaryView(forElementKind: UICollectionElementKindSectionHeader, at: indexPath) as! ProductListingCollectionReusableView
                        
                        header.searchBar.text = text
                    })
                } else {
                    self.collectionView.performBatchUpdates({
                        self.collectionView.reloadSections(IndexSet(integer: 0))
                    }, completion: { done in
                        let indexPath = IndexPath(row: 0, section: 0)
                        let header = self.collectionView.supplementaryView(forElementKind: UICollectionElementKindSectionHeader, at: indexPath) as! ProductListingCollectionReusableView
                        
                        header.searchBar.text = text
                    })
                }
            })
        }
    }
    
    // MARK: - Actions
    
    @IBAction func showSmallProductViews(_ sender: UIButton) {
        
        smallProductSortButton.imageView!.tintColor = UIColor.white
        wideProductSortButton.imageView!.tintColor = #colorLiteral(red: 0.9098039216, green: 0.9058823529, blue: 0.8235294118, alpha: 0.5)
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: floor(view.frame.width * (190/414)), height: floor(view.frame.height * (235/736)))
        
        KeychainWrapper.standard.set(ProductListingType.small, forKey: ProductListingType.key)
        
        UIView.animate(withDuration: 0.25, delay: 0.1, options: .curveEaseOut, animations: {
            self.selectionBar!.frame = CGRect(x: self.smallProductSortButton.frame.origin.x, y: self.smallProductSortButton.frame.origin.y + self.smallProductSortButton.frame.height - 2, width: self.smallProductSortButton.frame.width, height: 2)
        }, completion: nil)
    }
    
    @IBAction func showWideProductViews(_ sender: UIButton) {
        
        smallProductSortButton.imageView!.tintColor = #colorLiteral(red: 0.9098039216, green: 0.9058823529, blue: 0.8235294118, alpha: 0.5)
        wideProductSortButton.imageView!.tintColor = UIColor.white
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: floor(view.frame.width * (394/414)), height: floor(view.frame.height * (235/736)))
        
        KeychainWrapper.standard.set(ProductListingType.wide, forKey: ProductListingType.key)
        
        UIView.animate(withDuration: 0.25, delay: 0.1, options: .curveEaseOut, animations: {
            self.selectionBar!.frame = CGRect(x: self.wideProductSortButton.frame.origin.x, y: self.wideProductSortButton.frame.origin.y + self.wideProductSortButton.frame.height - 2, width: self.wideProductSortButton.frame.width, height: 2)
        }, completion: nil)
    }
    
    @objc private func filterButtonPressed() {
        if isSearching {
            searchedProducts.removeAll()
            
            isSearching = false
            
            collectionView.performBatchUpdates({
                self.collectionView.reloadSections(IndexSet(integer: 0))
            }, completion: { done in
                let indexPath = IndexPath(row: 0, section: 0)
                let header = self.collectionView.supplementaryView(forElementKind: UICollectionElementKindSectionHeader, at: indexPath) as! ProductListingCollectionReusableView
                
                header.searchBar.resignFirstResponder()
                header.searchBar.text = ""
                
                header.filterButton.setTitle("", for: .normal)
                header.filterButton.setImage(#imageLiteral(resourceName: "PLPFilters"), for: .normal)
                
                self.searchedAmountOfProducts = 0
                
                // Reset the counter to the counter of the feed.
                let productCount = self.amountOfProducts
                self.amountOfProducts = productCount
            })
            
        } else {
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = mainStoryboard.instantiateViewController(withIdentifier: "jeepSelectorViewController") as! JeepSelectorViewController
            
            present(vc, animated: true, completion: nil)
        }
    }
    
    // MARK: - Helpers

    private func placeInOrder(product: Product) {
        if products.count == 0 {
            products.append(product)
        } else {
            var iteratorIndex = 0
            var indexToPlaceAt = -1
            for prod in products {
                if indexToPlaceAt == -1 {
                    if product.postedDate >= prod.postedDate {
                        indexToPlaceAt = iteratorIndex
                    }
                }

                iteratorIndex += 1
            }

            if indexToPlaceAt == -1 {
                indexToPlaceAt = products.count
            }

            products.insert(product, at: indexToPlaceAt)
        }
    }

    private func indexOfProduct(_ snapshot: Product) -> Int {
        var index = 0
        for product in self.products {
            
            if snapshot.uid == product.uid {
                return index
            }
            index += 1
        }
        return -1
    }
    
    private func productArray() -> [Product] {
        var arrayToReturn: [Product]
        if searchedProducts.count > 0 {
            arrayToReturn = searchedProducts
        } else {
            arrayToReturn = products
        }
        
        return arrayToReturn
    }

}
