//
//  UploadSocialPostViewController.swift
//  ThePost
//
//  Created by Tyler Flowers on 3/11/17.
//  Copyright © 2017 The Post. All rights reserved.
//

import UIKit
import AVFoundation
import Firebase

class UploadSocialPostViewController: UIViewController, UIImagePickerControllerDelegate,
UINavigationControllerDelegate {
    
    @IBOutlet weak var exButton: UIButton!
    @IBOutlet weak var SubmitButton: UIButton!
    @IBOutlet weak var TitleLabel: UILabel!
    @IBOutlet weak var PreviewImageView: UIImageView!
    
    private var ref: FIRDatabaseReference!
    private var storageRef : FIRStorageReference!
    
    private var firstLaunch = false
    private var didPickPhoto = false
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        storageRef = FIRStorage.storage().reference()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !firstLaunch || !didPickPhoto {
            presentCameraOptions()
            firstLaunch = true
        }
    }
    
    // MARK: - Actions
    
    @IBAction func SubmitButtonAction(_ sender: Any) {
        //Send to Firebase
        
        SubmitButton.isEnabled = false
        SubmitButton.isHidden = true
        exButton.isEnabled = false
        
        if let userID = FIRAuth.auth()?.currentUser?.uid {
            let key = self.ref.child("social-posts").childByAutoId().key
            
            var dbPost: [String: Any] = ["owner": userID,
                                         "datePosted": FIRServerValue.timestamp()]
            
            // Compress stored image
            let imageData = UIImageJPEGRepresentation(self.PreviewImageView.image!, 0.1)
            
            // Upload image
            let filePath = "social-posts/" + key + "/\(Int(Date.timeIntervalSinceReferenceDate * 1000)).jpg"
            let metadata = FIRStorageMetadata()
            metadata.contentType = "image/jpeg"
            
            self.storageRef.child(filePath).put(imageData!, metadata: metadata, completion: { metadata, error in
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
                                
                                dbPost["image"] = stringUrl
                                
                                // Save the completed product at the very end
                                self.ref.child("social-posts").child(key).updateChildValues(dbPost)
                                self.dismiss(animated: true, completion: nil)
                            }
                        }
                    }
                }
            })
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
            
            let status = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
            
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = type
            
            if status == .notDetermined {
                if type != .photoLibrary {
                    AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { granted in
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        didPickPhoto = true
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        updateImageViewWith(Image: chosenImage)
        dismiss(animated: true, completion: nil)
    }
    
    func updateImageViewWith(Image image: UIImage) {
        self.PreviewImageView.image = image
        self.TitleLabel.text = "Here's a preview of what it will look like in the feed!"
        self.SubmitButton.isHidden = false
    }
    
}
