//
//  CameraViewController.swift
//  DRCCamera
//
//  Created by Kan Chen on 11/17/15.
//  Copyright © 2015 Kan Chen. All rights reserved.
//

import UIKit
import AVFoundation
@objc public protocol CameraViewControllerDelegate{
    func didFinshedTakePhoto(image: UIImage)
}

public class CameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var overlayImageView: UIImageView!
    public var delegate :CameraViewControllerDelegate?
    
    var captureSession:AVCaptureSession?
    var avcapturePreviewLayer: AVCaptureVideoPreviewLayer?
    var videoOutput:AVCaptureVideoDataOutput?
    var stillImageOutput:AVCaptureStillImageOutput?
    
    var detector:CIDetector!
    var enableDetect = true
    var lastRectFeature: CIRectangleFeature?
    
    var context: EAGLContext?
    public class func ViewControllerFromNib() -> CameraViewController{
        let nibVC = CameraViewController(nibName: "CameraViewController", bundle: NSBundle(forClass: CameraViewController.classForCoder()))
        return nibVC
    }
    override public func viewDidLoad() {
        super.viewDidLoad()
        let value = UIInterfaceOrientation.Portrait.rawValue
        UIDevice.currentDevice().setValue(value, forKey: "orientation")

//        let appDelegate = UIApplication.sharedApplication()
//        let windowRect = UIScreen.mainScreen().bounds
//        previewView = UIView(frame: windowRect)
//        previewView.backgroundColor = UIColor.clearColor()
//        appDelegate.windows[0].insertSubview(pre, belowSubview: <#T##UIView#>)
        if !setupCaptureSession(){
            print("Setup Failed")
            assert(false)
        }
        detector = CIDetector(ofType: CIDetectorTypeRectangle, context: nil, options: [CIDetectorAccuracy:CIDetectorAccuracyHigh])
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
       
    }
    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
                avcapturePreviewLayer!.frame = previewView.bounds
        captureSession?.startRunning()
    }
    var lastDate = NSDate()
    public func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
        let pixelBuffer: CVPixelBufferRef = CMSampleBufferGetImageBuffer(sampleBuffer)!
        
        let ciImage = CIImage(CVPixelBuffer: pixelBuffer)
        if enableDetect{
            let interval = NSDate().timeIntervalSinceDate(lastDate)
            if interval < 0.1 {
                print("dont detect now")
                return
            }
            lastDate = NSDate()
            let features = detector.featuresInImage(ciImage) as? [CIRectangleFeature]
            print("detected \(features?.count) features")
            if let features = features where features.count > 0 {
                self.lastRectFeature = features[0]
            }else{
                return
            }

            if let f = lastRectFeature{
//                let fdesc = CMSampleBufferGetFormatDescription(sampleBuffer)
//                let clap = CMVideoFormatDescriptionGetCleanAperture(fdesc!, false  /*originIsTopLeft == false*/)
//                dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                    self.drawForFeature(f, clap: clap, orientation: UIDevice.currentDevice().orientation)
//                })
                let overlay = self.drawOverlay(ciImage, feature: f)
                let context = CIContext()
                let cgImage = context.createCGImage(overlay, fromRect: ciImage.extent)
                let uiImage = UIImage(CGImage: cgImage)
                print("uiimage orientation:\(uiImage.imageOrientation.rawValue)")
                print(ciImage.extent)
                print(uiImage.size)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.overlayImageView.image = uiImage
                    self.previewView.bringSubviewToFront(self.overlayImageView)
//                    self.capturedImage.image = uiImage
                })

            }
        }

    }
    func drawForFeature(feature:CIRectangleFeature, clap:CGRect, orientation: UIDeviceOrientation ){
        let sublayers = avcapturePreviewLayer?.sublayers
        
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        
        for layer in sublayers!{
            if layer.name == "FaceLayer"{
                layer.hidden = true
            }
        }
        let parentFrameSize = previewView.frame.size
        let gravity = avcapturePreviewLayer?.videoGravity
        let previewBox = self.videoPreviewBoxForGravity(gravity!, frameSize: parentFrameSize, apertureSize: clap.size)
        
        
    }
    
    func videoPreviewBoxForGravity(gravity:String, frameSize:CGSize, apertureSize:CGSize) -> CGRect{
        let apertureRatio = apertureSize.height / apertureSize.width
        let viewRatio = frameSize.width / frameSize.height
        var size = CGSizeZero
        if gravity == AVLayerVideoGravityResizeAspectFill{
            if viewRatio > apertureRatio{
                if (viewRatio > apertureRatio) {
                    size.width = frameSize.width
                    size.height = apertureSize.width * (frameSize.width / apertureSize.height)
                } else {
                    size.width = apertureSize.height * (frameSize.height / apertureSize.width)
                    size.height = frameSize.height
                }
            }else if gravity == AVLayerVideoGravityResizeAspect{
                if (viewRatio > apertureRatio) {
                    size.width = apertureSize.height * (frameSize.height / apertureSize.width);
                    size.height = frameSize.height;
                } else {
                    size.width = frameSize.width;
                    size.height = apertureSize.width * (frameSize.width / apertureSize.height);
                }
            }else if gravity == AVLayerVideoGravityResize{
                size.width = frameSize.width;
                size.height = frameSize.height;
            }
        }
        var videoBox = CGRect()
        videoBox.size = size
        if (size.width < frameSize.width){
            videoBox.origin.x = (frameSize.width - size.width) / 2}
        else{
            videoBox.origin.x = (size.width - frameSize.width) / 2}
        
        if ( size.height < frameSize.height ){
            videoBox.origin.y = (frameSize.height - size.height) / 2}
        else{
            videoBox.origin.y = (size.height - frameSize.height) / 2}
        
        return videoBox
        
    }
    
    func drawOverlay(ciImage: CIImage , feature: CIRectangleFeature) -> CIImage{
        var overlay = CIImage(color: CIColor(red: 1, green: 0, blue: 0, alpha: 0.6))
        overlay = overlay.imageByCroppingToRect(ciImage.extent)
        overlay = overlay.imageByApplyingFilter("CIPerspectiveTransformWithExtent", withInputParameters: ["inputExtent": CIVector(CGRect: ciImage.extent),
            "inputTopLeft": CIVector(CGPoint:feature.topLeft),
            "inputTopRight":CIVector(CGPoint:feature.topRight),
            "inputBottomLeft": CIVector(CGPoint: feature.bottomLeft),
            "inputBottomRight": CIVector(CGPoint: feature.bottomRight)])
        
        overlay = overlay.imageByCompositingOverImage(ciImage)
        return overlay
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func setupCaptureSession() -> Bool{
        captureSession = AVCaptureSession()
        captureSession!.sessionPreset = AVCaptureSessionPresetPhoto
        let backCamera = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
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
        let rgbOutputSettings = [kCVPixelBufferPixelFormatTypeKey as NSString: NSNumber(unsignedInt:kCVPixelFormatType_32BGRA) ]
        videoOutput?.videoSettings = rgbOutputSettings
        videoOutput?.alwaysDiscardsLateVideoFrames = true
        let videoDataOutputQueue = dispatch_queue_create("videoOutputQueue", DISPATCH_QUEUE_SERIAL)
        videoOutput?.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        if captureSession!.canAddOutput(videoOutput){
            captureSession!.addOutput(videoOutput)
            
            let connection = self.videoOutput?.connectionWithMediaType(AVMediaTypeVideo)
            connection?.videoOrientation = AVCaptureVideoOrientation.Portrait
            avcapturePreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
            self.previewView.layer.addSublayer(avcapturePreviewLayer!)
            
            return true
        }
        return false
    }
    
    @IBAction func clickedCancelButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func clickedTakeButton(sender: AnyObject) {
        if let videoConnection = stillImageOutput!.connectionWithMediaType(AVMediaTypeVideo) {
            stillImageOutput?.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: { (sampleBuffer:CMSampleBuffer!, error:NSError!) -> Void in
                if sampleBuffer == nil{
                    print(error)
                    return
                }
                self.captureSession?.stopRunning()
                let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                let dataProvider = CGDataProviderCreateWithCFData(imageData)
                let cgImageRef = CGImageCreateWithJPEGDataProvider(dataProvider, nil, true, CGColorRenderingIntent.RenderingIntentDefault)
                let image = UIImage(CGImage: cgImageRef!, scale: 1.0, orientation:.Right)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.delegate?.didFinshedTakePhoto(image)
                })
            })
            
            
        
        }
    }
    public override func shouldAutorotate() -> Bool {
        return false
    }
    
    public override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
   
    
    public override func prefersStatusBarHidden() -> Bool {
        return true
    }
}