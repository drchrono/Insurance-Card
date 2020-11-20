//
//  CameraViewController.swift
//  DRCCamera
//
//  Created by Kan Chen on 11/17/15.
//  Copyright © 2015 Kan Chen. All rights reserved.
//

import UIKit
import AVFoundation

@objc public protocol CameraViewControllerDelegate {
    @objc optional func cameraViewControllerDidClose(_ cameraViewController: CameraViewController)
    @objc func cameraViewController(_ cameraViewController: CameraViewController, didTakeImage image: UIImage?)
}

@objc open class CameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    let detectionOverlayColor = CIColor(red: 70/255, green: 140/255, blue: 215/255, alpha: 0.6)
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var overlayImageView: UIImageView!
    @objc public weak var delegate :CameraViewControllerDelegate?
    
    var captureSession:AVCaptureSession?
    var avcapturePreviewLayer: AVCaptureVideoPreviewLayer?
    private lazy var videoOutput = AVCaptureVideoDataOutput()
    private lazy var stillImageOutput = AVCaptureStillImageOutput()

    var detector:CIDetector!
    var enableDetect = true
    var lastRectFeature: CIRectangleFeature?
    
    var context: EAGLContext?
    @IBOutlet weak var maskView: CameraMaskView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var distanceBetweenPromptAndSaveButtonConstraint: NSLayoutConstraint!

    @objc open class func viewControllerFromNib() -> CameraViewController {
        let nibVC = CameraViewController(nibName: "CameraViewController", bundle: Bundle(for: CameraViewController.classForCoder()))
        return nibVC
    }

    @objc open func showCaremaIfPossible(inViewController rootViewController: UIViewController){
        if !UIImagePickerController.isCameraDeviceAvailable(UIImagePickerController.CameraDevice.rear){
            let errorMsg = "You do not have a rear camera on this device."
            let alert = UIAlertController(title: "Error", message: errorMsg, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            rootViewController.present(alert, animated: true, completion: nil)
            return
        }
        switch AVCaptureDevice.authorizationStatus(for: AVMediaType.video) {
        case .authorized:
                break
        case .denied:
            let errorMsg = "Authorization denied. \nYou can change it in Settings"
            let alert = UIAlertController(title: "Error", message: errorMsg, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            rootViewController.present(alert, animated: true, completion: nil)
            return
        case .restricted:
            return
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (success: Bool) -> Void in
                DispatchQueue.main.async {
                    if success {
                        rootViewController.present(self, animated: true, completion: nil)
                    }else{
                        return
                    }
                }
            })
            return
        @unknown default:
            break
        }
        
        rootViewController.present(self, animated: true, completion: nil)
    }
    
    var initOrientation : UIInterfaceOrientation?
    override open func viewDidLoad() {
        super.viewDidLoad()
        if UIDevice.current.userInterfaceIdiom == .pad {
            if let centerRectangleSize = CameraKitConstants.shared.rectangleRectInProtrait?.size {
                distanceBetweenPromptAndSaveButtonConstraint.constant = (centerRectangleSize.height / 2) - 32 + 8
                view.layoutIfNeeded()
            }
        }
        self.saveButton.layer.cornerRadius = 32
        self.saveButton.layer.masksToBounds = true
        self.backButton.layer.cornerRadius = 22
        self.backButton.layer.masksToBounds = true
        //iOS 10, move up 1 point to be center
        saveButton.imageEdgeInsets = UIEdgeInsets(top: -1, left: 0, bottom: 1, right: 0)
        initOrientation = UIApplication.shared.statusBarOrientation
//        let value = UIInterfaceOrientation.Portrait.rawValue
//        UIDevice.currentDevice().setValue(value, forKey: "orientation")

//        let appDelegate = UIApplication.sharedApplication()
//        let windowRect = UIScreen.mainScreen().bounds
//        previewView = UIView(frame: windowRect)
//        previewView.backgroundColor = UIColor.clearColor()
//        appDelegate.windows[0].insertSubview(pre, belowSubview: <#T##UIView#>)
        if !setupCaptureSession(){
            print("Setup Failed")
            assert(false)
        }
        detector = CIDetector(ofType: CIDetectorTypeRectangle, context: nil, options: [CIDetectorAccuracy:CIDetectorAccuracyHigh, CIDetectorMinFeatureSize: 0.15])
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        avcapturePreviewLayer!.frame = previewView.bounds
        captureSession?.startRunning()
        self.previewView.bringSubviewToFront(self.overlayImageView)
    }
    
    var lastDate = Date()
    var lastCIImage: CIImage?

    open func captureOutput(_ captureOutput: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
//        print(connection.videoOrientation.rawValue)
        let currentAVOrientaion = avcapturePreviewLayer?.connection?.videoOrientation
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        if enableDetect{
            let interval = Date().timeIntervalSince(lastDate)
            if interval < 0.1 {
//                print("dont detect now")
                return
            }
            lastCIImage = nil
            lastDate = Date()
            
            let features = detector.features(in: ciImage, options: [CIDetectorAspectRatio:1.6]) as? [CIRectangleFeature]
//            print("detected \(features?.count) features")
            if let features = features , features.count > 0 {
                self.lastRectFeature = features[0]
            }else{
                return
            }

            if let f = lastRectFeature{
                var uiImage:UIImage? = nil
                let shouldDrawOverlay: Bool
                shouldDrawOverlay = isFeatureRectInRectangle(ciImage, feature: f,orientation: currentAVOrientaion!)
                if shouldDrawOverlay {
                    let overlay = self.drawOverlay(ciImage, feature: f)
                    let context = CIContext()
                    let cgImage = context.createCGImage(overlay, from: ciImage.extent)
                    uiImage = UIImage(cgImage: cgImage!)
                    lastCIImage = ciImage
//                    print("uiimage orientation:\(uiImage!.imageOrientation.rawValue)")
//                    print(ciImage.extent)
//                    print(uiImage!.size)
                }
                DispatchQueue.main.async(execute: { () -> Void in
                    self.overlayImageView.image = uiImage
//                    self.previewView.bringSubviewToFront(self.overlayImageView)
                })

            }
        }

    }
    
    func drawOverlay(_ ciImage: CIImage , feature: CIRectangleFeature) -> CIImage{
        var overlay = CIImage(color: detectionOverlayColor)
        overlay = overlay.cropped(to: ciImage.extent)
        overlay = overlay.applyingFilter("CIPerspectiveTransformWithExtent", parameters: ["inputExtent": CIVector(cgRect: ciImage.extent),
            "inputTopLeft": CIVector(cgPoint:feature.topLeft),
            "inputTopRight":CIVector(cgPoint:feature.topRight),
            "inputBottomLeft": CIVector(cgPoint: feature.bottomLeft),
            "inputBottomRight": CIVector(cgPoint: feature.bottomRight)])
        
//        overlay = overlay.imageByCompositingOverImage(ciImage)
        return overlay
    }

    private func setupCaptureSession() -> Bool {
        captureSession = AVCaptureSession()
        captureSession!.sessionPreset = AVCaptureSession.Preset.photo
        let backCamera = AVCaptureDevice.default(for: AVMediaType.video)!
        do{
            let input = try AVCaptureDeviceInput(device: backCamera)
            if captureSession!.canAddInput(input) {
                captureSession!.addInput(input)
            }else{
                return false
            }
        }catch let error as NSError{
            print(error)
            return false
        }

        stillImageOutput.outputSettings = [AVVideoCodecKey: AVVideoCodecType.jpeg]
        if captureSession!.canAddOutput(stillImageOutput){
            captureSession!.addOutput(stillImageOutput)
        }

        let rgbOutputSettings = [kCVPixelBufferPixelFormatTypeKey as String: NSNumber(value:kCVPixelFormatType_32BGRA) ]
        videoOutput.videoSettings = rgbOutputSettings as [String : Any]
        videoOutput.alwaysDiscardsLateVideoFrames = true
        let videoDataOutputQueue = DispatchQueue(label: "videoOutputQueue", attributes: [])
        videoOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        if captureSession!.canAddOutput(videoOutput){
            captureSession!.addOutput(videoOutput)
            
            let connection = self.videoOutput.connection(with: AVMediaType.video)
            switch self.initOrientation!{
            case .portrait:
                connection?.videoOrientation = AVCaptureVideoOrientation.portrait
            case .portraitUpsideDown:
                connection?.videoOrientation = AVCaptureVideoOrientation.portraitUpsideDown
            case .landscapeLeft:
                connection?.videoOrientation = AVCaptureVideoOrientation.landscapeLeft
            case .landscapeRight:
                connection?.videoOrientation = AVCaptureVideoOrientation.landscapeRight
            case .unknown:
                break
            @unknown default:
                break
            }
            
            avcapturePreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
            avcapturePreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            self.previewView.layer.addSublayer(avcapturePreviewLayer!)
            
            return true
        }
        return false
    }
    
    @IBAction func clickedCancelButton(_ sender: AnyObject) {
        dismiss(animated: true) {
            self.delegate?.cameraViewControllerDidClose?(self)
        }
    }
    @IBAction func clickedTakeButton(_ sender: AnyObject) {
        saveButton.isEnabled = false
        if let videoConnection = stillImageOutput.connection(with: AVMediaType.video) {
            stillImageOutput.captureStillImageAsynchronously(from: videoConnection, completionHandler: { sampleBuffer, error in
                guard let sampleBuffer = sampleBuffer else {
                    print(error!)
                    return
                }
                self.captureSession?.stopRunning()
                var image: UIImage? = nil
                if let _ = self.lastCIImage{
                    image = ImageHandler.getImageCorrectedPerspectiveShrink(self.lastCIImage!, feature: self.lastRectFeature!)
                }else{
                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)!
                    let dataProvider = CGDataProvider(data: imageData as CFData)
                    let cgImageRef = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: CGColorRenderingIntent.defaultIntent)
                    let connection = self.videoOutput.connection(with: AVMediaType.video)
                    let outputOrientation = connection!.videoOrientation
                    var imageOrientation = UIImage.Orientation.right
                    switch outputOrientation{
                    case .portrait:
//                        print("portait")
                        imageOrientation = UIImage.Orientation.right
                    case .landscapeLeft:
//                        print("land left")
                        imageOrientation = UIImage.Orientation.down
                    case .landscapeRight:
//                        print("land right")
                        imageOrientation = UIImage.Orientation.up
                    case .portraitUpsideDown:
//                        print("up side")
                        imageOrientation = UIImage.Orientation.left
                    @unknown default:
                        break
                    }
//                    print(connection!.videoOrientation.rawValue)
//                    print(UIImageOrientation.Right.rawValue)
                    image = UIImage(cgImage: cgImageRef!, scale: 1.0, orientation: imageOrientation)
                    image = ImageHandler.scaleAndRotateImage(image!)
                    let rect :CGRect
//                    if outputOrientation == AVCaptureVideoOrientation.Portrait || outputOrientation == AVCaptureVideoOrientation.PortraitUpsideDown{
//                        rect = CGRectMake(image!.size.width * CameraKitConstants.RectangleRectRatio.x,
//                            image!.size.height * CameraKitConstants.RectangleRectRatio.y,
//                            image!.size.width * CameraKitConstants.RectangleRectRatio.wp,
//                            image!.size.height * CameraKitConstants.RectangleRectRatio.hp)
//                    }else{
//                        rect = CGRectMake(image!.size.width * CameraKitConstants.RectangleRectLandscapeRatio.x,
//                            image!.size.height * CameraKitConstants.RectangleRectLandscapeRatio.y,
//                            image!.size.width * CameraKitConstants.RectangleRectLandscapeRatio.wp,
//                            image!.size.height * CameraKitConstants.RectangleRectLandscapeRatio.hp)
//                    }
                    if outputOrientation == AVCaptureVideoOrientation.portrait || outputOrientation == AVCaptureVideoOrientation.portraitUpsideDown{
                        rect = CGRect(x: image!.size.width * self.rectPortraitRatio.x,
                            y: image!.size.height * self.rectPortraitRatio.y,
                            width: image!.size.width * self.rectPortraitRatio.wp,
                            height: image!.size.height * self.rectPortraitRatio.hp)
                    }else{
                        rect = CGRect(x: image!.size.width * self.rectLandscapeRatio.x,
                            y: image!.size.height * self.rectLandscapeRatio.y,
                            width: image!.size.width * self.rectLandscapeRatio.wp,
                            height: image!.size.height * self.rectLandscapeRatio.hp)
                    }

                    let imageRef = image!.cgImage!.cropping(to: rect)
                    image = UIImage(cgImage: imageRef!)
//                    let ciImage = CIImage(CGImage: cgImageRef!)
//                    let image = ImageHandler.getImageCorrectedPerspectiv(ciImage, feature: self.lastRectFeature!)
//                    print(image!.imageOrientation.rawValue)
//                    print(image!.size)
                }
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: {
                        self.delegate?.cameraViewController(self, didTakeImage: image)
                        self.saveButton.isEnabled = true
                    })
                }
            })
        }
    }

    var rectPortraitRatio: RectangleRatio{
        if UIDevice.current.userInterfaceIdiom == .phone{
            if let ratio = CameraKitConstants.shared.iphoneRectangleRatio {
                return ratio
            } else {
                return RectangleRatio()
            }
        } else {
            return CameraKitConstants.rectangleRectRatioInProtrait
        }
    }
    var rectLandscapeRatio: RectangleRatio{
        if UIDevice.current.userInterfaceIdiom == .phone{
            if let ratio = CameraKitConstants.shared.iphoneRectangleLandscapeRatio {
                return ratio
            } else {
                return RectangleRatio()
            }
        } else {
            return CameraKitConstants.rectangleRectRatioInLandscape
        }
    }
    var detectingRectRatioPortrait: RectangleRatio{
        if UIDevice.current.userInterfaceIdiom == .phone{
            if let ratio = CameraKitConstants.shared.iphoneRectangleRatio  {
                return ratio
            } else {
                return RectangleRatio()
            }
        } else {
            return CameraKitConstants.detectionRectangleRatioInProtrait
        }
    }

    var detectingRectRatioLandscape: RectangleRatio{
        if UIDevice.current.userInterfaceIdiom == .phone{
            if let ratio = CameraKitConstants.shared.iphoneRectangleLandscapeRatio {
                return ratio
            } else {
                return RectangleRatio()
            }
        } else {
            return CameraKitConstants.detectionRectangleRatioInLandscape
        }
    }

    func isFeatureRectInRectangle(_ image: CIImage, feature: CIRectangleFeature, orientation: AVCaptureVideoOrientation) -> Bool{
        let isLandscape = (orientation == .landscapeLeft || orientation == .landscapeRight)
        let leftBoundary = image.extent.width * (isLandscape ? detectingRectRatioLandscape.x : detectingRectRatioPortrait.x )
        let rightBoundary = leftBoundary + image.extent.width * (isLandscape ? detectingRectRatioLandscape.wp : detectingRectRatioPortrait.wp)
        let bottomBoundary = image.extent.height *
            (1 - (isLandscape ?
                (detectingRectRatioLandscape.y + detectingRectRatioLandscape.hp) :
                (detectingRectRatioPortrait.y + detectingRectRatioPortrait.hp)
                ))
        let topBoundary = image.extent.height * (1 - (isLandscape ? detectingRectRatioLandscape.y : detectingRectRatioPortrait.y))
        if feature.topLeft.y > topBoundary || feature.topRight.y > topBoundary{
            return false
        }
        if feature.bottomLeft.y < bottomBoundary || feature.bottomRight.y < bottomBoundary{
            return false
        }
        if feature.bottomLeft.x < leftBoundary || feature.topLeft.x < leftBoundary {
            return false
        }
        if feature.bottomRight.x > rightBoundary || feature.topRight.x > rightBoundary{
            return false
        }
        return true
    }

    /// temporary fix in iOS 10.0 and 10.1 system which CoreImage API return incorrect data.
    @available(iOS, introduced: 10.0, obsoleted: 10.2, message: "is obsoleted in iOS 10.2")
    func isFeatureRectInRectangleIOS10(_ image: CIImage, feature: CIRectangleFeature, orientation: AVCaptureVideoOrientation) -> Bool{
        let isLandscape = (orientation == .landscapeLeft || orientation == .landscapeRight)
        let leftBoundary = image.extent.width * (isLandscape ? detectingRectRatioLandscape.x : detectingRectRatioPortrait.x )
        let rightBoundary = leftBoundary + image.extent.width * (isLandscape ? detectingRectRatioLandscape.wp : detectingRectRatioPortrait.wp)
        let bottomBoundary = image.extent.height *
            (1 - (isLandscape ?
                (detectingRectRatioLandscape.y + detectingRectRatioLandscape.hp) :
                (detectingRectRatioPortrait.y + detectingRectRatioPortrait.hp)
                ))
        let topBoundary = image.extent.height * (1 - (isLandscape ? detectingRectRatioLandscape.y : detectingRectRatioPortrait.y))
        let iOS10TopLeft = feature.bottomLeft
        let iOS10TopRight = feature.topLeft
        let iOS10BottomLeft = feature.bottomRight
        let iOS10BottomRight = feature.topRight

        if iOS10TopLeft.y > topBoundary || iOS10TopRight.y > topBoundary{
            return false
        }
        if iOS10BottomLeft.y < bottomBoundary || iOS10BottomRight.y < bottomBoundary{
            return false
        }
        if iOS10BottomLeft.x < leftBoundary || iOS10TopLeft.x < leftBoundary {
            return false
        }
        if iOS10BottomRight.x > rightBoundary || iOS10TopRight.x > rightBoundary{
            return false
        }
        return true
    }

    open override var shouldAutorotate: Bool {
        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone{
            return false
        }else{
            return true
        }
    }

    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone{
            return UIInterfaceOrientationMask.portrait
        }else{
            return UIInterfaceOrientationMask.all
        }
    }
 
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let connection = self.videoOutput.connection(with: AVMediaType.video)

        switch UIApplication.shared.statusBarOrientation {
        case .portrait:
            avcapturePreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
//            connection?.videoOrientation = AVCaptureVideoOrientation.Portrait
        case .portraitUpsideDown:
            avcapturePreviewLayer?.connection?.videoOrientation = .portraitUpsideDown
//            connection?.videoOrientation = .PortraitUpsideDown
        case .landscapeLeft:
            avcapturePreviewLayer?.connection?.videoOrientation = .landscapeLeft
//            connection?.videoOrientation = .LandscapeLeft
        case .landscapeRight:
            avcapturePreviewLayer?.connection?.videoOrientation = .landscapeRight
//            connection?.videoOrientation = .LandscapeRight
        case .unknown:
            break
        @unknown default:
            break
        }
        avcapturePreviewLayer?.frame = previewView.bounds
        self.view.layoutIfNeeded()
        self.maskView.setNeedsDisplay()
        //TODO: change video orientation will cost a lot resource,
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async { () -> Void in
            switch UIApplication.shared.statusBarOrientation{
            case .portrait:
                connection?.videoOrientation = AVCaptureVideoOrientation.portrait
            case .portraitUpsideDown:
                connection?.videoOrientation = .portraitUpsideDown
            case .landscapeLeft:
                connection?.videoOrientation = .landscapeLeft
            case .landscapeRight:
                connection?.videoOrientation = .landscapeRight
            case .unknown:
                break
            @unknown default:
                break
            }
        }
    }
    
    open override var prefersStatusBarHidden: Bool {
        return true
    }
}
