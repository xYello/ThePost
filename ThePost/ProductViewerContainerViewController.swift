//
//  ProductViewerContainerViewController.swift
//  ThePost
//
//  Created by Andrew Robinson on 1/9/17.
//  Copyright © 2017 The Post. All rights reserved.
//

import UIKit
import Firebase

class ProductViewerContainerViewController: UIViewController, UICollectionViewDataSource, UITableViewDataSource, UITableViewDelegate {
    
    private enum CellType {
        case text
        case details
        case seller
        case exCheck
    }

    @IBOutlet weak var priceContainer: UIView!
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var likeImageView: UIImageView!
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var viewsCountLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var orangeButton: UIButton!
    @IBOutlet weak var greenButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    
    private var likesRef: FIRDatabaseReference!
    private var viewsRef: FIRDatabaseReference!
    
    private var tableFormat: [[String: CellType]] = []
    private var textCellLayout: [String] = []
    private var checkCellLayout: [Bool] = []
    
    private var seller: User!
    
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
    
    var product: Product!
    
    // MARK: - View lifecycle
    
    // TODO: Report button
    override func viewDidLoad() {
        super.viewDidLoad()
        view.roundCorners(radius: 8.0)
        view.clipsToBounds = true
        
        product.images.removeAll()
        
        priceContainer.layer.shadowRadius = 3.0
        priceContainer.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor
        priceContainer.roundCorners(radius: 8.0)
        
        collectionView.dataSource = self
        
        tableView.dataSource = self
        tableView.delegate = self
        
        orangeButton.roundCorners(radius: 8.0)
        greenButton.roundCorners(radius: 8.0)
        
        closeButton.layer.borderColor = closeButton.titleLabel!.textColor.cgColor
        closeButton.layer.borderWidth = 1.0
        closeButton.roundCorners(radius: 8.0)
        
        if let image = likeImageView.image {
            likeImageView.image = image.withRenderingMode(.alwaysTemplate)
            likeImageView.tintColor = #colorLiteral(red: 0.2235294118, green: 0.2235294118, blue: 0.2235294118, alpha: 0.2034658138)
        }
        
        tableFormat = [["Item Name": .text],
                       ["Make & Model": .text],
                       ["Price": .text],
                       ["Condition": .text],
                       ["Details": .details],
                       ["Seller": .seller],
                       ["Willing to Ship Item": .exCheck],
                       ["Accepts PayPal": .exCheck],
                       ["Accepts Cash": .exCheck]]
        
        if let uid = FIRAuth.auth()?.currentUser?.uid {
            if uid == product.ownerId {
                orangeButton.setTitle("Delete", for: .normal)
                greenButton.setTitle("Edit", for: .normal)
            } else {
                orangeButton.setTitle("Make Offer", for: .normal)
                greenButton.setTitle("Message", for: .normal)
            }
        }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        let string = formatter.string(from: floor(product.price) as NSNumber)
        let endIndex = string!.index(string!.endIndex, offsetBy: -3)
        let truncated = string!.substring(to: endIndex) // Remove the .00 from the price.
        priceLabel.text = truncated
        
        textCellLayout = [product.name, product.jeepModel.description, truncated, product.condition.description]
        checkCellLayout = [product.willingToShip, product.acceptsPayPal, product.acceptsCash]
        
        grabProductImages()
        setupLikesAndViewsListeners()
        grabSellerInfo()
        checkForCurrentUserLike()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    deinit {
        likesRef.removeAllObservers()
        viewsRef.removeAllObservers()
    }
    
    // MARK: - CollectionView datasource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return product.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! ProductViewerImageCollectionViewCell
        
        let url = URL(string: product.images[indexPath.row])
        cell.imageView.sd_setImage(with: url)
        
        return cell
    }
    
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
            
            let detailText = textCellLayout[indexPath.row]
            textCell.textDetailLabel.text = detailText
            
            cell = textCell
        } else if type == .details {
            let detailsCell = tableView.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath) as! ProductViewerDetailsTableViewCell
            
            detailsCell.sideImageView.image = UIImage(named: imageName)!.withRenderingMode(.alwaysTemplate)
            detailsCell.sideImageView.tintColor = #colorLiteral(red: 0.9098039216, green: 0.9058823529, blue: 0.8235294118, alpha: 1)
            detailsCell.detailNameLabel.text = descriptionName
            detailsCell.hasOriginalBox = product.originalBox
            detailsCell.datePostedLabel.text = product.relativeDate
            
            if let releaseYear = product.releaseYear {
                detailsCell.releaseYearLabel.text = "\(releaseYear)"
            } else {
                detailsCell.releaseYearLabel.text = ""
            }
            
            if let itemDescription = product.detailedDescription {
                detailsCell.descriptionTextView.text = "\(itemDescription)"
            } else {
                detailsCell.descriptionTextView.text = "No description provided."
            }
            
            cell = detailsCell
        } else if type == .seller {
            let sellerCell = tableView.dequeueReusableCell(withIdentifier: "sellerCell", for: indexPath) as! ProductViewerSellerTableViewCell
            
            sellerCell.sideImageView.image = UIImage(named: imageName)!.withRenderingMode(.alwaysTemplate)
            sellerCell.sideImageView.tintColor = #colorLiteral(red: 0.9098039216, green: 0.9058823529, blue: 0.8235294118, alpha: 1)
            sellerCell.detailNameLabel.text = descriptionName
            sellerCell.sellerNameLabel.text = seller.fullName
            sellerCell.numberOfReviewsLabel.text = "0 Reviews"
            
            cell = sellerCell
        } else if type == .exCheck {
            let exCheckCell = tableView.dequeueReusableCell(withIdentifier: "exCheckCell", for: indexPath) as! ProductViewerExCheckTableViewCell
            
            exCheckCell.sideImageView.image = UIImage(named: imageName)!.withRenderingMode(.alwaysTemplate)
            exCheckCell.sideImageView.tintColor = #colorLiteral(red: 0.9098039216, green: 0.9058823529, blue: 0.8235294118, alpha: 1)
            exCheckCell.detailNameLabel.text = descriptionName
            
            let index = tableFormat.count - indexPath.row
            exCheckCell.isChecked = checkCellLayout[checkCellLayout.count - index]
            
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO: Open Owner's profile
    }
    
    // MARK: - Actions
    
    @IBAction func likeButtonTapped(_ sender: UIButton) {
        if likeImageView.tintColor == #colorLiteral(red: 0.9019607843, green: 0.2980392157, blue: 0.2352941176, alpha: 1) {
            likeImageView.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.3)
        } else {
            likeImageView.tintColor = #colorLiteral(red: 0.9019607843, green: 0.2980392157, blue: 0.2352941176, alpha: 1)
        }
        
        let productRef = FIRDatabase.database().reference().child("products").child(product.uid)
        incrementLikes(forRef: productRef)
        productRef.observeSingleEvent(of: .value, with: { snapshot in
            let value = snapshot.value as? NSDictionary
            if let uid = value?["owner"] as? String {
                let userProductRef = FIRDatabase.database().reference().child("user-products").child(uid).child(self.product.uid)
                self.incrementLikes(forRef: userProductRef)
            }
        })
    }
    
    @IBAction func orangeButtonTapped(_ sender: UIButton) {
        if sender.currentTitle == "Delete" {
            let alert = UIAlertController(title: "Delete \(product.name!)?", message: "Are you sure you want to delete \(product.name!)?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { action in
                // TODO: Delete the product for everywhere.
//                FIRDatabase.database().reference().child("products").child(self.product.uid).removeValue()
//                FIRDatabase.database().reference().child("user-products").child(FIRAuth.auth()!.currentUser!.uid).child(self.product.uid)
//                FIRDatabase.database().reference().child("products-location").child(self.product.uid).removeValue()
//                self.dismissParent()
            }))
            
            present(alert, animated: true, completion: nil)
        } else if sender.currentTitle == "Make Offer" {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: openChatControllerNotificationKey), object: nil, userInfo:
                ["productID": product.uid,
                 "productOwnerID": product.ownerId,
                 "productOwnerName": seller.fullName,
                 "preformattedMessage": "I would like to buy your product that you have for sale! Specifically the, \(product.name!)."])
            dismissParent()
        }
    }
    
    @IBAction func greenButtonTapped(_ sender: UIButton) {
        if sender.currentTitle == "Edit" {
            
        } else if sender.currentTitle == "Message" {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: openChatControllerNotificationKey), object: nil, userInfo:
                ["productID": product.uid,
                 "productOwnerID": product.ownerId,
                 "productOwnerName": seller.fullName])
            dismissParent()
        }
    }
    
    @IBAction func closeTapped(_ sender: UIButton) {
        dismissParent()
    }
    
    // MARK: - Helpers
    
    private func dismissParent() {
        if let parent = parent as? ProductViewerViewController {
            parent.prepareForDismissal {
                parent.dismiss(animated: false, completion: nil)
            }
        }
    }
    
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
    
    // MARK: - Firebase Database
    
    private func grabProductImages() {
        let imagesRef = FIRDatabase.database().reference().child("products").child(product.uid).child("images")
        imagesRef.observeSingleEvent(of: .value, with: { snapshot in
            for image in snapshot.children.allObjects as! [FIRDataSnapshot] {
                self.product.images.append(image.value as! String)
            }
            self.collectionView.reloadData()
        })
    }
    
    private func setupLikesAndViewsListeners() {
        likesRef = FIRDatabase.database().reference().child("products").child(product.uid).child("likeCount")
        likesRef.observe(.value, with: { snapshot in
            if let count = snapshot.value as? Int {
                DispatchQueue.main.async {
                    self.likeCountLabel.text = "\(count)"
                }
            }
        })
        
        viewsRef = FIRDatabase.database().reference().child("products").child(product.uid).child("viewCount")
        viewsRef.observe(.value, with: { snapshot in
            if let count = snapshot.value as? Int {
                DispatchQueue.main.async {
                    self.viewsCountLabel.text = "\(count)"
                }
            }
        })
        
        // Increment views
        let productRef = FIRDatabase.database().reference().child("products").child(product.uid)
        incrementViews(forRef: productRef.child("viewCount"))
        productRef.observeSingleEvent(of: .value, with: { snapshot in
            let value = snapshot.value as? NSDictionary
            if let uid = value?["owner"] as? String {
                let userProductRef = FIRDatabase.database().reference().child("user-products").child(uid).child(self.product.uid).child("viewCount")
                self.incrementViews(forRef: userProductRef)
            }
        })
    }
    
    private func grabSellerInfo() {
        seller = User()
        let userRef = FIRDatabase.database().reference().child("users").child(product.ownerId).child("fullName")
        userRef.observeSingleEvent(of: .value, with: { snapshot in
            if let name = snapshot.value as? String {
                self.seller.fullName = name
                let indexPath = IndexPath(row: 5, section: 0)
                self.tableView.reloadRows(at: [indexPath], with: .none)
            }
        })
    }
    
    private func incrementLikes(forRef ref: FIRDatabaseReference) {
        
        ref.runTransactionBlock({ (currentData: FIRMutableData) -> FIRTransactionResult in
            if var product = currentData.value as? [String : AnyObject], let uid = FIRAuth.auth()?.currentUser?.uid {
                var likes: Dictionary<String, Bool> = product["likes"] as? [String : Bool] ?? [:]
                var likeCount = product["likeCount"] as? Int ?? 0
                
                let userLikesRef = FIRDatabase.database().reference().child("user-likes").child(uid)
                
                if let _ = likes[uid] {
                    likeCount -= 1
                    likes.removeValue(forKey: uid)
                    userLikesRef.child(self.product.uid).removeValue()
                } else {
                    likeCount += 1
                    likes[uid] = true
                    
                    let userLikesUpdate = [self.product.uid: true]
                    userLikesRef.updateChildValues(userLikesUpdate)
                }
                product["likeCount"] = likeCount as AnyObject?
                product["likes"] = likes as AnyObject?
                
                DispatchQueue.main.sync {
                    self.likeCountLabel.text = "\(likeCount)"
                }
                
                currentData.value = product
                
                return FIRTransactionResult.success(withValue: currentData)
            }
            return FIRTransactionResult.success(withValue: currentData)
        }) { (error, committed, snapshot) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
        
    }
    
    private func incrementViews(forRef ref: FIRDatabaseReference) {
        ref.runTransactionBlock({ (currentData: FIRMutableData) -> FIRTransactionResult in
            if let count = currentData.value as? Int {
                currentData.value = count + 1
                
                return FIRTransactionResult.success(withValue: currentData)
            }
            return FIRTransactionResult.success(withValue: currentData)
        }) { (error, committed, snapshot) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    private func checkForCurrentUserLike() {
        if let uid = FIRAuth.auth()?.currentUser?.uid {
            var color = #colorLiteral(red: 0.2235294118, green: 0.2235294118, blue: 0.2235294118, alpha: 0.2034658138)
            let likesRef = FIRDatabase.database().reference().child("products").child(product.uid)
            likesRef.observeSingleEvent(of: .value, with: { snapshot in
                if let product = snapshot.value as? [String: AnyObject] {
                    if let likes = product["likes"] as? [String: Bool] {
                        if let _ = likes[uid] {
                            color = #colorLiteral(red: 0.9019607843, green: 0.2980392157, blue: 0.2352941176, alpha: 1)
                        }
                    }
                    
                }
                
                DispatchQueue.main.async {
                    self.likeImageView.tintColor = color
                }
                
            })
        }
    }

}
