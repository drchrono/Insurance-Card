//
//  ViewController.swift
//  DRCCamera
//
//  Created by Kan Chen on 9/28/15.
//  Copyright © 2015 Kan Chen. All rights reserved.
//

import UIKit

class ViewController: UIViewController , DRCCustomImagePickerControllerDelegate{
    var photos = [UIImage]()
    @IBOutlet weak var overlay: UIImageView!
    @IBOutlet weak var cropView: UIImageView!
    @IBOutlet weak var detectView: UIImageView!
    @IBOutlet var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        let rectView = CenterView(frame: CGRectInset(self.view.bounds, 100, 100))
//        rectView.backgroundColor = UIColor.clearColor()
//        self.view.addSubview(rectView)
//        performImageRecognition(UIImage(named: "Lenore")!)
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
    
    func customImagePickerDidFinishPickingImage(rectImage: UIImage, detectedRectImage: UIImage?) {
        imageView.image = rectImage.g8_grayScale()
        detectView.image = detectedRectImage
        var test: UIImage?
        if let detectedRectImage = detectedRectImage{
            let detect = CIDetector(ofType: CIDetectorTypeText, context: nil, options: [CIDetectorAccuracy:CIDetectorAccuracyHigh])
            let imageci = CIImage(image: detectedRectImage)!
            let features = detect.featuresInImage(imageci, options: nil) as! [CITextFeature]
            
            if features.count == 0 {
                return
            }
            
            print("has \(features.count) fs")
            for feature in features{
                var overlay = CIImage(color: CIColor(color: UIColor(red: 1, green: 0, blue: 0, alpha: 0.7)))
                overlay = overlay.imageByCroppingToRect(imageci.extent)
                let f = feature
//                let f = features[0]
                //            let topLeft = CGPoint(x: f.topLeft.x - 5, y: f.topLeft.y - 5)
                //            let topRight = CGPoint(x: f.topRight.x + 5, y: f.topRight.y - 5)
                //            let bottomLeft = CGPoint(x: f.bottomLeft.x - 5 , y: f.bottomLeft.y + 5)
                //            let bottomRight = CGPoint(x: f.bottomRight.x + 5, y: f.bottomRight.y + 5)
                overlay = overlay.imageByApplyingFilter("CIPerspectiveTransformWithExtent",
                    withInputParameters: ["inputExtent": CIVector(CGRect: imageci.extent),
                        "inputTopLeft": CIVector(CGPoint: f.topLeft),
                        "inputTopRight": CIVector(CGPoint: f.topRight),
                        "inputBottomLeft": CIVector(CGPoint: f.bottomLeft),
                        "inputBottomRight": CIVector(CGPoint: f.bottomRight)]
                )
                let resultci = overlay.imageByCompositingOverImage(imageci)
                let result = UIImage(CIImage: resultci)
                self.overlay.image = result
                
                let textRect = cropCardByFeature(imageci, feature: f)
                let context = CIContext(options: nil)
                let cgImage: CGImageRef = context.createCGImage(textRect, fromRect: textRect.extent)
                let textUIImage = UIImage(CGImage: cgImage)
                performImageRecognition(textUIImage)
                test = textUIImage
                self.photos.append(textUIImage)
            }
        }
        
        cropView.image = test
        
//        if let image = picker?.overlay{
//            overlay.image = image
//        }
    }
    
    func performImageRecognition(image: UIImage) {
        // 1
        
        let tesseract = G8Tesseract()
        
        // 2
        tesseract.language = "eng"
        
        // 3
        tesseract.engineMode = .TesseractCubeCombined
        
        // 4
        tesseract.pageSegmentationMode = .Auto
        
        // 5
        tesseract.maximumRecognitionTime = 60.0
        
        // 6
        let imageG8 = image.g8_blackAndWhite()
        let imageG82 = image.g8_grayScale()
        print("iamgeG8: \(imageG8)")
        print("image: \(image)")
//        self.overlay.image = imageG8
        tesseract.image = imageG8
        tesseract.recognize()
        
        // 7
        print("Detected :     \(tesseract.recognizedText)")
        
    }
    func cropCardByFeature(image: CIImage, feature: CITextFeature) -> CIImage{
        var card: CIImage
        let f = feature
        let topLeft = CGPoint(x: f.topLeft.x - 5, y: f.topLeft.y + 5)
        let topRight = CGPoint(x: f.topRight.x + 5, y: f.topRight.y + 5)
        let bottomLeft = CGPoint(x: f.bottomLeft.x - 5 , y: f.bottomLeft.y - 5)
        let bottomRight = CGPoint(x: f.bottomRight.x + 5, y: f.bottomRight.y - 5)
        
        card = image.imageByApplyingFilter("CIPerspectiveTransformWithExtent",
            withInputParameters: ["inputExtent": CIVector(CGRect: image.extent),
                "inputTopLeft": CIVector(CGPoint: topLeft),
                "inputTopRight": CIVector(CGPoint: topRight),
                "inputBottomLeft": CIVector(CGPoint: bottomLeft),
                "inputBottomRight": CIVector(CGPoint: bottomRight)]
        )
        card = image.imageByCroppingToRect(card.extent)
        return card
    }
    @IBAction func clickedDetail(sender: AnyObject) {
        performSegueWithIdentifier("detail", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "detail"{
            let dest = segue.destinationViewController as! TableViewController
            dest.images = self.photos
        }
    }
}

