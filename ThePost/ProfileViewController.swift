//
//  ProfileViewController.swift
//  ThePost
//
//  Created by Andrew Robinson on 1/6/17.
//  Copyright © 2017 The Post. All rights reserved.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private enum ProductViewing {
        case selling
        case sold
        case liked
    }
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileNameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var settingsButton: UIButton!
    
    @IBOutlet weak var farLeftStar: UIImageView!
    @IBOutlet weak var leftMidStar: UIImageView!
    @IBOutlet weak var midStar: UIImageView!
    @IBOutlet weak var rightMidStar: UIImageView!
    @IBOutlet weak var farRightStar: UIImageView!
    
    @IBOutlet weak var numberOfReviewsLabel: UILabel!
    
    @IBOutlet weak var sellingProductTypeButton: UIButton!
    @IBOutlet weak var bottomMostSeperator: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var closeButton: UIButton!
    
    @IBOutlet weak var profileImageViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomBarHeightConstraint: NSLayoutConstraint!
    
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
    
    private var userProductsRef: FIRDatabaseReference?
    private var likesQuery: FIRDatabaseQuery?
    
    private var shouldUpdateProfileOnNextView = false
    
    private var amountOfStars = 0 {
        didSet {
            switch amountOfStars {
            case 0:
                break
            case 1:
                farLeftStar.tintColor = #colorLiteral(red: 0.9529411765, green: 0.6274509804, blue: 0.09803921569, alpha: 1)
            case 2:
                farLeftStar.tintColor = #colorLiteral(red: 0.9529411765, green: 0.6274509804, blue: 0.09803921569, alpha: 1)
                leftMidStar.tintColor = #colorLiteral(red: 0.9529411765, green: 0.6274509804, blue: 0.09803921569, alpha: 1)
            case 3:
                farLeftStar.tintColor = #colorLiteral(red: 0.9529411765, green: 0.6274509804, blue: 0.09803921569, alpha: 1)
                leftMidStar.tintColor = #colorLiteral(red: 0.9529411765, green: 0.6274509804, blue: 0.09803921569, alpha: 1)
                midStar.tintColor = #colorLiteral(red: 0.9529411765, green: 0.6274509804, blue: 0.09803921569, alpha: 1)
            case 4:
                farLeftStar.tintColor = #colorLiteral(red: 0.9529411765, green: 0.6274509804, blue: 0.09803921569, alpha: 1)
                leftMidStar.tintColor = #colorLiteral(red: 0.9529411765, green: 0.6274509804, blue: 0.09803921569, alpha: 1)
                midStar.tintColor = #colorLiteral(red: 0.9529411765, green: 0.6274509804, blue: 0.09803921569, alpha: 1)
                rightMidStar.tintColor = #colorLiteral(red: 0.9529411765, green: 0.6274509804, blue: 0.09803921569, alpha: 1)
            default:
                farLeftStar.tintColor = #colorLiteral(red: 0.9529411765, green: 0.6274509804, blue: 0.09803921569, alpha: 1)
                leftMidStar.tintColor = #colorLiteral(red: 0.9529411765, green: 0.6274509804, blue: 0.09803921569, alpha: 1)
                midStar.tintColor = #colorLiteral(red: 0.9529411765, green: 0.6274509804, blue: 0.09803921569, alpha: 1)
                rightMidStar.tintColor = #colorLiteral(red: 0.9529411765, green: 0.6274509804, blue: 0.09803921569, alpha: 1)
                farRightStar.tintColor = #colorLiteral(red: 0.9529411765, green: 0.6274509804, blue: 0.09803921569, alpha: 1)
            }
        }
    }
    
    var userId: String?

    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var uid = ""
        if let id = userId {
            uid = id
            settingsButton.isHidden = true
            profileImageViewTopConstraint.constant = 0.0
        } else {
            uid = FIRAuth.auth()!.currentUser!.uid
            bottomBarHeightConstraint.constant = tabBarController!.tabBar.frame.height
        }
        
        updateProfileInformation(with: uid)
        
        let stars: [UIImageView] = [farLeftStar, leftMidStar, midStar, rightMidStar, farRightStar]
        for star in stars {
            star.image = UIImage(named: "ProfileReviewsStar")!.withRenderingMode(.alwaysTemplate)
            star.tintColor = #colorLiteral(red: 0.7215686275, green: 0.7607843137, blue: 0.7803921569, alpha: 1)
        }
        
        numberOfReviewsLabel.text = "\(0) reviews"
        
        tableView.dataSource = self
        tableView.delegate = self
        
        closeButton.layer.borderColor = closeButton.titleLabel!.textColor.cgColor
        closeButton.layer.borderWidth = 1.0
        closeButton.roundCorners(radius: 8.0)
        
        NotificationCenter.default.addObserver(self, selector: #selector(userHasLoggedOut(notification:)), name: NSNotification.Name(rawValue: logoutNotificationKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(userHasChangedName(notification:)), name: NSNotification.Name(rawValue: nameChangeNotificationKey), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if shouldUpdateProfileOnNextView {
            updateProfileInformation(with: FIRAuth.auth()!.currentUser!.uid)
            shouldUpdateProfileOnNextView = false
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        var uid = ""
        if let id = userId {
            uid = id
        } else {
            uid = FIRAuth.auth()!.currentUser!.uid
        }
        
        if userProductsRef == nil {
            sellingProducts.removeAll()
            soldProducts.removeAll()
            
            userProductsRef = FIRDatabase.database().reference().child("user-products").child(uid)
            setupProductListeners()
        }
        if likesQuery == nil {
            likedProducts.removeAll()
            likesQuery = FIRDatabase.database().reference().child("user-likes").child(uid).queryLimited(toLast: 100)
            grabLikedPosts()
        }
        
        if selectionBar == nil {
            selectionBar = UIView()
            selectionBar!.frame = CGRect(x: sellingProductTypeButton.frame.origin.x - 4, y: self.bottomMostSeperator.frame.origin.y - 1, width: sellingProductTypeButton.frame.width + 8, height: 2)
            selectionBar!.backgroundColor = #colorLiteral(red: 0.8470588235, green: 0.337254902, blue: 0.2156862745, alpha: 1)
            selectionBar!.isUserInteractionEnabled = false
            view.addSubview(selectionBar!)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if let ref = userProductsRef {
            ref.removeAllObservers()
            userProductsRef = nil
        }
        if let ref = likesQuery {
            ref.removeAllObservers()
            likesQuery = nil
        }
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
        } else {
            cell.productImageView.alpha = 1.0
            cell.soldImageView.isHidden = true
            cell.nameLabel.alpha = 1.0
            cell.priceLabel.alpha = 1.0
            cell.simplifiedDescriptionLabel.alpha = 1.0
            cell.likeImageView.tintColor = #colorLiteral(red: 0.8470588235, green: 0.337254902, blue: 0.2156862745, alpha: 1)
            cell.likeImageView.alpha = 1.0
            cell.likeCountLabel.alpha = 1.0
            
            if let attributedText = cell.priceLabel.attributedText {
                let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: attributedText.string)
                attributeString.removeAttribute(NSStrikethroughColorAttributeName, range: NSMakeRange(0, attributeString.length))
                cell.priceLabel.attributedText = attributeString
            }
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

    @IBAction func reviewsButtonTapped(_ sender: UIButton) {
        var uid = ""
        if let id = userId {
            uid = id
        } else if let deviceUserId = FIRAuth.auth()?.currentUser?.uid {
            uid = deviceUserId
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "reviewsSummaryController") as? ReviewsSummaryViewController {
            vc.modalPresentationStyle = .overCurrentContext
            vc.userId = uid
            
            PresentationCenter.manager.present(viewController: vc, sender: self)
        }
    }
    
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
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "settingsController") as? SettingsViewController {
            vc.modalPresentationStyle = .overCurrentContext
            vc.fullName = profileNameLabel.text
            
            present(vc, animated: false, completion: nil)
        }
    }
    
    @IBAction func wantsToClose(_ sender: UIButton) {
        dismissParent()
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
    
    private func dismissParent() {
        if let parent = parent as? ProfileModalViewController {
            parent.prepareForDismissal {
                parent.dismiss(animated: false, completion: nil)
            }
        }
    }
    
    private func getUserProfile(with uid: String) {
        let ref = FIRDatabase.database().reference().child("users").child(uid).child("fullName")
        ref.observeSingleEvent(of: .value, with: { snapshot in
            if let fullName = snapshot.value as? String {
                DispatchQueue.main.async {
                    self.settingsButton.isEnabled = true
                    self.profileNameLabel.text = fullName
                }
            }
        })
    }
    
    private func grabUsersReviewStats(with uid: String) {
        let ref = FIRDatabase.database().reference().child("reviews").child(uid).child("reviewNumbers")
        ref.observeSingleEvent(of: .value, with: { snapshot in
            if let numbers = snapshot.value as? [String: Int] {
                let count = numbers["count"]!
                let number = Double(numbers["sum"]!) / Double(count)
                let roundedNumber = number.roundTo(places: 1)
                
                self.determineStarsfor(number: roundedNumber)
                
                var reviewsCountString = "\(count) reviews"
                if count == 1 {
                    reviewsCountString = "\(count) review"
                }
                
                DispatchQueue.main.async {
                    self.numberOfReviewsLabel.text = reviewsCountString
                }
            }
        })
    }
    
    private func determineStarsfor(number: Double) {
        let wholeNumber = Int(number)
        var starsToTurnOn = wholeNumber
        
        if number - Double(wholeNumber) >= 0.9 {
            starsToTurnOn += 1
        }
        
        amountOfStars = starsToTurnOn
    }
    
    private func setupProductListeners() {
        userProductsRef!.observe(.childAdded, with: { snapshot in
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
                                self.soldProducts.insert(product, at: 0)
                            } else {
                                self.sellingProducts.insert(product, at: 0)
                            }
                        } else {
                            self.sellingProducts.insert(product, at: 0)
                        }
                        
                        if self.productViewType == .selling || self.productViewType == .sold {
                            self.tableView.reloadData()
                        }
                    }
                }
            }
        })
        
        userProductsRef!.observe(.childRemoved, with: { snapshot in
            if let productDict = snapshot.value as? [String: Any] {
                if let jeepModel = JeepModel.enumFromString(string: productDict["jeepModel"] as! String) {
                    if let condition = Condition.enumFromString(string: productDict["condition"] as! String) {
                        let product = Product(withName: productDict["name"] as! String,
                                              model: jeepModel,
                                              price: productDict["price"] as! Float,
                                              condition: condition)
                        product.uid = snapshot.key
                        
                        if let isSold = productDict["isSold"] as? Bool {
                            if isSold {
                                let index = self.indexOf(product: product, in: self.soldProducts)
                                self.soldProducts.remove(at: index)
                            } else {
                                let index = self.indexOf(product: product, in: self.sellingProducts)
                                self.sellingProducts.remove(at: index)
                            }
                        } else {
                            let index = self.indexOf(product: product, in: self.sellingProducts)
                            self.sellingProducts.remove(at: index)
                        }
                        
                        if self.productViewType == .selling || self.productViewType == .sold {
                            self.tableView.reloadData()
                        }
                    }
                }
            }
        })
    }
    
    private func grabLikedPosts() {
        likesQuery!.observe(.childAdded, with: { snapshot in
            let productQuery = FIRDatabase.database().reference().child("products").child(snapshot.key)
            productQuery.observeSingleEvent(of: .value, with: { snapshot in
                if let productDict = snapshot.value as? [String: Any] {
                    if let jeepModel = JeepModel.enumFromString(string: productDict["jeepModel"] as! String) {
                        if let condition = Condition.enumFromString(string: productDict["condition"] as! String) {
                            let product = Product(withName: productDict["name"] as! String,
                                                  model: jeepModel,
                                                  price: productDict["price"] as! Float,
                                                  condition: condition)
                            product.uid = snapshot.key
                            
                            if let isSold = productDict["isSold"] as? Bool {
                                product.isSold = isSold
                            }
                            
                            self.likedProducts.insert(product, at: 0)
                            if self.productViewType == .liked {
                                self.tableView.reloadData()
                            }
                        }
                    }
                }
            })
        })
        
        likesQuery!.observe(.childRemoved, with: { snapshot in
            let productQuery = FIRDatabase.database().reference().child("products").child(snapshot.key)
            productQuery.observeSingleEvent(of: .value, with: { snapshot in
                if let productDict = snapshot.value as? [String: Any] {
                    if let jeepModel = JeepModel.enumFromString(string: productDict["jeepModel"] as! String) {
                        if let condition = Condition.enumFromString(string: productDict["condition"] as! String) {
                            let product = Product(withName: productDict["name"] as! String,
                                                  model: jeepModel,
                                                  price: productDict["price"] as! Float,
                                                  condition: condition)
                            product.uid = snapshot.key
                            
                            let index = self.indexOf(product: product, in: self.likedProducts)
                            self.likedProducts.remove(at: index)
                            
                            if self.productViewType == .liked {
                                self.tableView.reloadData()
                            }
                        }
                    }
                }
            })
        })
    }
    
    private func indexOf(product snapshot: Product, in array: [Product]) -> Int {
        var index = 0
        for product in array {
            
            if snapshot.uid == product.uid {
                return index
            }
            index += 1
        }
        return -1
    }
    
    private func updateProfileInformation(with uid: String) {
        getUserProfile(with: uid)
        grabUsersReviewStats(with: uid)
        
        previouslySelectedButton = sellingProductTypeButton
    }
    
    // MARK: - Notifications
    
    @objc private func userHasLoggedOut(notification: NSNotification) {
        shouldUpdateProfileOnNextView = true
    }
    
    @objc private func userHasChangedName(notification: NSNotification) {
        getUserProfile(with: FIRAuth.auth()!.currentUser!.uid)
    }
    
}
