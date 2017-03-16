//
//  UploadSocialPostViewController.swift
//  ThePost
//
//  Created by Tyler Flowers on 3/11/17.
//  Copyright © 2017 The Post. All rights reserved.
//

import UIKit
import Firebase

class UploadSocialPostViewController: UIViewController, UIImagePickerControllerDelegate,
UINavigationControllerDelegate {
    
    @IBOutlet weak var CameraRollButton: UIButton!
    @IBOutlet weak var CameraPhotoButton: UIButton!
    @IBOutlet weak var SubmitButton: UIButton!
    @IBOutlet weak var TitleLabel: UILabel!
    @IBOutlet weak var PreviewImageView: UIImageView!
    
    @IBOutlet var photosButtons: [UIView]!
    
    var ref: FIRDatabaseReference!
    var storageRef : FIRStorageReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        ref = FIRDatabase.database().reference()
        storageRef = FIRStorage.storage().reference()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func CameraRollButtonAction(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary;
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func CameraPhotoButtonAction(_ sender: Any) {
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera;
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        updateImageViewWith(Image: chosenImage)
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func SubmitButtonAction(_ sender: Any) {
        //Send to Firebase
        
        if let userID = FIRAuth.auth()?.currentUser?.uid {
            ref.child("users").child(userID).observeSingleEvent(of: .value, with: { snapshot in
                
                if let value = snapshot.value as? NSDictionary {
                    if let fullName = value["fullName"] as? String {
                        
                        let key = self.ref.child("social-posts").childByAutoId().key
                        
                        var dbPost: [String: Any] = ["userid": userID,
                                                     "name": fullName,
                                                     "likes": [],
                                                     "datePosted": Date().timeIntervalSince1970]
                        
                        
                        // Compress stored image
                        let imageData = UIImageJPEGRepresentation(self.PreviewImageView.image!, 0.05)
                        
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
            }, withCancel: { error in
                print("Error saving new social post: \(error.localizedDescription)")
            })
        }
        
    }
    
    func updateImageViewWith(Image image: UIImage) {
        self.PreviewImageView.image = image
        
        self.TitleLabel.text = "Here's a preview of what it will look like in the feed"
        
        self.photosButtons.forEach { (view) in
            view.isHidden = true
        }
        self.SubmitButton.isHidden = false
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
