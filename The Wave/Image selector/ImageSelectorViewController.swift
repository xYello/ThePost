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
import TOCropViewController

// This class is to be subclassed by view controllers that take this view controller's selected image.
protocol ImageSelectorClose {
    func dismiss()
}

class SeletectedImageViewController: UIViewController {
    var image: UIImage!
    var handler: ImageSelectorClose!

    func present(fromVc: UIViewController, withDismissHandler handler: ImageSelectorClose) {
        self.handler = handler

        let nav = UINavigationController(rootViewController: self)
        nav.isNavigationBarHidden = true
        nav.modalPresentationStyle = .overCurrentContext
        fromVc.present(nav, animated: true, completion: nil)
    }
}

class ImageSelectorViewController: UIViewController, ImageSelectorClose {

    fileprivate enum CameraState {
        case takingImage
        case tookImage
        case choseImageFromPicker
    }

    @IBOutlet weak var photoPreviewImageView: UIImageView!
    @IBOutlet weak var controlsContainer: UIView!
    @IBOutlet weak var pictureTakeButton: UIButton!
    @IBOutlet weak var savedImagesButton: UIButton!
    @IBOutlet weak var uploadPictureButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!

    private var vcToPresent: SeletectedImageViewController?
    private var dismissHandler: ((UIImage?) -> ())?
    private var prefilledImage: UIImage?
    
    private var session: AVCaptureSession!
    fileprivate var photoOutput: AVCapturePhotoOutput!
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer!

    fileprivate var state: CameraState! {
        didSet {
            if state == .takingImage {
                photoPreviewImageView.contentMode = .scaleAspectFill
                photoPreviewImageView.isHidden = true

                cancelButton.setTitle("Cancel", for: .normal)

                pictureTakeButton.isHidden = false
                savedImagesButton.isHidden = false
                uploadPictureButton.isHidden = true
            } else {
                photoPreviewImageView.isHidden = false
                cancelButton.setTitle(state == .tookImage ? "Retake" : "Rechoose", for: .normal)
                pictureTakeButton.isHidden = true
                savedImagesButton.isHidden = true
                uploadPictureButton.isHidden = false
            }
        }
    }

    // MARK: - Init

    init(vcToPresentAfterUpload vc: SeletectedImageViewController) {
        vcToPresent = vc
        super.init(nibName: nil, bundle: nil)
    }

    init(prefilledImage: UIImage? = nil, dismissHandler: @escaping ((UIImage?) -> ())) {
        self.dismissHandler = dismissHandler
        self.prefilledImage = prefilledImage
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        state = .takingImage
        savedImagesButton.setImage(nil, for: .normal)

        if let image = prefilledImage {
            photoPreviewImageView.contentMode = .scaleAspectFit
            photoPreviewImageView.image = image
            state = .tookImage

            uploadPictureButton.setTitle("Finish", for: .normal)
        }

        PHPhotoLibrary.requestAuthorization() { status in
            if status == .authorized {
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
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        #if !(IOS_SIMULATOR)
        // Camera Setup
        session = AVCaptureSession()
        session.sessionPreset = AVCaptureSession.Preset.photo

        let backCam = AVCaptureDevice.default(for: .video)
        var input: AVCaptureDeviceInput?

        do {
            input =  try AVCaptureDeviceInput(device: backCam!)
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
        videoPreviewLayer.videoGravity = .resizeAspectFill
        videoPreviewLayer.connection?.videoOrientation = .portrait
        view.layer.addSublayer(videoPreviewLayer)
        session.startRunning()
        #endif
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        #if !(IOS_SIMULATOR)
        videoPreviewLayer.frame = view.frame
        #endif

        view.bringSubview(toFront: photoPreviewImageView)
        view.bringSubview(toFront: controlsContainer)
    }

    // MARK: - Actions

    @IBAction func takeImageButtonPressed(_ sender: UIButton) {
        #if !(IOS_SIMULATOR)
        photoOutput.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
        #endif
    }

    @IBAction func savedImagesButtonPressed(_ sender: UIButton) {
        presentCamera(withSource: .photoLibrary, delegate: self)
    }

    @IBAction func uploadPicture(_ sender: UIButton) {
        if photoPreviewImageView.contentMode == .scaleAspectFill {
            if let image = photoPreviewImageView.image {
                presentCropController(withImage: image)
            }
        } else {
            controlsContainer.isHidden = true

            if let vc = vcToPresent {
                vc.image = photoPreviewImageView.image
                vc.present(fromVc: self, withDismissHandler: self)
            } else {
                dismissHandler?(photoPreviewImageView.image)
                dismiss(animated: true, completion: nil)
            }
        }
    }

    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        if state == .takingImage {
            dismiss(animated: true, completion: nil)
        } else {
            state = .takingImage
        }
    }

    // MARK: - Helpers

    fileprivate func captured(image: UIImage?, error: Error?) {
        if let error = error {
            SentryManager.shared.sendEvent(withError: error)
        } else if let image = image {
            state = .tookImage
            DispatchQueue.main.async {
                self.photoPreviewImageView.image = image
            }
        }
    }

    fileprivate func presentCropController(withImage image: UIImage) {
        let cropVc = TOCropViewController(image: image)
        cropVc.imageCropFrame = CGRect(x: 0, y: 0, width: 343, height: 257)
        cropVc.aspectRatioLockEnabled = true
        cropVc.resetAspectRatioEnabled = false
        cropVc.delegate = self

        present(cropVc, animated: true, completion: nil)
    }

    // MARK: - ImageSelectorClose protocol

    func dismiss() {
        vcToPresent?.navigationController?.dismiss(animated: true, completion: {
            self.dismiss(animated: true, completion: nil)
        })
    }
}

extension ImageSelectorViewController: AVCapturePhotoCaptureDelegate {

    func photoOutput(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        if let buffer = photoSampleBuffer, let data = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: buffer, previewPhotoSampleBuffer: nil), let image = UIImage(data: data) {
            captured(image: image, error: nil)
        } else if let error = error {
            captured(image: nil, error: error)
        }
    }

    @available(iOS 11.0, *)
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let data = photo.fileDataRepresentation() {
            captured(image: UIImage(data: data), error: nil)
        } else {
            captured(image: nil, error: error)
        }
    }

}

extension ImageSelectorViewController: TOCropViewControllerDelegate {

    func cropViewController(_ cropViewController: TOCropViewController, didCropToImage image: UIImage, rect cropRect: CGRect, angle: Int) {
        cropViewController.dismiss(animated: true, completion: nil)
        
        photoPreviewImageView.contentMode = .scaleAspectFit
        photoPreviewImageView.image = image
    }

    func cropViewController(_ cropViewController: TOCropViewController, didFinishCancelled cancelled: Bool) {
        if cancelled {
            cropViewController.dismiss(animated: true, completion: nil)
            state = .takingImage
        }
    }

}

extension ImageSelectorViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        picker.dismiss(animated: true, completion: nil)

        state = .choseImageFromPicker
        presentCropController(withImage: chosenImage)
    }

}
