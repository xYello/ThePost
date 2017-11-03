//
//  UIViewController+PhotoPermissions.swift
//  The Wave
//
//  Created by Andrew Robinson on 7/30/17.
//  Copyright © 2017 XYello, Inc. All rights reserved.
//

import AVFoundation

extension UIViewController {

    func presentCamera(withSource type: UIImagePickerControllerSourceType, delegate: UIImagePickerControllerDelegate & UINavigationControllerDelegate) {

        if type == .photoLibrary || UIImagePickerController.isSourceTypeAvailable(.camera) {

            let status = AVCaptureDevice.authorizationStatus(for: .video)

            let imagePicker = UIImagePickerController()
            imagePicker.delegate = delegate
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
    
}
