//
//  AddNewProductViewController.swift
//  ThePost
//
//  Created by Andrew Robinson on 12/28/16.
//  Copyright © 2016 The Post. All rights reserved.
//

import UIKit
import AVFoundation

class AddNewProductViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDataSource,
                                   UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private enum CellType {
        case textField
        case dropDown
        case price
        case details
        case controlSwitch
    }

    @IBOutlet weak var container: UIView!
    
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var cameraAlert: UIView!
    @IBOutlet weak var cameraAlertLabel: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    
    private var tableFormat: [[String:CellType]] = []
    
    private var currentlyOpenPickerIndex = -1
    
    private var imagePicker: UIImagePickerController!
    private var storedPictures: [UIImage] = []
    
    private var disappearTimerSet = false
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorColor = #colorLiteral(red: 0.3568627451, green: 0.3568627451, blue: 0.3568627451, alpha: 0.102270344)
        tableView.dataSource = self
        tableView.delegate = self
        
        container.roundCorners(radius: 8.0)
        
        cameraAlert.alpha = 0.0
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
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
        
        UIView.animate(withDuration: 0.25, animations: {
            self.view.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.7020763423)
        })
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
        var cell: UITableViewCell
        
        let dictionary = tableFormat[indexPath.row]
        let descriptionName = Array(dictionary.keys)[0]
        let type = Array(dictionary.values)[0]
        let imageName = evaluateImageName(withDescription: descriptionName)
        
        if type == .textField || type == .price {
            let textCell = tableView.dequeueReusableCell(withIdentifier: "textCell", for: indexPath) as! NewProductTextTableViewCell
            
            if type == .price {
                textCell.sideImageView.image = UIImage(named: imageName)!.withRenderingMode(.alwaysTemplate)
                textCell.contentTextField.attributedPlaceholder = NSAttributedString(string: "$Price", attributes: [NSForegroundColorAttributeName: #colorLiteral(red: 0.137254902, green: 0.6352941176, blue: 0.3019607843, alpha: 0.5)])
                textCell.contentTextField.textColor = #colorLiteral(red: 0.137254902, green: 0.6352941176, blue: 0.3019607843, alpha: 1)
                textCell.contentTextField.keyboardType = .numberPad
            } else {
                textCell.sideImageView.image = UIImage(named: imageName)!.withRenderingMode(.alwaysTemplate)
            }
            
            textCell.sideImageView.tintColor = #colorLiteral(red: 0.9098039216, green: 0.9058823529, blue: 0.8235294118, alpha: 1)
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
            
        } else {
            cell = UITableViewCell()
        }
        
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let dictionary = tableFormat[indexPath.row]
        let type = Array(dictionary.values)[0]
        
        var height: CGFloat = 30.0
        
        if currentlyOpenPickerIndex != -1 && currentlyOpenPickerIndex == indexPath.row {
            if type == .dropDown {
                height = 216.0
            }
        }
        
        if type == .details {
            height = 216.0
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
    
    // MARK: - ImagePicker delegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            storedPictures.append(image)
            
            if cameraAlert.alpha != 0.0 {
                cameraAlert.alpha = 0.0
            }
            
            if cameraButton.isUserInteractionEnabled {
                cameraButton.isUserInteractionEnabled = false
                collectionView.delegate = self
            }
            
            collectionView.reloadData()
            collectionView.alpha = 1.0
            
            let indexPath = IndexPath(row: storedPictures.count - 1, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .right, animated: false)
        }
    }
 
    // MARK: - Actions
 
    @IBAction func wantsToAddPicture(_ sender: UIButton) {
        presentCameraOptions()
    }
    
    @IBAction func wantsToCancel(_ sender: UIButton) {
        prepareForDismissal() {
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    @IBAction func wantsToSubmit(_ sender: UIButton) {
        if storedPictures.count == 0 {
            displayCameraAlert(with: "You will need to upload at least one photo to submit your item.")
        } else {
            // Ready to submit
            
            prepareForDismissal() {
                self.dismiss(animated: false, completion: nil)
            }
        }
    }
    
    // MARK: - Helpers
    
    private func prepareForDismissal(dismissCompletion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.25, animations: {
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
        if storedPictures.count < 4 {
            
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let status = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
                
                self.imagePicker = UIImagePickerController()
                self.imagePicker.delegate = self
                self.imagePicker.sourceType = .camera
                
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
            
        } else {
            
            displayCameraAlert(with: "You may only upload 4 photos for a product.")
            if !disappearTimerSet {
                
                disappearTimerSet = true
                Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false, block: { timer in
                    self.disappearTimerSet = false
                    UIView.animate(withDuration: 0.15, animations: {
                        self.cameraAlert.frame = CGRect(x: self.cameraAlert.frame.origin.x, y: self.cameraAlert.frame.origin.y + 5, width: self.cameraAlert.frame.width, height: self.cameraAlert.frame.height)
                        self.cameraAlert.alpha = 0.0
                        self.cameraAlert.roundCorners()
                    }, completion: { done in
                        self.cameraAlert.frame = CGRect(x: self.cameraAlert.frame.origin.x, y: self.cameraAlert.frame.origin.y - 5, width: self.cameraAlert.frame.width, height: self.cameraAlert.frame.height)
                    })
                })
                
            }
        }
    }
    
    private func displayCameraAlert(with text: String) {
        if cameraAlert.alpha == 0.0 {
            cameraAlertLabel.text = text
            cameraAlert.frame = CGRect(x: cameraAlert.frame.origin.x, y: cameraAlert.frame.origin.y - 5, width: cameraAlert.frame.width, height: cameraAlert.frame.height)
            UIView.animate(withDuration: 0.15, animations: {
                self.cameraAlert.frame = CGRect(x: self.cameraAlert.frame.origin.x, y: self.cameraAlert.frame.origin.y + 5, width: self.cameraAlert.frame.width, height: self.cameraAlert.frame.height)
                self.cameraAlert.alpha = 1.0
                self.cameraAlert.roundCorners()
            })
        }
    }
    
    private func dismissCameraAlert() {
    }

}
