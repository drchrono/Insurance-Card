//
//  CameraOverlay.swift
//  testSBR
//
//  Created by Kan Chen on 9/23/15.
//  Copyright © 2015 Kan Chen. All rights reserved.
//

import UIKit
let kCornerRadius: CGFloat = 3

protocol CameraOverlayDelegate{
    func cancelFromImagePicker()
    func saveInImagePicker(ratio:RectangleRatio, detectRatio: RectangleRatio?)
}

struct RectangleRatio {
    var x:CGFloat
    var y:CGFloat
    var wp:CGFloat
    var hp:CGFloat
    init(x: CGFloat,y:CGFloat, wp:CGFloat, hp:CGFloat){
        self.x = x
        self.y = y
        self.wp = wp
        self.hp = hp
    }
}

class CameraOverlay: UIView {
    var method = 0
    var delegate: CameraOverlayDelegate?
    @IBOutlet var saveButton: UIButton!
    @IBOutlet var cancelButton: UIButton!
    var centerRect: CGRect?
    var ratio: RectangleRatio?
    var detectRatio: RectangleRatio?
    override func drawRect(rect: CGRect) {
        if method == 0 {
            print("drawRect=====")
            print(UIApplication.sharedApplication().statusBarOrientation.rawValue)
            print("width: \(rect.size.width)       height:\(rect.size.height)")

            drawDirectly(rect)
        }else if method == 1 {
            drawUsingMultipleLayers(rect)
        }
        
    }
    
    private func drawDirectly(rect: CGRect) {
        UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 0.3).setFill()
        UIRectFill(rect)
    
        print("######")
        print("width: \(rect.size.width)       height:\(rect.size.height)")
    
        guard let result = calculatePosition() else{
            return
        }
        let labelRect: CGRect = result.1
        let labelTransform: CGAffineTransform = result.2
        let rectInCenter: CGRect = result.0
        print("======")
        print(rectInCenter)
        let interRect = CGRectIntersection(rectInCenter, rect)
        
        UIColor.clearColor().setFill()
        UIRectFill(interRect)
        
        let path = UIBezierPath(roundedRect: rectInCenter, cornerRadius: kCornerRadius)
        path.lineWidth = 1
        UIColor.whiteColor().setStroke()
        path.stroke()
        
        let label = UILabel(frame: labelRect)
        label.transform = labelTransform
        
        label.textAlignment = NSTextAlignment.Center
        label.textColor = UIColor.whiteColor()
        label.text = "Postion Card in this Frame"
        self.cancelButton.transform = labelTransform
        self.addSubview(label)
        
        
    }
    
    private func drawUsingMultipleLayers (rect: CGRect) {
        guard let result = calculatePosition() else{
            return
        }
        let labelRect: CGRect = result.1
        let labelTransform: CGAffineTransform = result.2
        let rectInCenter: CGRect = result.0
       
        //Shadow Layer
        let shadowView = UIView(frame: rect)
        shadowView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)
        let maskLayer = CAShapeLayer()
        let maskPath = CGPathCreateMutable()
        CGPathAddRoundedRect(maskPath, nil, rectInCenter, kCornerRadius, kCornerRadius)
        CGPathAddRect(maskPath, nil, rect)
        maskLayer.path = maskPath
        maskLayer.fillColor = UIColor.whiteColor().CGColor
        maskLayer.fillRule = kCAFillRuleEvenOdd
        shadowView.layer.mask = maskLayer
        self.addSubview(shadowView)
        
        //add roundedRect
//        let path = UIBezierPath(roundedRect: rectInCenter, cornerRadius: 5)
//        path.lineWidth = 1
//        UIColor.whiteColor().setStroke()
//        path.stroke()
        
        
        self.bringSubviewToFront(self.rectView!)
        self.bringSubviewToFront(self.saveButton)
        self.bringSubviewToFront(self.cancelButton)
        
    }
    
    func calculatePosition() -> (CGRect,CGRect,CGAffineTransform)?{
        let rect = UIScreen.mainScreen().bounds
        print("=====")
        print(UIApplication.sharedApplication().statusBarOrientation.rawValue)
        print("width: \(rect.size.width)       height:\(rect.size.height)")
        var sideMargin:CGFloat = 30.0
        if (UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad) {
            if (UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad) {
                if UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeLeft || UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeRight{
                    sideMargin = 200
                    if rect.size.width == 768 {
                        print("reDraw")
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW,  500 * Int64(NSEC_PER_MSEC) ), dispatch_get_main_queue(), { () -> Void in
                            if let subView = self.subviews.last as? UILabel {
                                subView.removeFromSuperview()
                            }
                             self.setNeedsDisplay()
                        })
                    }
                    
                }else{
                    sideMargin = 100
                    if rect.size.width == 1024{
                        print("reDraw")
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW,  500 * Int64(NSEC_PER_MSEC) ), dispatch_get_main_queue(), { () -> Void in
                            if let subView = self.subviews.last as? UILabel {
                                subView.removeFromSuperview()
                            }
                            self.setNeedsDisplay()
                        })
                    }
                    
                }
                
            }

        }
        let centerWidth = rect.size.width - 2 * sideMargin
        let centerHeight = centerWidth / 1.6
        let labelRect: CGRect
        let labelTransform: CGAffineTransform
        let rectInCenter: CGRect

        if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone
            && (UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeLeft || UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeRight)  {
                print("Device current is \(UIDevice.currentDevice().orientation.rawValue)")
                let rectW:CGFloat = 250
                let rectH:CGFloat = 400
                rectInCenter = CGRectMake((rect.width - rectW) / 2,(rect.height - rectH) / 2 , rectW, rectH)
                
                // calculate crop ratio
                let ty = (UIScreen.mainScreen().bounds.height - (UIScreen.mainScreen().bounds.width * 4 / 3)) / 2
                let y:CGFloat = rectInCenter.origin.x / rect.width
                let hp:CGFloat = rectInCenter.size.width / rect.width
                let x:CGFloat = (rectInCenter.origin.y - ty)/(rect.height - 2 * ty)
                let wp:CGFloat = rectInCenter.size.height / (rect.height - 2 * ty)
                self.ratio = RectangleRatio(x: x, y: y, wp: wp, hp: hp)
                // end calculation
                if UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeLeft{
                    labelRect = CGRectMake(15 - rectInCenter.height/2 + (rect.width/2 - rectW/2-30-8), rect.height/2 - 15, rectH, 30)
                    labelTransform = CGAffineTransformMakeRotation(CGFloat(M_PI_2))
                }else{
                    labelRect = CGRectMake(rect.width - 15 - rectInCenter.height/2 - (rect.width/2 - rectW/2-30-8), rect.height/2 - 15, rectH, 30)
                    labelTransform = CGAffineTransformMakeRotation(CGFloat(-M_PI_2))
                }
                
        } else {
            rectInCenter = CGRectMake(rect.size.width/2 - centerWidth/2, rect.size.height/2 - centerHeight/2, centerWidth  , centerHeight)
            
            // calculate crop ratio
            if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad{
                let x:CGFloat = rectInCenter.origin.x / rect.width
                let y:CGFloat = rectInCenter.origin.y / rect.height
                let wp:CGFloat = rectInCenter.size.width / rect.width
                let hp:CGFloat = rectInCenter.size.height / rect.height
                self.ratio = RectangleRatio(x: x, y: y, wp: wp, hp: hp)
                let dx:CGFloat = (rectInCenter.origin.x - 40) / rect.width
                let dy:CGFloat = (rectInCenter.origin.y - 40) / rect.height
                let dwp:CGFloat = (rectInCenter.size.width + 80) / rect.width
                let dhp:CGFloat = (rectInCenter.size.height + 80) / rect.height
                self.detectRatio = RectangleRatio(x: dx, y: dy, wp: dwp, hp: dhp)
            }else{
                let ty = (UIScreen.mainScreen().bounds.height - (UIScreen.mainScreen().bounds.width * 4 / 3)) / 2
                let x:CGFloat = rectInCenter.origin.x / rect.width
                let wp:CGFloat = rectInCenter.size.width / rect.width
                let y:CGFloat = (rectInCenter.origin.y - ty)/(rect.height - 2 * ty)
                let hp:CGFloat = rectInCenter.size.height / (rect.height - 2 * ty)
                
                self.ratio = RectangleRatio(x: x, y: y, wp: wp, hp: hp)
            }
            // end calculation
            labelRect = CGRectMake(rect.size.width/2 - centerWidth/2 , rect.size.height/2 + centerHeight/2 + 8, centerWidth, 30)
            labelTransform = CGAffineTransformIdentity
        }
        return (rectInCenter, labelRect, labelTransform)
    }
    
    var rectView: UIView?
    override func awakeFromNib() {
        super.awakeFromNib()
        if method == 1{
            let newRect = calculatePosition()!.0
            
            let rectView = CenterView(frame:newRect)
            //        let rectView = UIView(frame: newRect)
            //        rectView.backgroundColor = UIColor.clearColor()
            //
            rectView.clipsToBounds = true
            self.addSubview(rectView)
            self.rectView = rectView
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "deviceOrientationChangedNotification:", name: UIDeviceOrientationDidChangeNotification, object: nil)
        }else if method == 0{
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "deviceOrientationChangedNotification2:", name: UIDeviceOrientationDidChangeNotification, object: nil)
        }
//        CATransaction.setDisableActions(false)
        
        //        let sampleView = self
        //        let maskLayer = CALayer()
        //        maskLayer.frame = sampleView.bounds
        //        let circleLayer = CAShapeLayer()
        //        circleLayer.frame = CGRectMake(sampleView.center.x - 100, sampleView.center.y - 100, 200, 200)
        //        let circlePath = UIBezierPath(ovalInRect: CGRectMake(0, 0, 200, 200))
        //        circleLayer.path = circlePath.CGPath
        //        circleLayer.fillColor = UIColor.blackColor().CGColor
        //        maskLayer.addSublayer(circleLayer)
        //
        //        sampleView.layer.mask = maskLayer
        
        
        
    }
    var lastOrientation: UIDeviceOrientation?
    func deviceOrientationChangedNotification2(note : NSNotification){
        let currentOrientation = UIDevice.currentDevice().orientation
        if currentOrientation == lastOrientation{
            return
        }
        lastOrientation = currentOrientation
        if currentOrientation == UIDeviceOrientation.LandscapeLeft ||
            currentOrientation == UIDeviceOrientation.LandscapeRight ||
            currentOrientation == UIDeviceOrientation.Portrait ||
            currentOrientation == UIDeviceOrientation.PortraitUpsideDown{
                guard let _ = self.superview else {
                    return
                }
                if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad{
                    self.setNeedsDisplay()
                    if let subView = self.subviews.last as? UILabel {
                        subView.removeFromSuperview()
                    }
                }else{
                    self.setNeedsDisplay()
                    if let subView = self.subviews.last as? UILabel {
                        subView.removeFromSuperview()
                    }
                }
        }
    }
    
    func deviceOrientationChangedNotification(note : NSNotification){
        guard let _ = self.superview else {
            return
        }
        if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad{
            (self.subviews.first)!.removeFromSuperview()
            if let subView = self.subviews.last as? UILabel {
                subView.removeFromSuperview()
            }
            self.setNeedsDisplay()
            
        }else{
            let newRect = calculatePosition()!.0
            let tempView = UIView(frame: self.frame)
            tempView.backgroundColor = UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 0.7)
            self.insertSubview(tempView, atIndex: 1)
            UIView.animateWithDuration(0.1, animations: { () -> Void in
                self.rectView?.frame = newRect
                }, completion: { (success: Bool) -> Void in
                    (self.subviews.first)!.removeFromSuperview()
                    (self.subviews.first)!.removeFromSuperview()
                    self.setNeedsDisplay()

            })
            if let subView = self.subviews.last as? UILabel {
                subView.removeFromSuperview()
            }
            
        }
    }
    
    @IBAction func clickedCancelButton(sender: AnyObject) {
        delegate?.cancelFromImagePicker()
    }
    
    @IBAction func clickedSaveButton(sender: AnyObject) {
        delegate?.saveInImagePicker(self.ratio!, detectRatio: detectRatio)
    }
}
