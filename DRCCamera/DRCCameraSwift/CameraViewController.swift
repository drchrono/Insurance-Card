//
//  CameraViewController.swift
//  DRCCamera
//
//  Created by Kan Chen on 11/17/15.
//  Copyright © 2015 Kan Chen. All rights reserved.
//

import UIKit
import AVFoundation
import GLKit

@objc public protocol CameraViewControllerDelegate{
    @objc optional func cameraViewControllerDidClose(_ cameraViewController: CameraViewController)
    func cameraViewController(_ cameraViewController: CameraViewController, didTakeImage image: UIImage?)
}

open class CameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    let detectionOverlayColor = CIColor(red: 70/255, green: 140/255, blue: 215/255, alpha: 0.6)
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var overlayImageView: UIImageView!
    open weak var delegate :CameraViewControllerDelegate?
    
    var captureSession:AVCaptureSession?
    var avcapturePreviewLayer: AVCaptureVideoPreviewLayer?
    var videoOutput:AVCaptureVideoDataOutput?
    var stillImageOutput:AVCaptureStillImageOutput?

    var detector:CIDetector!
    var enableDetect = true
    var lastRectFeature: CIRectangleFeature?
    
    var context: EAGLContext?
    @IBOutlet weak var maskView: CameraMaskView!
    @IBOutlet weak var SaveButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var distanceBetweenPromptAndSaveButtonConstraint: NSLayoutConstraint!

    open class func ViewControllerFromNib() -> CameraViewController{
        let nibVC = CameraViewController(nibName: "CameraViewController", bundle: Bundle(for: CameraViewController.classForCoder()))
        return nibVC
    }

    open func showCaremaIfPossible(inViewController rootViewController: UIViewController){
        if !UIImagePickerController.isCameraDeviceAvailable(UIImagePickerControllerCameraDevice.rear){
            let errorMsg = "You do not have a rear camera on this device."
            let alert = UIAlertController(title: "Error", message: errorMsg, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            rootViewController.present(alert, animated: true, completion: nil)
            return
        }
        switch AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo){
        case .authorized:
                break
        case .denied:
            let errorMsg = "Authorization denied. \nYou can change it in Settings"
            let alert = UIAlertController(title: "Error", message: errorMsg, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            rootViewController.present(alert, animated: true, completion: nil)
            return
        case .restricted:
            return
        case .notDetermined:
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { (success:Bool) -> Void in
                DispatchQueue.main.async {
                    if success {
                        rootViewController.present(self, animated: true, completion: nil)
                    }else{
                        return
                    }
                }
            })
            return
        }
        
        rootViewController.present(self, animated: true, completion: nil)
    }
    
    var initOrientation : UIInterfaceOrientation?
    override open func viewDidLoad() {
        super.viewDidLoad()
        if UIDevice.current.userInterfaceIdiom == .pad {
            if let centerRectangleSize = CameraKitConstants.singleton.RectangleRectProtrait?.size {
                distanceBetweenPromptAndSaveButtonConstraint.constant = (centerRectangleSize.height / 2) - 32 + 8
                view.layoutIfNeeded()
            }
        }
        self.SaveButton.layer.cornerRadius = 32
        self.SaveButton.layer.masksToBounds = true
        self.backButton.layer.cornerRadius = 22
        self.backButton.layer.masksToBounds = true
        //iOS 10, move up 1 point to be center
        SaveButton.imageEdgeInsets = UIEdgeInsets(top: -1, left: 0, bottom: 1, right: 0)
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
        self.previewView.bringSubview(toFront: self.overlayImageView)

    }
    var lastDate = Date()
    var lastCIImage: CIImage?

    open func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
//        print(connection.videoOrientation.rawValue)
        let currentAVOrientaion = avcapturePreviewLayer?.connection.videoOrientation
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
                if isFeatureRectInRectangle(ciImage, feature: f,orientation: currentAVOrientaion!){
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
        overlay = overlay.cropping(to: ciImage.extent)
        overlay = overlay.applyingFilter("CIPerspectiveTransformWithExtent", withInputParameters: ["inputExtent": CIVector(cgRect: ciImage.extent),
            "inputTopLeft": CIVector(cgPoint:feature.topLeft),
            "inputTopRight":CIVector(cgPoint:feature.topRight),
            "inputBottomLeft": CIVector(cgPoint: feature.bottomLeft),
            "inputBottomRight": CIVector(cgPoint: feature.bottomRight)])
        
//        overlay = overlay.imageByCompositingOverImage(ciImage)
        return overlay
    }

    func setupCaptureSession() -> Bool{
        captureSession = AVCaptureSession()
        captureSession!.sessionPreset = AVCaptureSessionPresetPhoto
        let backCamera = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
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
        stillImageOutput = AVCaptureStillImageOutput()
        stillImageOutput!.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
        if captureSession!.canAddOutput(stillImageOutput){
            captureSession!.addOutput(stillImageOutput)
        }
        
        videoOutput = AVCaptureVideoDataOutput()
        let rgbOutputSettings = [kCVPixelBufferPixelFormatTypeKey as NSString: NSNumber(value:kCVPixelFormatType_32BGRA) ]
        videoOutput?.videoSettings = rgbOutputSettings
        videoOutput?.alwaysDiscardsLateVideoFrames = true
        let videoDataOutputQueue = DispatchQueue(label: "videoOutputQueue", attributes: [])
        videoOutput?.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        if captureSession!.canAddOutput(videoOutput){
            captureSession!.addOutput(videoOutput)
            
            let connection = self.videoOutput?.connection(withMediaType: AVMediaTypeVideo)
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
            }
            
            avcapturePreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
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
        SaveButton.isEnabled = false
        if let videoConnection = stillImageOutput!.connection(withMediaType: AVMediaTypeVideo) {
            stillImageOutput?.captureStillImageAsynchronously(from: videoConnection, completionHandler: { sampleBuffer, error in
                guard let sampleBuffer = sampleBuffer else {
                    print(error)
                    return
                }
                self.captureSession?.stopRunning()
                var image: UIImage? = nil
                if let _ = self.lastCIImage{
//                    image = ImageHandler.getImageCorrectedPerspectiv(self.lastCIImage!, feature: self.lastRectFeature!)
                    image = ImageHandler.getImageCorrectedPerspectiveShrink(self.lastCIImage!, feature: self.lastRectFeature!)
                }else{
                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer) as NSData
                    let dataProvider = CGDataProvider(data: imageData as CFData)
                    let cgImageRef = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: CGColorRenderingIntent.defaultIntent)
                    let connection = self.videoOutput?.connection(withMediaType: AVMediaTypeVideo)
                    let outputOrientation = connection!.videoOrientation
                    var imageOrientation = UIImageOrientation.right
                    switch outputOrientation{
                    case .portrait:
//                        print("portait")
                        imageOrientation = UIImageOrientation.right
                    case .landscapeLeft:
//                        print("land left")
                        imageOrientation = UIImageOrientation.down
                    case .landscapeRight:
//                        print("land right")
                        imageOrientation = UIImageOrientation.up
                    case .portraitUpsideDown:
//                        print("up side")
                        imageOrientation = UIImageOrientation.left
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
                        rect = CGRect(x: image!.size.width * self.RectPortraitRatio.x,
                            y: image!.size.height * self.RectPortraitRatio.y,
                            width: image!.size.width * self.RectPortraitRatio.wp,
                            height: image!.size.height * self.RectPortraitRatio.hp)
                    }else{
                        rect = CGRect(x: image!.size.width * self.RectLandscapeRatio.x,
                            y: image!.size.height * self.RectLandscapeRatio.y,
                            width: image!.size.width * self.RectLandscapeRatio.wp,
                            height: image!.size.height * self.RectLandscapeRatio.hp)
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
                        self.SaveButton.isEnabled = true
                    })
                }
            })
        }
    }

    var RectPortraitRatio: RectangleRatio{
        if UIDevice.current.userInterfaceIdiom == .phone{
            if let ratio = CameraKitConstants.singleton.iphoneRectangleRatio {
                return ratio
            } else {
                return RectangleRatio()
            }
        } else {
            return CameraKitConstants.RectangleRectRatio
        }
    }
    var RectLandscapeRatio: RectangleRatio{
        if UIDevice.current.userInterfaceIdiom == .phone{
            if let ratio = CameraKitConstants.singleton.iphoneRectangleLandscapeRatio {
                return ratio
            } else {
                return RectangleRatio()
            }
        } else {
            return CameraKitConstants.RectangleRectLandscapeRatio
        }
    }
    var detectingRectRatioPortrait: RectangleRatio{
        if UIDevice.current.userInterfaceIdiom == .phone{
            if let ratio = CameraKitConstants.singleton.iphoneRectangleRatio  {
                return ratio
            } else {
                return RectangleRatio()
            }
        } else {
            return CameraKitConstants.DetectionRectangleRatio
        }
    }

    var detectingRectRatioLandscape: RectangleRatio{
        if UIDevice.current.userInterfaceIdiom == .phone{
            if let ratio = CameraKitConstants.singleton.iphoneRectangleLandscapeRatio {
                return ratio
            } else {
                return RectangleRatio()
            }
        } else {
            return CameraKitConstants.DetectionRectangleLandscapeRatio
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
        let connection = self.videoOutput?.connection(withMediaType: AVMediaTypeVideo)

        switch UIApplication.shared.statusBarOrientation{
        case .portrait:
            avcapturePreviewLayer?.connection.videoOrientation = AVCaptureVideoOrientation.portrait
//            connection?.videoOrientation = AVCaptureVideoOrientation.Portrait
        case .portraitUpsideDown:
            avcapturePreviewLayer?.connection.videoOrientation = .portraitUpsideDown
//            connection?.videoOrientation = .PortraitUpsideDown
        case .landscapeLeft:
            avcapturePreviewLayer?.connection.videoOrientation = .landscapeLeft
//            connection?.videoOrientation = .LandscapeLeft
        case .landscapeRight:
            avcapturePreviewLayer?.connection.videoOrientation = .landscapeRight
//            connection?.videoOrientation = .LandscapeRight
        case .unknown:
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
            }
        }
    }
    
    open override var prefersStatusBarHidden: Bool {
        return true
    }
}
