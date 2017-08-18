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

class ProductUploadViewController: SeletectedImageViewController {

    @IBOutlet weak var statusLabel: UILabel!

    private var product: Product
    private var dbProduct = [String: Any]()

    private let productRef = FIRDatabase.database().reference().child("products")
    private var productKey: String!

    private var didHaveError = false {
        didSet {
            if didHaveError {
                // TODO: Display error message.
                statusLabel.text = "Error uploading product!"
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

        let reach = Reachability()!
        if reach.currentReachabilityStatus == .notReachable {
            didHaveError = true
        } else {
            startUpload()
        }
    }

    // MARK: - Upload

    private func startUpload() {
        if let userId = FIRAuth.auth()?.currentUser?.uid {
            uploadImages(withUserId: userId)
        } else {
            SentryManager.shared.sendEvent(withMessage: "Product upload: Firebase current user does not exist!")
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

            productRef.child(productKey).updateChildValues(dbProduct)

            // TODO: Update with success, and URLs.
            handler.dismiss()
        }
    }

}
