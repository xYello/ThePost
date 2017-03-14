//
//  UploadSocialPostViewController.swift
//  ThePost
//
//  Created by Tyler Flowers on 3/11/17.
//  Copyright © 2017 The Post. All rights reserved.
//

import UIKit

class UploadSocialPostViewController: UIViewController, UIImagePickerControllerDelegate,
UINavigationControllerDelegate {

    @IBOutlet weak var CameraRollButton: UIButton!
    @IBOutlet weak var CameraPhotoButton: UIButton!
    @IBOutlet weak var SubmitButton: UIButton!
    @IBOutlet weak var TitleLabel: UILabel!
    @IBOutlet weak var PreviewImageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
            imagePicker.allowsEditing = true
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
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        updateImageViewWith(Image: image)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func SubmitButtonAction(_ sender: Any) {
        //Send to Firebase
    }
    
    func updateImageViewWith(Image image: UIImage) {
        self.PreviewImageView.image = image
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
