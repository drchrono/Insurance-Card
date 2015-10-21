//
//  ViewController.swift
//  DRCCamera
//
//  Created by Kan Chen on 9/28/15.
//  Copyright © 2015 Kan Chen. All rights reserved.
//

import UIKit
import DRCCameraSwift

class ViewController: UIViewController , DRCCustomImagePickerControllerDelegate{

    @IBOutlet weak var sniper: UIActivityIndicatorView!
    @IBOutlet weak var overlay: UIImageView!
    @IBOutlet weak var cropView: UIImageView!
    @IBOutlet weak var detectView: UIImageView!
    @IBOutlet var imageView: UIImageView!
    var imageOCR = ImageOCR.shared
    override func viewDidLoad() {
        super.viewDidLoad()
        ImageOCR.shared.initTesseract { () -> Void in
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    var picker: DRCCustomImagePickerController?

    @IBOutlet weak var click2: UIButton!
    @IBAction func click2(sender: AnyObject) {
        let customPicker = DRCCustomImagePickerController()
        customPicker.customDelegate = self
        customPicker.showImagePicker(inViewController: self)
        customPicker.enableImageDetecting = true
//        customPicker.method = 1
        self.picker = customPicker
    }
    @IBAction func click(sender: AnyObject) {
        let customPicker = DRCCustomImagePickerController()
        customPicker.customDelegate = self
        customPicker.showImagePicker(inViewController: self)
        customPicker.enableImageDetecting = true
//        customPicker.method = 0
        self.picker = customPicker
    }
    
    var result = [String: String]()
    
    func customImagePickerDidFinishPickingImage(rectImage: UIImage, detectedRectImage: UIImage?) {
        imageView.image = rectImage.g8_grayScale()
        detectView.image = detectedRectImage
        
        if let detectedRectImage = detectedRectImage{
            if self.imageOCR.isAvailable {
                sniper.startAnimating()
                imageOCR.detectTextInImageBackground(detectedRectImage, completion: { (result) -> Void in
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        if let id = result["id"] {
                            print("result:"+id)
                        }
                        self.sniper.stopAnimating()
                    })
                    
                })
            }
        }else{
            self.imageOCR.detectTextInRawImage(rectImage)
        }
    }
  
    @IBAction func clickedDetail(sender: AnyObject) {
        performSegueWithIdentifier("detail", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "detail"{
            let dest = segue.destinationViewController as! TableViewController
//            dest.images = self.photos
//            dest.strs = self.strs
        }
    }
}

