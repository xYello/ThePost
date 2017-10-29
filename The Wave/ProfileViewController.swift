//
//  ProfileViewController.swift
//  ThePost
//
//  Created by Andrew Robinson on 1/6/17.
//  Copyright © 2017 XYello, Inc. All rights reserved.
//

import UIKit
import Firebase
import AVFoundation
import ReachabilitySwift

private enum BadgeStatus: String {
    case verified = "verified"
    case admin = "admin"
    case unicorn = "unicorn"
}

class ProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private enum ProductViewing {
        case selling
        case sold
        case liked
    }
    
    @IBOutlet weak var profileNameLabel: UILabel!
    @IBOutlet weak var settingsButton: UIButton!
    
    @IBOutlet weak var buildTrustView: UIView!
    @IBOutlet weak var buildTrustLabel: UILabel!
    @IBOutlet weak var buildTrustButton: UIButton!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var farLeftStar: UIImageView!
    @IBOutlet weak var leftMidStar: UIImageView!
    @IBOutlet weak var midStar: UIImageView!
    @IBOutlet weak var rightMidStar: UIImageView!
    @IBOutlet weak var farRightStar: UIImageView!

    @IBOutlet weak var numberOfReviewsLabel: UILabel!
    
    @IBOutlet weak var twitterVerifiedWithImage: UIImageView!
    @IBOutlet weak var facebookVerifiedWithImage: UIImageView!
    
    @IBOutlet weak var sellingProductTypeButton: UIButton!
    @IBOutlet weak var bottomMostSeperator: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var closeContainer: UIView!
    @IBOutlet weak var closeButton: UIButton!
    
    @IBOutlet weak var profileImageViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var profileBadge: UIImageView!
    
    private var previouslySelectedButton: UIButton!
    private var selectionBar: UIView?
    
    private var productViewType: ProductViewing = .selling {
        didSet {
            tableView.reloadData()
        }
    }

    private let reachability = Reachability()!
    
    private var sellingProducts: [Product] = []
    private var soldProducts: [Product] = []
    private var likedProducts: [Product] = []
    
    private var userProductsRef: DatabaseQuery?
    private var likesQuery: DatabaseQuery?
    private var reviewNumbersRef: DatabaseReference?
    
    private var shouldUpdateProfileOnNextView = false

    private let on = #colorLiteral(red: 0.9529411765, green: 0.6274509804, blue: 0.09803921569, alpha: 1)
    private let off = #colorLiteral(red: 0.7215686275, green: 0.7607843137, blue: 0.7803921569, alpha: 1)
    
    private var amountOfStars = 0 {
        didSet {
            switch amountOfStars {
            case 0:
                farLeftStar.tintColor = off
                leftMidStar.tintColor = off
                midStar.tintColor = off
                rightMidStar.tintColor = off
                farRightStar.tintColor = off
            case 1:
                farLeftStar.tintColor = on
                leftMidStar.tintColor = off
                midStar.tintColor = off
                rightMidStar.tintColor = off
                farRightStar.tintColor = off
            case 2:
                farLeftStar.tintColor = on
                leftMidStar.tintColor = on
                midStar.tintColor = off
                rightMidStar.tintColor = off
                farRightStar.tintColor = off
            case 3:
                farLeftStar.tintColor = on
                leftMidStar.tintColor = on
                midStar.tintColor = on
                rightMidStar.tintColor = off
                farRightStar.tintColor = off
            case 4:
                farLeftStar.tintColor = on
                leftMidStar.tintColor = on
                midStar.tintColor = on
                rightMidStar.tintColor = on
                farRightStar.tintColor = off
            default:
                farLeftStar.tintColor = on
                leftMidStar.tintColor = on
                midStar.tintColor = on
                rightMidStar.tintColor = on
                farRightStar.tintColor = on
            }
        }
    }
    
    var userId: String?

    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileImageView.roundCorners()
        profileImageView.clipsToBounds = true
        profileBadge.isHidden = true
        
        var uid = ""
        if let id = userId {
            uid = id
            settingsButton.isHidden = true
            buildTrustView.isHidden = true
            buildTrustButton.isHidden = true
            
            profileImageViewTopConstraint.constant = 0.0
        } else {
            buildTrustView.roundCorners(radius: 5.0)
            buildTrustView.clipsToBounds = true
            
            uid = Auth.auth().currentUser!.uid
            closeContainer.isHidden = true
        }
        
        updateProfileInformation(with: uid)
        
        let stars: [UIImageView] = [farLeftStar, leftMidStar, midStar, rightMidStar, farRightStar]
        for star in stars {
            star.image = UIImage(named: "ProfileReviewsStar")!.withRenderingMode(.alwaysTemplate)
            star.tintColor = off
        }
        
        numberOfReviewsLabel.text = "\(0) reviews"
        
        twitterVerifiedWithImage.image = #imageLiteral(resourceName: "twitter").withRenderingMode(.alwaysTemplate)
        twitterVerifiedWithImage.tintColor = #colorLiteral(red: 0.6078431373, green: 0.6078431373, blue: 0.6078431373, alpha: 1)
        
        facebookVerifiedWithImage.image = #imageLiteral(resourceName: "FacebookSmallRounded").withRenderingMode(.alwaysTemplate)
        facebookVerifiedWithImage.tintColor = #colorLiteral(red: 0.6078431373, green: 0.6078431373, blue: 0.6078431373, alpha: 1)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        closeButton.layer.borderColor = closeButton.titleLabel!.textColor.cgColor
        closeButton.layer.borderWidth = 1.0
        closeButton.roundCorners(radius: 8.0)
        
        NotificationCenter.default.addObserver(self, selector: #selector(userHasLoggedOut(notification:)), name: NSNotification.Name(rawValue: logoutNotificationKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(userHasChangedName(notification:)), name: NSNotification.Name(rawValue: nameChangeNotificationKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(userBuiltTrust(notification:)), name: NSNotification.Name(rawValue: buildTrustChangeNotificationKey), object: nil)
        
        previouslySelectedButton = sellingProductTypeButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if shouldUpdateProfileOnNextView {
            updateProfileInformation(with: Auth.auth().currentUser!.uid)
            shouldUpdateProfileOnNextView = false
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        var uid = ""
        if let id = userId {
            uid = id
        } else {
            uid = Auth.auth().currentUser!.uid
        }
        
        if userProductsRef == nil {
            sellingProducts.removeAll()
            soldProducts.removeAll()
            
            userProductsRef = Database.database().reference().child("products").queryOrdered(byChild: "owner").queryStarting(atValue: uid).queryEnding(atValue: uid)
            setupProductListeners()
        }
        if likesQuery == nil {
            likedProducts.removeAll()
            likesQuery = Database.database().reference().child("user-likes").child(uid).queryLimited(toLast: 100)
            grabLikedPosts()
        }
        if reviewNumbersRef == nil {
            grabUsersReviewStats(with: uid)
        }
        
        if selectionBar == nil {
            selectionBar = UIView()
            selectionBar!.frame = CGRect(x: sellingProductTypeButton.frame.origin.x - 4, y: self.bottomMostSeperator.frame.origin.y - 1, width: sellingProductTypeButton.frame.width + 8, height: 2)
            selectionBar!.backgroundColor = .waveRed
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
        if let ref = reviewNumbersRef {
            ref.removeAllObservers()
            reviewNumbersRef = nil
        }
    }
    
    // MARK: - TableView datasource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productArray().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "productListingTableCell", for: indexPath) as! ProductListingTableViewCell
        cell.selectionStyle = .none
        
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
            let truncated = String(string![..<endIndex]) // Remove the .00 from the price.
            cell.priceLabel.text = truncated
        }
        
        if product.isSold {
            cell.productImageView.alpha = 0.2
            cell.soldImageView.isHidden = false
            cell.nameLabel.alpha = 0.2
            cell.priceLabel.alpha = 0.2
            cell.simplifiedDescriptionLabel.alpha = 0.2
            cell.likeImageView.tintColor = .waveYellow
            cell.likeImageView.alpha = 0.2
            cell.likeCountLabel.alpha = 0.2
            
            let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: cell.priceLabel.text!)
            attributeString.addAttribute(NSAttributedStringKey.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
            cell.priceLabel.attributedText = attributeString
        } else {
            cell.productImageView.alpha = 1.0
            cell.soldImageView.isHidden = true
            cell.nameLabel.alpha = 1.0
            cell.priceLabel.alpha = 1.0
            cell.simplifiedDescriptionLabel.alpha = 1.0
            cell.likeImageView.tintColor = #colorLiteral(red: 0.9529411765, green: 0.6274509804, blue: 0.09803921569, alpha: 1)
            cell.likeImageView.alpha = 1.0
            cell.likeCountLabel.alpha = 1.0
            
            if let attributedText = cell.priceLabel.attributedText {
                let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: attributedText.string)
                attributeString.removeAttribute(NSAttributedStringKey.strikethroughColor, range: NSMakeRange(0, attributeString.length))
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "viewProductInfo") as? ProductViewerViewController {
            vc.modalPresentationStyle = .overCurrentContext
            
            let product = productArray()[indexPath.row]
            vc.product = product
            
            if let tabController = tabBarController {
                PresentationCenter.manager.present(viewController: vc, sender: tabController)
            } else {
                PresentationCenter.manager.present(viewController: vc, sender: self)
            }
        }
    }
    
    // MARK: - ImagePicker delegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {

            profileImageView.image = image
            
            let uid = Auth.auth().currentUser!.uid
            let storageRef = Storage.storage().reference()
            let imageData = UIImageJPEGRepresentation(image, 0.1)
            let filePath = "profilePictures/" + "\(uid).jpg"
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            
            storageRef.child(filePath).putData(imageData!, metadata: metadata, completion: { metadata, error in
                if let error = error {
                    print("Error uploading images: \(error.localizedDescription)")
                    SentryManager.shared.sendEvent(withError: error)
                } else {
                    
                    // Grab image url and store on user
                    storageRef.child(filePath).downloadURL() { url, error in
                        if let error = error {
                            print("Error getting download url: \(error.localizedDescription)")
                            SentryManager.shared.sendEvent(withError: error)
                        } else {
                            if let url = url {
                                let stringUrl = url.absoluteString
                                
                                Database.database().reference().child("users").child(uid).child("profileImage").setValue(stringUrl)
                            }
                        }
                    }
                    
                }
            })
            
        }
    }
    
    // MARK: - Actions

    @IBAction func profileImageTapped(_ sender: UIButton) {
        if userId == nil {
            let options = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let camera = UIAlertAction(title: "Take a photo", style: .default, handler: { alert in
                self.presentCamera(withSource: .camera)
            })
            
            let library = UIAlertAction(title: "Choose from library", style: .default, handler: { aler in
                self.presentCamera(withSource: .photoLibrary)
            })
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            options.addAction(camera)
            options.addAction(library)
            options.addAction(cancel)
            
            present(options, animated: true, completion: nil)
        }
    }
    
    @IBAction func reviewsButtonTapped(_ sender: UIButton) {
        var uid = ""
        if let id = userId {
            uid = id
        } else if let deviceUserId = Auth.auth().currentUser?.uid {
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
        
        if sender.titleColor(for: .normal) != .waveRed {
            sender.setTitleColor(.waveRed, for: .normal)
            previouslySelectedButton.setTitleColor(#colorLiteral(red: 0.9098039216, green: 0.9058823529, blue: 0.8235294118, alpha: 1), for: .normal)
            previouslySelectedButton = sender
            
            if sender.currentTitle == "SELLING" {
                productViewType = .selling
            } else if sender.currentTitle == "SOLD" {
                productViewType = .sold
            } else if sender.currentTitle == "FAVORITES" {
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
    
    @IBAction func buildTrustButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "buildTrustViewController") as? BuildTrustModalViewController {
            vc.modalPresentationStyle = .overCurrentContext

            present(vc, animated: false, completion: nil)
        }
    }
    
    @IBAction func wantsToClose(_ sender: UIButton) {
        dismissParent()
    }
    
    // MARK: - Helpers
    
    private func presentCamera(withSource type: UIImagePickerControllerSourceType) {
        
        if type == .photoLibrary || UIImagePickerController.isSourceTypeAvailable(.camera) {
            
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = type
            
            if status == .notDetermined {
                if type != .photoLibrary {
                    AVCaptureDevice.requestAccess(for: .video, completionHandler: { granted in
                        if granted {
                            self.present(imagePicker, animated: true, completion: nil)
                        }
                    })
                } else {
                    present(imagePicker, animated: true, completion: nil)
                }
            } else if status == .authorized {
                present(imagePicker, animated: true, completion: nil)
            } else {
                if let url = URL(string: UIApplicationOpenSettingsURLString) {
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url)
                    }
                }
            }
        }

        
    }
    
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
    
    private func grabVerifiedWithInformation(with uid: String) {
        let ref = Database.database().reference().child("users").child(uid).child("verifiedWith")
        ref.observeSingleEvent(of: .value, with: { snapshot in
            if let verified = snapshot.value as? [String: Bool] {
                let verifiedTwitter = verified["Twitter"] ?? false
                let verifiedFacebook = verified["Facebook"] ?? false
                
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.25, animations: {
                        if verifiedTwitter {
                            self.twitterVerifiedWithImage.tintColor = #colorLiteral(red: 0.4623369575, green: 0.6616973877, blue: 0.9191944003, alpha: 1)
                        } else {
                            self.twitterVerifiedWithImage.tintColor = #colorLiteral(red: 0.6078431373, green: 0.6078431373, blue: 0.6078431373, alpha: 1)
                        }
                        
                        if verifiedFacebook {
                            self.facebookVerifiedWithImage.tintColor = #colorLiteral(red: 0.2784313725, green: 0.3490196078, blue: 0.5764705882, alpha: 1)
                        } else {
                            self.facebookVerifiedWithImage.tintColor = #colorLiteral(red: 0.6078431373, green: 0.6078431373, blue: 0.6078431373, alpha: 1)
                        }
                    })
                }
            } else {
                self.twitterVerifiedWithImage.tintColor = #colorLiteral(red: 0.6078431373, green: 0.6078431373, blue: 0.6078431373, alpha: 1)
                self.facebookVerifiedWithImage.tintColor = #colorLiteral(red: 0.6078431373, green: 0.6078431373, blue: 0.6078431373, alpha: 1)
            }
        })
    }
    
    private func grabProfileImage(with uid: String) {
        let ref = Database.database().reference().child("users").child(uid).child("profileImage")
        ref.observeSingleEvent(of: .value, with: { snapshot in
            if let urlString = snapshot.value as? String {
                let url = URL(string: urlString)
                self.profileImageView.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "DefaultProfilePicture"))
            } else {
                self.profileImageView.image = #imageLiteral(resourceName: "DefaultProfilePicture")
            }
        })
    }
    
    private func getUserProfile(with uid: String) {
        let ref = Database.database().reference().child("users").child(uid).child("fullName")
        ref.observeSingleEvent(of: .value, with: { snapshot in
            if let fullName = snapshot.value as? String {
                DispatchQueue.main.async {
                    self.settingsButton.isEnabled = true
                    self.profileNameLabel.text = fullName
                }
            }
        })
    }

    fileprivate func updateReviewCounts(with snapshot: DataSnapshot) {
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
    }

    private func grabUsersReviewStats(with uid: String) {
        reviewNumbersRef = Database.database().reference().child("reviews").child(uid)
        reviewNumbersRef!.child("reviewNumbers").observeSingleEvent(of: .value, with: { snapshot in
            self.updateReviewCounts(with: snapshot)
        })

        reviewNumbersRef!.observe(.childChanged, with: { snapshot in
            self.updateReviewCounts(with: snapshot)
        })
    }

    private func grabUserBadgeState(with uid: String) {
        let ref = Database.database().reference().child("users").child(uid).child("badge")
        ref.observeSingleEvent(of: .value, with: { snapshot in
            if let stateString = snapshot.value as? String {
                if let state = BadgeStatus(rawValue: stateString) {
                    self.profileBadge.isHidden = false

                    switch state {
                    case .verified:
                        self.profileBadge.image = #imageLiteral(resourceName: "VerifiedBadge")
                    case .admin:
                        self.profileBadge.image = #imageLiteral(resourceName: "AdminBadge")
                    case .unicorn:
                        self.profileBadge.image = #imageLiteral(resourceName: "AndrewBadge")
                    }
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
            if let productDict = snapshot.value as? [String: AnyObject] {
                if let product = Product.createProduct(with: productDict, with: snapshot.key) {
                    
                    if product.isSold {
                        self.soldProducts.insert(product, at: 0)
                    } else {
                        self.sellingProducts.insert(product, at: 0)
                    }
                    
                    if self.productViewType == .selling || self.productViewType == .sold {
                        self.tableView.reloadData()
                    }
                    
                }
            }
        })
        
        userProductsRef!.observe(.childRemoved, with: { snapshot in
            if let productDict = snapshot.value as? [String: AnyObject] {
                if let product = Product.createProduct(with: productDict, with: snapshot.key) {
                    
                    if product.isSold {
                        let index = self.indexOf(product: product, in: self.soldProducts)
                        self.soldProducts.remove(at: index)
                    } else {
                        let index = self.indexOf(product: product, in: self.sellingProducts)
                        self.sellingProducts.remove(at: index)
                    }
                    
                    if self.productViewType == .selling || self.productViewType == .sold {
                        self.tableView.reloadData()
                    }
                }
            }
        })
    }
    
    private func grabLikedPosts() {
        likesQuery!.observe(.childAdded, with: { snapshot in
            let productQuery = Database.database().reference().child("products").child(snapshot.key)
            productQuery.observeSingleEvent(of: .value, with: { snapshot in
                if let productDict = snapshot.value as? [String: AnyObject] {
                    if let product = Product.createProduct(with: productDict, with: snapshot.key) {
                        self.likedProducts.insert(product, at: 0)
                        if self.productViewType == .liked {
                            self.tableView.reloadData()
                        }
                    }
                }
            })
        })
        
        likesQuery!.observe(.childRemoved, with: { snapshot in
            let productQuery = Database.database().reference().child("products").child(snapshot.key)
            productQuery.observeSingleEvent(of: .value, with: { snapshot in
                if let productDict = snapshot.value as? [String: AnyObject] {
                    if let product = Product.createProduct(with: productDict, with: snapshot.key) {
                        let index = self.indexOf(product: product, in: self.likedProducts)
                        self.likedProducts.remove(at: index)
                        
                        if self.productViewType == .liked {
                            self.tableView.reloadData()
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
        if reachability.isReachable {
            grabVerifiedWithInformation(with: uid)
            getUserProfile(with: uid)
            grabUsersReviewStats(with: uid)
            grabProfileImage(with: uid)
            grabUserBadgeState(with: uid)

            userBuiltTrust(notification: nil)
        } else {
            reachability.whenReachable = { reachability in
                self.grabVerifiedWithInformation(with: uid)
                self.getUserProfile(with: uid)
                self.grabUsersReviewStats(with: uid)
                self.grabProfileImage(with: uid)
                self.grabUserBadgeState(with: uid)

                self.userBuiltTrust(notification: nil)
            }
            do { try reachability.startNotifier() } catch {
                SentryManager.shared.sendEvent(withMessage: "Reachability has failed to initiazlied its notifications!")
            }
        }
    }
    
    // MARK: - Notifications
    
    @objc private func userHasLoggedOut(notification: NSNotification) {
        shouldUpdateProfileOnNextView = true
    }
    
    @objc private func userHasChangedName(notification: NSNotification) {
        getUserProfile(with: Auth.auth().currentUser!.uid)
    }
    
    @objc private func userBuiltTrust(notification: NSNotification?) {
        if let user = Auth.auth().currentUser {
            if !buildTrustView.isHidden {
                grabVerifiedWithInformation(with: user.uid)
                
                var hasFacebook = false
                var hasTwitter = false
                
                for provider in user.providerData {
                    if provider.providerID == "facebook.com" {
                        hasFacebook = true
                    } else if provider.providerID == "twitter.com" {
                        hasTwitter = true
                    }
                }
                
                if hasFacebook && hasTwitter {
                    buildTrustView.backgroundColor = .waveGreen
                    buildTrustLabel.text = "Trust Built"
                    buildTrustButton.isEnabled = false
                } else {
                    buildTrustView.backgroundColor = .waveRed
                    buildTrustLabel.text = "Build Trust"
                    buildTrustButton.isEnabled = true
                }
            }
        }
    }
    
}
