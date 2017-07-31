//
//  ImageSelectorViewController.swift
//  The Wave
//
//  Created by Andrew Robinson on 7/29/17.
//  Copyright © 2017 XYello, Inc. All rights reserved.
//

import UIKit
import Photos
import AVFoundation

class ImageSelectorViewController: UIViewController {

    @IBOutlet weak var controlsContainer: UIView!
    @IBOutlet weak var savedImagesButton: UIButton!

    private var session: AVCaptureSession!
    fileprivate var photoOutput: AVCapturePhotoOutput!
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        savedImagesButton.setImage(nil, for: .normal)

        // Last photo setup
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]

        let result = PHAsset.fetchAssets(with: .image, options: options)
        if let asset = result.firstObject {
            PHImageManager.default().requestImage(for: asset,
                                                  targetSize: CGSize(width: 50, height: 50),
                                                  contentMode: .aspectFill,
                                                  options: nil,
                                                  resultHandler: { image, info in
                                                    DispatchQueue.main.async {
                                                        self.savedImagesButton.setImage(image, for: .normal)
                                                    }
            })
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Camera Setup
        session = AVCaptureSession()
        session.sessionPreset = AVCaptureSessionPresetPhoto

        let backCam = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        var input: AVCaptureDeviceInput?

        do {
            input =  try AVCaptureDeviceInput(device: backCam)
        } catch {
            print(error.localizedDescription)
        }

        if let input = input, session.canAddInput(input) {
            session.addInput(input)
        }

        photoOutput = AVCapturePhotoOutput()
        photoOutput.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecJPEG])], completionHandler: nil)

        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
        }

        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
        videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        videoPreviewLayer.connection?.videoOrientation = .portrait
        view.layer.addSublayer(videoPreviewLayer)
        session.startRunning()

        photoOutput.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        videoPreviewLayer.frame = view.frame
        view.bringSubview(toFront: controlsContainer)
    }

    // MARK: - Actions

    @IBAction func takeImageButtonPressed(_ sender: UIButton) {
    }

    @IBAction func savedImagesButtonPressed(_ sender: UIButton) {
    }

    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}

extension ImageSelectorViewController: AVCapturePhotoCaptureDelegate {
}
