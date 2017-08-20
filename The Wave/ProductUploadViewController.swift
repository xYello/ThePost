//
//  ProductUploadViewController.swift
//  The Wave
//
//  Created by Andrew Robinson on 8/16/17.
//  Copyright © 2017 XYello, Inc. All rights reserved.
//

import UIKit
import Firebase
import ReachabilitySwift
import WVCheckMark

class ProductUploadViewController: SeletectedImageViewController {

    @IBOutlet weak var check: WVCheckMark!
    
    @IBOutlet weak var statusLabel: UILabel!

    @IBOutlet weak var mainButton: BigRedShadowButton!
    @IBOutlet weak var secondaryButton: UIButton!

    @IBOutlet weak var successView: UIView!
    @IBOutlet weak var linkButton: UIButton!
    @IBOutlet weak var linkInfoLabel: UILabel!
    
    private var product: Product
    private var dbProduct = [String: Any]()

    private let productRef = FIRDatabase.database().reference().child("products")
    private var productKey: String!

    private var didHaveError = false {
        didSet {
            if didHaveError {
                check.setColor(color: #colorLiteral(red: 0.6392156863, green: 0.2980392157, blue: 0.2235294118, alpha: 1).cgColor)
                check.startX()

                statusLabel.text = "Error uploading product 😕"
                mainButton.isHidden = false
                mainButton.setTitle("Retry?", for: .normal)
                secondaryButton.isHidden = false
            } else {
                statusLabel.text = "Trying again..."
                mainButton.isHidden = true
                mainButton.setTitle("View Listing", for: .normal)
                secondaryButton.isHidden = true
            }
        }
    }

    // MARK: - Init

    init(withProduct product: Product) {
        self.product = product
        super.init(nibName: nil, bundle: nil)

        productKey = productRef.childByAutoId().key
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mainButton.isHidden = true
        successView.isHidden = true
        secondaryButton.isHidden = true

        linkButton.setTitle(WebsiteLinks.products + productKey, for: .normal)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startUpload()
    }

    // MARK: - Actions

    @IBAction func viewListingPressed(_ sender: BigRedShadowButton) {
        if didHaveError {
            didHaveError = false
            startUpload()
        } else {
            handler.dismiss()
        }
    }

    @IBAction func secondaryButtonPressed(_ sender: UIButton) {
        handler.dismiss()
    }

    @IBAction func linkButtonPressed(_ sender: UIButton) {
        UIPasteboard.general.string = WebsiteLinks.products + productKey
        linkInfoLabel.text = "Copied!"
        linkInfoLabel.textColor = #colorLiteral(red: 0.4078431373, green: 0.7490196078, blue: 0.4823529412, alpha: 1)
    }

    // MARK: - Upload

    private func startUpload() {let reach = Reachability()!
        if reach.currentReachabilityStatus == .notReachable {
            didHaveError = true
        } else {
            if let userId = FIRAuth.auth()?.currentUser?.uid {
                uploadImages(withUserId: userId)
            } else {
                SentryManager.shared.sendEvent(withMessage: "Product upload: Firebase current user does not exist!")
            }
        }
    }

    private func uploadImages(withUserId userId: String) {
        var compressed = [Data]()
        for image in product.images {
            let imageData = UIImageJPEGRepresentation(image, 0.1)
            compressed.append(imageData!)
        }

        var imageDict = [String: String]()

        let ref = FIRStorage.storage().reference().child("products").child(productKey)
        let metadata = FIRStorageMetadata()
        metadata.contentType = "image/jpeg"

        for i in 1...product.images.count {
            imageDict["\(i)"] = ""
        }

        for (index, _) in imageDict {
            if !self.didHaveError {
                ref.child("\(index)").put(compressed[Int(index)! - 1], metadata: metadata, completion: { metadata, error in
                    if let error = error {
                        SentryManager.shared.sendEvent(withError: error)
                        self.didHaveError = true
                        return
                    } else {
                        ref.child("\(index)").downloadURL() { url, error in
                            if let error = error {
                                SentryManager.shared.sendEvent(withError: error)
                                self.didHaveError = true
                                return
                            } else if let url = url {
                                imageDict[index] = url.absoluteString
                                self.dbProduct["images"] = imageDict

                                // Create the entire product if all images have bene uploaded.
                                var isFinished = true
                                for (_, value) in imageDict {
                                    if value == "" {
                                        isFinished = false
                                    }
                                }
                                if isFinished {
                                    self.createNewProduct(withUserId: userId)
                                }
                            } else {
                                SentryManager.shared.sendEvent(withMessage: "Uploading images: URL does not exist!")
                                self.didHaveError = true
                                return
                            }
                        }
                    }
                })
            }
        }
    }

    private func createNewProduct(withUserId userId: String) {
        if !didHaveError {
            dbProduct["owner"] = userId
            dbProduct["name"] = product.name
            dbProduct["jeepModel"] = product.jeepModel.name
            dbProduct["isSold"] = false
            dbProduct["soldModel"] = "SELLING" + product.jeepModel.name
            dbProduct["price"] = product.price
            dbProduct["willingToShip"] = product.willingToShip
            dbProduct["acceptsPayPal"] = product.acceptsPayPal
            dbProduct["acceptsCash"] = product.acceptsCash
            dbProduct["likeCount"] = 0
            dbProduct["viewCount"] = 0
            dbProduct["datePosted"] = FIRServerValue.timestamp()

            if let description = product.detailedDescription {
                dbProduct["detailedDescription"] = description
            }

            // These are dummies, otherwise lower app versions would crash.
            dbProduct["condition"] = Condition.other.description
            dbProduct["originalBox"] = false

            productRef.child(productKey).updateChildValues(dbProduct, withCompletionBlock: { error, ref in
                if let _ = error {
                    self.didHaveError = true
                } else {
                    self.check.setColor(color: #colorLiteral(red: 0.4078431373, green: 0.7490196078, blue: 0.4823529412, alpha: 1).cgColor)
                    self.check.start()

                    self.statusLabel.text = "🎉 Upload completed! 🎉"
                    self.mainButton.isHidden = false
                    self.successView.isHidden = false
                }
            })
        }
    }

}
