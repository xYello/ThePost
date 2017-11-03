//
//  UploadSocialPostViewController.swift
//  ThePost
//
//  Created by Tyler Flowers on 3/11/17.
//  Copyright © 2017 XYello, Inc. All rights reserved.
//

import UIKit
import AVFoundation
import Firebase
import TOCropViewController

class UploadSocialPostViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, TOCropViewControllerDelegate {
    
    @IBOutlet weak var exButton: UIButton!


    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var previewImageView: UIImageView!

    @IBOutlet weak var editImageButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    
    private var ref: DatabaseReference!
    private var storageRef : StorageReference!
    
    private var firstLaunch = false
    private var didPickPhoto = false

    private var originalImage: UIImage?
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        storageRef = Storage.storage().reference()

        editImageButton.roundCorners(radius: 8.0)
        submitButton.roundCorners(radius: 8.0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !firstLaunch || !didPickPhoto {
            presentCameraOptions()
            firstLaunch = true
        }
    }
    
    // MARK: - Actions
    
    @IBAction func editImageButtonPressed(_ sender: UIButton) {
        if let ogImage = originalImage {
            presentCrop(withImage: ogImage)
        }
    }
    
    @IBAction func submitButtonAction(_ sender: Any) {
        UIView.animate(withDuration: 0.25, animations: {
            self.submitButton.isEnabled = false
            self.editImageButton.isEnabled = false
            self.exButton.isEnabled = false
            self.titleLabel.text = "Uploading image! Please wait..."
        })
        
        if let userID = Auth.auth().currentUser?.uid {
            let key = self.ref.child("social-posts").childByAutoId().key
            
            var dbPost: [String: Any] = ["owner": userID,
                                         "datePosted": ServerValue.timestamp()]
            
            // Compress stored image
            let imageData = UIImageJPEGRepresentation(self.previewImageView.image!, 0.1)
            
            // Upload image
            let filePath = "social-posts/" + key + "/\(Int(Date.timeIntervalSinceReferenceDate * 1000)).jpg"
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"

            storageRef.child(filePath).putData(imageData!, metadata: metadata) { metadata, error in
                if let error = error {
                    print("Error uploading images: \(error.localizedDescription)")
                    SentryManager.shared.sendEvent(withError: error)
                } else {
                    
                    // Grab image url and store in product dictionary
                    self.storageRef.child(filePath).downloadURL() { url, error in
                        if let error = error {
                            print("Error getting download url: \(error.localizedDescription)")
                            SentryManager.shared.sendEvent(withError: error)
                        } else {
                            if let url = url {
                                let stringUrl = url.absoluteString
                                
                                dbPost["image"] = stringUrl
                                
                                // Save the completed product at the very end
                                self.ref.child("social-posts").child(key).updateChildValues(dbPost)
                                self.dismiss(animated: true, completion: nil)
                            }
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func exButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Helpers
    
    private func presentCameraOptions() {
        
        let options = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let camera = UIAlertAction(title: "Take a photo", style: .default, handler: { alert in
            self.presentCamera(withSource: .camera)
        })
        
        let library = UIAlertAction(title: "Choose from library", style: .default, handler: { alert in
            self.presentCamera(withSource: .photoLibrary)
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { alert in
            self.dismiss(animated: true, completion: nil)
        })
        
        options.addAction(camera)
        options.addAction(library)
        options.addAction(cancel)
        
        present(options, animated: true, completion: nil)
    }
    
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

    func updateImage(_ image: UIImage) {
        self.previewImageView.image = image
        self.titleLabel.text = "Here's a preview of what it will look like in the feed!"
        self.submitButton.isHidden = false
        self.editImageButton.isHidden = false
    }

    private func presentCrop(withImage image: UIImage) {
        let cropVc = TOCropViewController(image: image)
        cropVc.imageCropFrame = previewImageView.frame
        cropVc.aspectRatioLockEnabled = true
        cropVc.resetAspectRatioEnabled = false
        cropVc.delegate = self

        present(cropVc, animated: true, completion: nil)
    }

    // MARK: - ImagePicker delegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        didPickPhoto = true
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        picker.dismiss(animated: true, completion: nil)

        originalImage = chosenImage
        presentCrop(withImage: chosenImage)
    }

    // MARK: - TOViewController delegate

    func cropViewController(_ cropViewController: TOCropViewController, didCropToImage image: UIImage, rect cropRect: CGRect, angle: Int) {
        updateImage(image)
        cropViewController.dismiss(animated: true, completion: nil)
    }

    func cropViewController(_ cropViewController: TOCropViewController, didFinishCancelled cancelled: Bool) {
        if cancelled {
            if let image = originalImage {
                updateImage(image)
            } else {
                presentCameraOptions()
                firstLaunch = true
            }

            cropViewController.dismiss(animated: true, completion: nil)
        }
    }
    
}
