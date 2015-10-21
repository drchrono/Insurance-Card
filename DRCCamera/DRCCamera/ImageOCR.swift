//
//  ImageOCR.swift
//  DRCCamera
//
//  Created by Kan Chen on 10/20/15.
//  Copyright © 2015 Kan Chen. All rights reserved.
//

import Foundation

class ImageOCR {
    static let shared = ImageOCR()
    var tesseract: G8Tesseract?
    var textDetector: CIDetector?
    var photos = [UIImage]()
    var strs = [String]()
    var isDebug = false
    
    var isAvailable: Bool{
        get{
        if let _ = tesseract, _ = textDetector {
            return true
        }
        return false
        }
    }
    
    func initTesseract(){
        tesseract = G8Tesseract()
        tesseract?.language = "eng"
        tesseract?.engineMode = .TesseractCubeCombined
        tesseract?.pageSegmentationMode = G8PageSegmentationMode.SingleLine
        tesseract?.maximumRecognitionTime = 1.0
        
        textDetector = CIDetector(ofType: CIDetectorTypeText, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
    }
    
    func initTesseract(complete: () -> Void){
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) { () -> Void in
            self.initTesseract()
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                complete()
            })
        }
    }
    
    func detectTextInImageBackground(image: UIImage, completion: (result: [String:String])-> Void) {
        let start = NSDate.timeIntervalSinceReferenceDate()
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            if !self.isAvailable {
                completion(result: [String:String]())
            }
            completion(result: self.detectTextInImage(image))
            let end = NSDate.timeIntervalSinceReferenceDate()
            let interval = Double(end - start)
            print("all process takes \(interval)")
        }
        
    }
    //return useful dict
    func detectTextInImage(image: UIImage) -> [String: String]{
        initBeforeEachDetect()
        
        guard let detect = textDetector else{
            return ocrResult
        }
        let imageci = CIImage(image: image)!
        let features = detect.featuresInImage(imageci, options: nil) as! [CITextFeature]
        
        if features.count == 0 {
            return ocrResult
        }
        
        print("Image has \(features.count) features")
        for feature in features{
            if shouldFinished {
                break
            }
            // filter right part
            if (feature.topLeft.x + feature.topRight.x) / 2 > imageci.extent.width * 0.5 {
                continue
            }
            // filter height
            
            let textRect:CIImage = cropTextPartByFeature(imageci, feature: feature, margin: 5)
            let context = CIContext(options: nil)
            let cgImage: CGImageRef = context.createCGImage(textRect, fromRect: textRect.extent)
            let textUIImage = UIImage(CGImage: cgImage)
            
            performImageRecognition(textUIImage, result: &ocrResult)
//            if ocrResult.count > 1 || self.shouldFinished{
//                ocrResult["id"] = id
//                return ocrResult
//            }
            if ocrResult.count > 1 || self.shouldFinished {
                return ocrResult
            }
        }
        return ocrResult
    }
    
    func detectTextInRawImage(image: UIImage){
        guard let detect = textDetector else{
            return
        }
        let imageci = CIImage(image: image)!
        let features = detect.featuresInImage(imageci, options: nil) as! [CITextFeature]
        print("didn't detect rect but detect \(features.count) text in image")

    }
    enum LastIndentifyKey{
        case ID
        case Group
        case None
    }
    var ocrResult = [String:String]()
    var inSteps = 0
    var finalSteps = Int.max
    var shouldFinished = false
    var lastKey = LastIndentifyKey.None
    
    func initBeforeEachDetect() {
        self.ocrResult = [String:String]()
        self.finalSteps = Int.max
        self.shouldFinished = false
        self.lastKey = .None
        self.inSteps = 0
    }
    
    func performImageRecognition(image: UIImage, inout result: [String: String]){
        finalSteps--
        if finalSteps == 0{
            shouldFinished = true
            return
        }
        let start = NSDate.timeIntervalSinceReferenceDate()
        guard let tesseract = tesseract else{
            return
        }
        
        let imageG8 = image.g8_blackAndWhite()
        tesseract.image = imageG8
        tesseract.recognize()
        
        print("Detected :     ==\(tesseract.recognizedText)==")
        let end = NSDate.timeIntervalSinceReferenceDate()
        let interval = Double(end - start)
        print("OCR cost time: \(interval)")
        let text = getCleanString(tesseract.recognizedText)
        
        if lastKey == .None && foundIdFeature(text){
            lastKey = .ID
            inSteps = 2
            finalSteps = 6
            if isPotentialIdString(text) {
                let strs = text.characters.split(":").map({ String($0) })
                for index in 1..<strs.count{
                    if isPotentialIdString(strs[index]) {
                        result["id"] = strs[index]
                        if isDebug{
                            self.strs.append(strs[index])
                            self.photos.append(image)
                        }
                        return
                    }
                }
            }
        }else if lastKey == .ID && result["id"] == nil{
            if isPotentialIdString(text) {
                if isDebug{
                    self.strs.append(text)
                    self.photos.append(image)
                }
//                self.shouldFinished = true
                result["id"] = text
                return
            }
            if inSteps == 1 {
                lastKey = .None
                inSteps = 0
            }else{
                inSteps--
            }
        }else if lastKey == .ID {
            if text.characters.count > 6 && isPotentialIdString(text){
                if text.containsString(":") {
                    let strs = text.characters.split(":").map({ String($0)})
                    for index in 1..<strs.count{
                        if isPotentialIdString(strs[index]){
                            result["group"] = strs[index]
                            shouldFinished = true
                            return
                        }
                    }
                }else{
                    result["group"] = text
                    shouldFinished = true
                    return
                }
            }
        }
        if foundGroupFeatrue(text){
            lastKey = .Group
            inSteps = 2
            if isPotentialIdString(text){
                let strs = text.characters.split(":").map({String($0)})
                for index in 1..<strs.count{
                    if isPotentialIdString(strs[index]){
                        result["group"] = strs[index]
                        shouldFinished = true
                        if isDebug{
                            
                        }
//                        shouldFinished = true
                        return
                    }
                }
            }
        }else if lastKey == .Group && result["group"] == nil{
            if isPotentialIdString(text){
                result["group"] = text
                shouldFinished = true
                return
            }
            if inSteps == 1 {
                shouldFinished = true
                return
            }else{
                inSteps--
            }
        }
        return
    }
    
    //MARK: - Regex Part
    
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
    
    func foundIdFeature(text:String) -> Bool{
        let idReg = try! NSRegularExpression(pattern: "(i|I)(d|D)(entification)*", options: [])
        if let _ = idReg.firstMatchInString(text, options: [], range: NSRange(location: 0, length: text.characters.count)) {
            return true
        }
        return false
    }
    
    func foundGroupFeatrue(text:String) -> Bool{
        //ocr will mix p and g sometimes
        let groupReg = try! NSRegularExpression(pattern: "(g|G|p)rou(p|g)", options: [])
        if let _ = groupReg.firstMatchInString(text, options: [], range: NSRange(location: 0, length: text.characters.count)) {
            return true
        }
        return false
    }
    
    //MARK: - crop
    func cropTextPartByFeature(image: CIImage, feature f: CITextFeature, margin: CGFloat) -> CIImage{
        var card: CIImage
        let topLeft = CGPoint(x: f.topLeft.x - margin, y: f.topLeft.y + margin)
        let topRight = CGPoint(x: f.topRight.x + margin, y: f.topRight.y + margin)
        let bottomLeft = CGPoint(x: f.bottomLeft.x - margin , y: f.bottomLeft.y - margin)
        let bottomRight = CGPoint(x: f.bottomRight.x + margin, y: f.bottomRight.y - margin)
        
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
    
    //MARK: - ResultTextProcess
    func getCleanString(s: String) -> String{
        return s.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }
}