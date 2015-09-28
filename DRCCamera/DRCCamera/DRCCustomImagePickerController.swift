//
//  DRCCustomImagePickerController.swift
//  testSBR
//
//  Created by Kan Chen on 9/24/15.
//  Copyright © 2015 Kan Chen. All rights reserved.
//

import UIKit

protocol DRCCustomImagePickerControllerDelegate{
    func customImagePickerDidFinishPickingImage(rectImage: UIImage)
}

class DRCCustomImagePickerController: UIImagePickerController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CameraOverlayDelegate {
    var imagePicker = UIImagePickerController()
    var photoRatio : RectangleRatio?
    var customDelegate: DRCCustomImagePickerControllerDelegate?
    var parentVC: UIViewController?
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func showImagePicker(inViewController parent: UIViewController){
        let sourceType = UIImagePickerControllerSourceType.Camera
        imagePicker.sourceType = sourceType
        
        var availableSource = UIImagePickerController.availableMediaTypesForSourceType(sourceType)
        availableSource?.removeLast()
        imagePicker.mediaTypes = availableSource!
        
        imagePicker.delegate = self
        imagePicker.showsCameraControls = false
        
        let xibs = NSBundle.mainBundle().loadNibNamed("CameraOverlay", owner: nil, options: nil)
        let overlayView = xibs.first as? CameraOverlay
        overlayView?.frame = imagePicker.cameraOverlayView!.frame
        imagePicker.cameraOverlayView = overlayView
        overlayView?.delegate = self
        
        self.parentVC = parent
        parentVC!.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        self.parentVC!.dismissViewControllerAnimated(true) { () -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                UIGraphicsBeginImageContext(image.size)
                
                
                let rotatedPhoto = Graph().scaleAndRotateImage(image)
                
                let imageRef3 = CGImageCreateWithImageInRect(rotatedPhoto.CGImage, CGRectMake(image.size.width * self.photoRatio!.x, image.size.height * self.photoRatio!.y, image.size.width * self.photoRatio!.wp, image.size.height * self.photoRatio!.hp))
                let rectImage = UIImage(CGImage: imageRef3!)
                self.customDelegate?.customImagePickerDidFinishPickingImage(rectImage)
                
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
}
