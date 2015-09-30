//
//  DRCCustomImagePickerController.swift
//  testSBR
//
//  Created by Kan Chen on 9/24/15.
//  Copyright © 2015 Kan Chen. All rights reserved.
//

import UIKit

@objc public protocol DRCCustomImagePickerControllerDelegate{
    func customImagePickerDidFinishPickingImage(rectImage: UIImage, detectedRectImage: UIImage?)
}

public class DRCCustomImagePickerController: UIImagePickerController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CameraOverlayDelegate {
    var imagePicker = UIImagePickerController()
    var photoRatio : RectangleRatio?
    public var enableImageDetecting:Bool = false
    public var customDelegate: DRCCustomImagePickerControllerDelegate?
    var parentVC: UIViewController?
    override public func viewDidLoad() {
        super.viewDidLoad()
    }
    
    public func showImagePicker(inViewController parent: UIViewController){
        let sourceType = UIImagePickerControllerSourceType.Camera
        imagePicker.sourceType = sourceType
        
        var availableSource = UIImagePickerController.availableMediaTypesForSourceType(sourceType)
        availableSource?.removeLast()
        imagePicker.mediaTypes = availableSource!
        
        imagePicker.delegate = self
        imagePicker.showsCameraControls = false
        let bundle = NSBundle(forClass: DRCCustomImagePickerController.classForCoder())
        let xibs = bundle.loadNibNamed("CameraOverlay", owner: nil, options: nil)
        
//        let xibs = NSBundle.mainBundle().loadNibNamed("CameraOverlay", owner: nil, options: nil)
        let overlayView = xibs.first as? CameraOverlay
        overlayView?.frame = imagePicker.cameraOverlayView!.frame
        imagePicker.cameraOverlayView = overlayView
        overlayView?.delegate = self
        
        setCameraCenter()
        
        self.parentVC = parent
        parentVC!.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    private func setCameraCenter(){
        if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone{
            var transform = self.imagePicker.cameraViewTransform
            let y = (UIScreen.mainScreen().bounds.height - (UIScreen.mainScreen().bounds.width * 4 / 3)) / 2
            transform.ty = y
            self.imagePicker.cameraViewTransform = transform
        }

    }
    
//    public override func shouldAutorotate() -> Bool {
//        return false
//    }
    public func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        self.parentVC!.dismissViewControllerAnimated(true) { () -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
//
                print(image.imageOrientation.rawValue)
                let rotatedPhoto: UIImage = ImageHandler.scaleAndRotateImage(image)
      
//                let imageRef3 = CGImageCreateWithImageInRect(rotatedPhoto.CGImage, CGRectMake(image.size.width * self.photoRatio!.x, image.size.height * self.photoRatio!.y, image.size.width * self.photoRatio!.wp, image.size.height * self.photoRatio!.hp))
                let rect = CGRectMake(rotatedPhoto.size.width * self.photoRatio!.x, rotatedPhoto.size.height * self.photoRatio!.y, rotatedPhoto.size.width * self.photoRatio!.wp, rotatedPhoto.size.height * self.photoRatio!.hp)
                let imageRef3 = CGImageCreateWithImageInRect(rotatedPhoto.CGImage, rect)
                
                let rectImage = UIImage(CGImage: imageRef3!)
                self.customDelegate?.customImagePickerDidFinishPickingImage(rectImage, detectedRectImage: self.detect(rectImage))
                
            })
            
            
        }

    }
    
    //MARK: - OverlayDelegate
    func cancelFromImagePicker() {
        self.parentVC!.dismissViewControllerAnimated(true, completion: nil)
    }
    func saveInImagePicker(ratio: RectangleRatio) {
        imagePicker.takePicture()
        self.photoRatio = ratio
    }
    
    func detect(image: UIImage) -> UIImage?{
        if !enableImageDetecting {
            return nil
        }
        let detector = CIDetector(ofType: CIDetectorTypeRectangle, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh, CIDetectorMinFeatureSize: 0.2])
        
        let imageCI = CIImage(image: image)!
//        var result = image
        
        
        let opts = [CIDetectorAspectRatio: 1.6]
        let features = detector.featuresInImage(imageCI, options: opts) as! [CIRectangleFeature]
        if features.count == 0 {
            return nil
        }
        if features.count > 1{
            print("we found \(features.count) features")
        }
        let featuresRect = features[0].bounds
        let imageRef = CGImageCreateWithImageInRect(image.CGImage, featuresRect)
        let resultImage = UIImage(CGImage: imageRef!)
//        for f:CIRectangleFeature in features{
//            var overlay = CIImage(color: CIColor(color: UIColor(red: 1, green: 0, blue: 0, alpha: 0.6)))
//            overlay = overlay.imageByCroppingToRect(image.extent)
//            overlay = overlay.imageByApplyingFilter("CIPerspectiveTransformWithExtent", withInputParameters: ["inputExtent": CIVector(x: 0, y: 0, z: 1, w: 1),
//                "inputTopLeft": CIVector(CGPoint: f.topLeft), "inputTopRight": CIVector(CGPoint: f.topRight), "inputBottomLeft": CIVector(CGPoint: f.bottomLeft),"inputBottomRight": CIVector(CGPoint: f.bottomRight)])
//            result = overlay.imageByCompositingOverImage(result)
//            
//        }
//        let result2 = image
//        var overlay = CIImage(color: CIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.7))
//        overlay = overlay.imageByCroppingToRect(features[0].bounds)
//        
//        let ciimagewithoverlay = overlay.imageByCompositingOverImage(result2)
//        resultImage.image = UIImage(CIImage:ciimagewithoverlay)
        
//        image2.image = UIImage(CIImage: result)
        return resultImage
    }

}
