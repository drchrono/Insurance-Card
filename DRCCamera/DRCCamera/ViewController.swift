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
    var photos = [UIImage]()
    var strs = [String]()
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
    
    var result = [String: String]()
    
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
                if isFinished {
                    break
                }
//                var overlay = CIImage(color: CIColor(color: UIColor(red: 1, green: 0, blue: 0, alpha: 0.7)))
//                overlay = overlay.imageByCroppingToRect(imageci.extent)
                let f = feature
                
//                overlay = overlay.imageByApplyingFilter("CIPerspectiveTransformWithExtent",
//                    withInputParameters: ["inputExtent": CIVector(CGRect: imageci.extent),
//                        "inputTopLeft": CIVector(CGPoint: f.topLeft),
//                        "inputTopRight": CIVector(CGPoint: f.topRight),
//                        "inputBottomLeft": CIVector(CGPoint: f.bottomLeft),
//                        "inputBottomRight": CIVector(CGPoint: f.bottomRight)]
//                )
//                let resultci = overlay.imageByCompositingOverImage(imageci)
//                let result = UIImage(CIImage: resultci)
//                self.overlay.image = result
                
                // filter right part
                if f.topLeft.x > imageci.extent.width * 0.5 {
                    continue
                }
                // filter height
                
                let textRect:CIImage = cropCardByFeature(imageci, feature: f)
                let context = CIContext(options: nil)
                let cgImage: CGImageRef = context.createCGImage(textRect, fromRect: textRect.extent)
                let textUIImage = UIImage(CGImage: cgImage)
                
                performImageRecognition(textUIImage)
            }
        }
        
    }
    var inSteps = 0
    var isFinished = false
    
    func isPotentialIdString(text:String) -> Bool{
        let len = text.characters.count
        let pureDigitPattern = try! NSRegularExpression(pattern: "\\d{\(len)}", options: [])
        let digitMixCapitalPattern = try! NSRegularExpression(pattern: "(\\d|[A-Z]){3}\\d(\\d|[A-Z])*", options: [])
        
        if let _ = pureDigitPattern.firstMatchInString(text, options: [], range: NSRange(location: 0, length: len)) {
            return true
        }
        if let _ = digitMixCapitalPattern.firstMatchInString(text, options: [], range: NSRange(location: 0, length: len)) {
            return true
        }
        
        return false
    }
    
    func isID(text:String) -> Bool{
        let idReg = try! NSRegularExpression(pattern: "(i|I)(d|D)(entification)*", options: [])
        if let _ = idReg.firstMatchInString(text, options: [], range: NSRange(location: 0, length: text.characters.count)) {
            return true
        }
        return false
    }
    
    func isGroup(text:String) -> Bool{
        return true
    }
    
    func performImageRecognition(image: UIImage) -> String{
        // 1
        let start = NSDate.timeIntervalSinceReferenceDate()
        let tesseract = G8Tesseract()
        
        // 2
        tesseract.language = "eng"
        
        // 3
        tesseract.engineMode = .TesseractCubeCombined
        
        // 4
//        tesseract.pageSegmentationMode = .Auto
        tesseract.pageSegmentationMode = G8PageSegmentationMode.SingleLine
        // 5
        tesseract.maximumRecognitionTime = 60.0
//        tesseract.variableValueForKey(<#T##key: String!##String!#>)
        var end = NSDate.timeIntervalSinceReferenceDate()
        var interval = Double(end - start)
        print("Setup cost time: \(interval)")
        // 6
        let imageG8 = image.g8_blackAndWhite()

        tesseract.image = imageG8
        tesseract.recognize()
        
        // 7
        print("Detected :     ==\(tesseract.recognizedText)===")
        end = NSDate.timeIntervalSinceReferenceDate()
        interval = Double(end - start)
        print("OCR cost time: \(interval)")
        let text = tesseract.recognizedText
        
        if inSteps == 0 && isID(text){
            if isPotentialIdString(text) {
                let strs = text.characters.split(":").map({ String($0) })
                for index in 1..<strs.count{
                    if isPotentialIdString(strs[index]) {
                        self.strs.append(strs[index])
                        self.photos.append(image)
                        self.isFinished = true
                        return strs[index]
                    }
                }
            }else{
                inSteps = 2
            }
        }
        
        if inSteps > 0 {
            if isPotentialIdString(text) {
                self.strs.append(text)
                self.photos.append(image)
                self.isFinished = true
                return text
            }
            inSteps--
        }
        
//        if isPotentialIdString(text){
//            self.strs.append(text)
//            self.photos.append(image)
//        }
        return text
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
            dest.strs = self.strs
        }
    }
}

