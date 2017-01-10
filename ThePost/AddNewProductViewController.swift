//
//  AddNewProductViewController.swift
//  ThePost
//
//  Created by Andrew Robinson on 12/28/16.
//  Copyright © 2016 The Post. All rights reserved.
//

import UIKit
import AVFoundation
import Firebase
import GeoFire

class AddNewProductViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate,
                                   UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, NewProductBaseTableViewCellDelegate {
    
    private enum CellType {
        case textField
        case dropDown
        case price
        case details
        case controlSwitch
    }

    @IBOutlet weak var container: UIView!
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var cameraDescriptionLabel: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    
    @IBOutlet weak var backgroundImageViewAspectRatioConstraint: NSLayoutConstraint!
    
    private var tableFormat: [[String:CellType]] = []
    
    private var currentlyOpenPickerIndex = -1
    
    private var imagePicker: UIImagePickerController!
    private var storedPictures: [UIImage] = []
    
    private var animator: UIDynamicAnimator!
    
    private var containerOriginalFrame: CGRect!
    
    private var ref: FIRDatabaseReference!
    private var storageRef: FIRStorageReference!
    private var newProduct: Product?
    
    private var geoFire: GeoFire!
    private var locationManager: CLLocationManager!
    private var lastGrabbedLocation: CLLocation?
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        geoFire = GeoFire(firebaseRef: ref.child("products-location"))
        storageRef = FIRStorage.storage().reference()
        
        locationManager = CLLocationManager()
        
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tappedOnView))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        animator = UIDynamicAnimator()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        container.roundCorners(radius: 8.0)
        container.alpha = 0.0
        
        collectionView.dataSource = self
        collectionView.alpha = 0.0
        
        cancelButton.layer.borderColor = cancelButton.titleLabel!.textColor.cgColor
        cancelButton.layer.borderWidth = 1.0
        cancelButton.roundCorners(radius: 8.0)
        
        submitButton.roundCorners(radius: 8.0)
        
        tableFormat = [["Item Name": .textField],
                       ["Make & Model": .dropDown],
                       ["Price": .price],
                       ["Condition": .dropDown],
                       ["Details (optional)": .details],
                       ["Willing to Ship Item": .controlSwitch],
                       ["Do you accept PayPal?": .controlSwitch],
                       ["Cash?": .controlSwitch]]
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        containerOriginalFrame = container.frame
        
        if container.alpha != 1.0 {
            let point = CGPoint(x: container.frame.midX, y: container.frame.midY)
            let snap = UISnapBehavior(item: container, snapTo: point)
            snap.damping = 1.0
            
            container.frame = CGRect(x: container.frame.origin.x + view.frame.width, y: -container.frame.origin.y - view.frame.height, width: container.frame.width, height: container.frame.height)
            container.alpha = 1.0
            
            animator.addBehavior(snap)
            
            UIView.animate(withDuration: 0.25, animations: {
                self.view.backgroundColor = #colorLiteral(red: 0.4705882353, green: 0.4705882353, blue: 0.4705882353, alpha: 0.7527527265)
            })
        }
    }
    
    // MARK: - CollectionView datasource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return storedPictures.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! ProductImageCollectionViewCell
        
        cell.imageView.image = storedPictures[indexPath.row]
        
        return cell
    }
    
    // MARK: - CollectionView delegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        presentCameraOptions()
    }
    
    // MARK: - TableView datasource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableFormat.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = NewProductBaseTableViewCell()
        
        let dictionary = tableFormat[indexPath.row]
        let descriptionName = Array(dictionary.keys)[0]
        let type = Array(dictionary.values)[0]
        let imageName = evaluateImageName(withDescription: descriptionName)
        
        if type == .textField || type == .price {
            let textCell = tableView.dequeueReusableCell(withIdentifier: "textCell", for: indexPath) as! NewProductTextTableViewCell
            
            if type == .price {
                textCell.sideImageView.image = UIImage(named: imageName)!.withRenderingMode(.alwaysTemplate)
                textCell.contentTextField.attributedPlaceholder = NSAttributedString(string: "$0", attributes: [NSForegroundColorAttributeName: #colorLiteral(red: 0.137254902, green: 0.6352941176, blue: 0.3019607843, alpha: 0.7040950084)])
                textCell.contentTextField.textColor = #colorLiteral(red: 0.137254902, green: 0.6352941176, blue: 0.3019607843, alpha: 1)
                textCell.contentTextField.alpha = 1.0
                textCell.contentTextField.font = UIFont(name: "Lato-Bold", size: 16)
                textCell.contentTextField.keyboardType = .numberPad
            } else {
                textCell.sideImageView.image = UIImage(named: imageName)!.withRenderingMode(.alwaysTemplate)
                textCell.contentTextField.delegate = self
            }
            
            textCell.sideImageView.tintColor = textCell.detailNameLabel.textColor
            textCell.detailNameLabel.text = descriptionName
            
            cell = textCell
        } else if type == .dropDown {
            let dropDownCell = tableView.dequeueReusableCell(withIdentifier: "dropDownCell", for: indexPath) as! NewProductDropDownTableViewCell
            
            dropDownCell.sideImageView.image = UIImage(named: imageName)!.withRenderingMode(.alwaysTemplate)
            dropDownCell.sideImageView.tintColor = #colorLiteral(red: 0.9098039216, green: 0.9058823529, blue: 0.8235294118, alpha: 1)
            dropDownCell.detailNameLabel.text = descriptionName
            
            if descriptionName == "Condition" {
                dropDownCell.pickerType = .condition
            }
            
            dropDownCell.delegate = self
            dropDownCell.setContentLabelForCurrentlySelectedRow()
                        
            cell = dropDownCell
        } else if type == .details {
            let detailCell = tableView.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath) as! NewProductDetailsTableViewCell
            
            detailCell.sideImageView.image = UIImage(named: imageName)!.withRenderingMode(.alwaysTemplate)
            detailCell.sideImageView.tintColor = #colorLiteral(red: 0.9098039216, green: 0.9058823529, blue: 0.8235294118, alpha: 1)
            detailCell.detailNameLabel.text = descriptionName
            
            cell = detailCell
        } else if type == .controlSwitch {
            let controlCell = tableView.dequeueReusableCell(withIdentifier: "controlCell", for: indexPath) as! NewProductSwitchTableViewCell
            
            controlCell.sideImageView.image = UIImage(named: imageName)!.withRenderingMode(.alwaysTemplate)
            controlCell.sideImageView.tintColor = #colorLiteral(red: 0.9098039216, green: 0.9058823529, blue: 0.8235294118, alpha: 1)
            controlCell.detailNameLabel.text = descriptionName
            
            cell = controlCell
        }
        
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let dictionary = tableFormat[indexPath.row]
        let type = Array(dictionary.values)[0]
        
        var height: CGFloat = 35.0
        
        if currentlyOpenPickerIndex != -1 && currentlyOpenPickerIndex == indexPath.row {
            if type == .dropDown {
                height = 221.0
            }
        }
        
        if type == .details {
            height = 221.0
        }
        
        return height
    }
    
    // MARK: - TableView delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        let previouslyOpenIndex = currentlyOpenPickerIndex
        
        dismissOpenPicker()
        
        if let textCell = cell as? NewProductTextTableViewCell {
            textCell.contentTextField.becomeFirstResponder()
        } else {
            view.endEditing(true)
        }
        
        if indexPath.row != previouslyOpenIndex {
            if let dropDownCell = cell as? NewProductDropDownTableViewCell {
                currentlyOpenPickerIndex = indexPath.row
                tableView.beginUpdates()
                tableView.endUpdates()
                dropDownCell.setContentLabelForCurrentlySelectedRow()
                dropDownCell.pickerView.alpha = 0.0
                UIView.animate(withDuration: 0.25, animations: {
                    dropDownCell.pickerView.alpha = 1.0
                })
            }
        }

    }
    
    // MARK: - TextField delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        let indexPath = IndexPath(row: 2, section: 0)
        if let cell = tableView.cellForRow(at: indexPath) as? NewProductTextTableViewCell {
            cell.contentTextField.becomeFirstResponder()
        }
        
        return false
    }
    
    // MARK: - ImagePicker delegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            storedPictures.append(image)
            
            if image.size.width >= image.size.height {
                backgroundImageView.removeConstraint(backgroundImageViewAspectRatioConstraint)
                backgroundImageViewAspectRatioConstraint = NSLayoutConstraint(item: backgroundImageView,
                                                                              attribute: .width,
                                                                              relatedBy: .equal,
                                                                              toItem: backgroundImageView,
                                                                              attribute: .height,
                                                                              multiplier: image.size.width / image.size.height,
                                                                              constant: 0.0)
                backgroundImageView.addConstraint(backgroundImageViewAspectRatioConstraint)
            }
            
            if cameraButton.isUserInteractionEnabled {
                cameraButton.isUserInteractionEnabled = false
                collectionView.delegate = self
            }
            
            collectionView.reloadData()
            collectionView.alpha = 1.0
            
            let indexPath = IndexPath(row: storedPictures.count - 1, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .right, animated: false)
            
            let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
            layout.itemSize = CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
            
            if storedPictures.count < 4 {
                cameraDescriptionLabel.text = "Add more Photos"
                cameraButton.setImage(#imageLiteral(resourceName: "PIPCameraPlus"), for: .normal)
            } else {
                cameraDescriptionLabel.text = ""
                cameraButton.isHidden = true
            }
        }
    }
    
    // MARK: - NewPostBaseCell delegate
    
    func valueDidChangeInCell(sender: NewProductBaseTableViewCell, value: Any?) {
        
        if newProduct == nil {
            newProduct = Product()
        }
        
        if let textCell = sender as? NewProductTextTableViewCell {
            
            if textCell.detailNameLabel.text == "Price" {
                if let price = value as? Int {
                    newProduct!.price = Float(price)
                }
            } else if textCell.detailNameLabel.text == "Item Name" {
                if let name = value as? String {
                    newProduct!.name = name
                }
            }
            
        } else if let dropDownCell = sender as? NewProductDropDownTableViewCell {
            
            if dropDownCell.pickerType == .jeep {
                if let jeepType = value as? JeepModel {
                    newProduct!.jeepModel = jeepType
                }
            } else {
                if let condition = value as? Condition {
                    newProduct!.condition = condition
                }
            }
            
        } else if let detailsCell = sender as? NewProductDetailsTableViewCell {
            
            if let hasOriginalBox = value as? Bool {
                newProduct!.originalBox = hasOriginalBox
                view.endEditing(false)
            } else if let stringValue = value as? String {
                
                if stringValue == detailsCell.releaseYearTextField.text {
                    newProduct!.releaseYear = Int(stringValue)
                } else {
                    newProduct!.detailedDescription = stringValue
                }
            }
            
        } else if let switchCell = sender as? NewProductSwitchTableViewCell {
            
            view.endEditing(false)
            if let switchIsOnOff = value as? Bool {
                if switchCell.detailNameLabel.text == "Willing to Ship Item" {
                    newProduct!.willingToShip = switchIsOnOff
                } else if switchCell.detailNameLabel.text == "Do you accept PayPal?" {
                    newProduct!.acceptsPayPal = switchIsOnOff
                } else if switchCell.detailNameLabel.text == "Cash?" {
                    newProduct!.acceptsCash = switchIsOnOff
                }
            }
            
        }
    }
    
    // MARK: - LocationManager delegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = manager.location {
            lastGrabbedLocation = location
        }
    }
 
    // MARK: - Actions
 
    @IBAction func wantsToAddPicture(_ sender: UIButton) {
        presentCameraOptions()
    }
    
    @objc private func tappedOnView() {
        view.endEditing(true)
    }
    
    @IBAction func wantsToCancel(_ sender: UIButton) {
        prepareForDismissal() {
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    @IBAction func wantsToSubmit(_ sender: UIButton) {
            
        var isReadyForSubmit = true
        
        if storedPictures.count == 0 {
            shakeView(view: cameraDescriptionLabel)
            isReadyForSubmit = false
        }
        
        for i in 0...tableFormat.count {
            let indexPath = IndexPath(row: i, section: 0)
            let cell = tableView.cellForRow(at: indexPath)
            
            if let textCell = cell as? NewProductTextTableViewCell {
                if textCell.contentTextField.text == "" || textCell.contentTextField.text == "$" {
                    textCell.sideImageView.tintColor = #colorLiteral(red: 0.8470588235, green: 0.337254902, blue: 0.2156862745, alpha: 1)
                    textCell.detailNameLabel.textColor = #colorLiteral(red: 0.8470588235, green: 0.337254902, blue: 0.2156862745, alpha: 1)
                    
                    isReadyForSubmit = false
                }
            }
        }
        
        if isReadyForSubmit {
            createNewProductListing()
            prepareForDismissal() {
                self.dismiss(animated: false, completion: nil)
            }
        }
    }
    
    // MARK: - Notifications
    
    @objc private func keyboardWillShow(_ notification: NSNotification) {
        if container.frame.origin.y == containerOriginalFrame.origin.y {
            
            var cellFrameInView: CGRect!
            
            // Find the active textfield in tableview
            for cell in tableView.visibleCells {
                if let textCell = cell as? NewProductTextTableViewCell {
                    if textCell.contentTextField.isFirstResponder {
                        cellFrameInView = view.convert(textCell.frame, from: tableView)
                        let cellIndexPath = tableView.indexPath(for: textCell)
                        tableView.scrollToRow(at: cellIndexPath!, at: .top, animated: true)
                    }
                } else if let detailsCell = cell as? NewProductDetailsTableViewCell {
                    if detailsCell.releaseYearTextField.isFirstResponder || detailsCell.descriptionTextView.isFirstResponder {
                        cellFrameInView = view.convert(detailsCell.frame, from: tableView)
                        let cellIndexPath = tableView.indexPath(for: detailsCell)
                        tableView.scrollToRow(at: cellIndexPath!, at: .top, animated: true)
                    }
                }
            }
            
            if let userInfo = notification.userInfo {
                let keyboardRect = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
                let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
                let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber
                let animationCurveRaw = animationCurveRawNSN.uintValue
                let animationCurve  = UIViewAnimationOptions(rawValue: animationCurveRaw)
                
                let keyboardOriginY = keyboardRect.origin.y
                let distanceFromCellFrame = keyboardOriginY - (cellFrameInView.origin.y + cellFrameInView.height)
                
                if distanceFromCellFrame < 0 {
                    UIView.animate(withDuration: duration, delay: 0.0, options: animationCurve, animations: {
                        self.container.frame = CGRect(x: self.container.frame.origin.x,
                                                      y: self.container.frame.origin.y + distanceFromCellFrame,
                                                      width: self.container.frame.width,
                                                      height: self.container.frame.height)
                    }, completion: nil)
                }
            }
            
        }
    }
    
    @objc private func keyboardWillHide(_ notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber
            let animationCurveRaw = animationCurveRawNSN.uintValue
            let animationCurve  = UIViewAnimationOptions(rawValue: animationCurveRaw)
            
            UIView.animate(withDuration: duration, delay: 0.0, options: animationCurve, animations: {
                self.container.frame = CGRect(x: self.container.frame.origin.x,
                                              y: self.containerOriginalFrame.origin.y,
                                              width: self.container.frame.width,
                                              height: self.container.frame.height)
            }, completion: nil)
        }
    }
    
    // MARK: - Helpers
    
    private func prepareForDismissal(dismissCompletion: @escaping () -> Void) {
        animator.removeAllBehaviors()
        
        let gravity = UIGravityBehavior(items: [container])
        gravity.gravityDirection = CGVector(dx: 0.0, dy: 9.8)
        animator.addBehavior(gravity)
        
        let item = UIDynamicItemBehavior(items: [container])
        item.addAngularVelocity(-CGFloat(M_PI_2), for: container)
        animator.addBehavior(item)
        
        UIView.animate(withDuration: 0.25, animations: {
            self.container.alpha = 0.0
            self.view.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        }, completion: { done in
            dismissCompletion()
        })
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
        case "Details (optional)":
            imageName = "PIPDetails"
        case "Willing to Ship Item":
            imageName = "PIPShip"
        case "Do you accept PayPal?":
            imageName = "PIPPayPal"
        case "Cash?":
            imageName = "PIPCash"
        default:
            imageName = "PIPItemName"
        }
        
        return imageName
    }
    
    private func dismissOpenPicker() {
        if currentlyOpenPickerIndex != -1 {
            let newPath = IndexPath(item: currentlyOpenPickerIndex, section: 0)
            currentlyOpenPickerIndex = -1
            if let openCell = tableView.cellForRow(at: newPath) as? NewProductDropDownTableViewCell {
                tableView.beginUpdates()
                tableView.endUpdates()
                UIView.animate(withDuration: 0.25, animations: {
                    openCell.pickerView.alpha = 0.0
                })
            }
        }
    }
    
    private func presentCameraOptions() {
        
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
    
    private func presentCamera(withSource type: UIImagePickerControllerSourceType) {
        
        if type == .photoLibrary || UIImagePickerController.isSourceTypeAvailable(.camera) {
            
            let status = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
            
            imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = type
            
            if status == .notDetermined {
                AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { granted in
                    if granted {
                        self.present(self.imagePicker, animated: true, completion: nil)
                    }
                })
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
    
    private func shakeView(view: UIView) {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.08
        animation.repeatCount = 2
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: view.center.x - 10, y: view.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: view.center.x + 10, y: view.center.y))
        view.layer.add(animation, forKey: "position")
    }
    
    private func createNewProductListing() {
        
        if let product = newProduct {
            if let userID = FIRAuth.auth()?.currentUser?.uid {
                ref.child("users").child(userID).observeSingleEvent(of: .value, with: { snapshot in
                    
                    if let value = snapshot.value as? NSDictionary {
                        if let fullName = value["fullName"] as? String {
                            
                            let key = self.ref.child("products").childByAutoId().key
                            var dbProduct: [String: Any] = ["owner": userID,
                                           "author": fullName,
                                           "name": product.name,
                                           "jeepModel": product.jeepModel.description,
                                           "price": product.price,
                                           "condition": product.condition.description,
                                           "originalBox": product.originalBox,
                                           "willingToShip": product.willingToShip,
                                           "acceptsPayPal": product.acceptsPayPal,
                                           "acceptsCash": product.acceptsCash]
                            
                            if let releaseYear = product.releaseYear {
                                dbProduct["releaseYear"] = releaseYear
                            }
                            if let description = product.detailedDescription {
                                dbProduct["detailedDescription"] = description
                            }
                            
                            // Compress stored images
                            var compressedImages: [Data] = []
                            for image in self.storedPictures {
                                let imageData = UIImageJPEGRepresentation(image, 0.1)
                                
                                compressedImages.append(imageData!)
                            }
                            
                            // Upload images
                            var imageOrder = 0
                            var imageDictionary: [String: String] = [:]
                            for imageData in compressedImages {
                                
                                let filePath = "products/" + key + "/\(Int(Date.timeIntervalSinceReferenceDate * 1000)).jpg"
                                let metadata = FIRStorageMetadata()
                                metadata.contentType = "image/jpeg"
                                
                                self.storageRef.child(filePath).put(imageData, metadata: metadata, completion: { metadata, error in
                                    if let error = error {
                                        print("Error uploading images: \(error.localizedDescription)")
                                    } else {
                                        
                                        // Grab image url and store in product dictionary
                                        self.storageRef.child(filePath).downloadURL() { url, error in
                                            if let error = error {
                                                print("Error getting download url: \(error.localizedDescription)")
                                            } else {
                                                if let url = url {
                                                    let stringUrl = url.absoluteString

                                                    imageOrder += 1
                                                    imageDictionary["\(imageOrder)"] = stringUrl
                                                    
                                                    if imageOrder == self.storedPictures.count {
                                                        dbProduct["images"] = imageDictionary
                                                        let productUpdates = ["/products/\(key)": dbProduct, "/user-products/\(userID)/\(key)": dbProduct]
                                                        
                                                        // Save the completed product at the very end
                                                        self.ref.updateChildValues(productUpdates) { error in
                                                            // Save location of user as current location of product
                                                            if let location = self.lastGrabbedLocation {
                                                                self.geoFire.setLocation(location, forKey: key)
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                        
                                    }
                                })
                            }
                        }
                    }
                    
                }, withCancel: { error in
                    print("Error saving new product: \(error.localizedDescription)")
                })
            }
        }
        
    }
    
    private func generateCompressedImage() {
        
    }

}
