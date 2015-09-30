//
//  CameraOverlay.swift
//  testSBR
//
//  Created by Kan Chen on 9/23/15.
//  Copyright © 2015 Kan Chen. All rights reserved.
//

import UIKit

protocol CameraOverlayDelegate{
    func cancelFromImagePicker()
    func saveInImagePicker(ratio:RectangleRatio)
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
    var delegate: CameraOverlayDelegate?
    @IBOutlet var saveButton: UIButton!
    @IBOutlet var cancelButton: UIButton!
    var centerRect: CGRect?
    var ratio: RectangleRatio?
    
    override func drawRect(rect: CGRect) {
        print(2)
//        self.backgroundColor = UIColor.clearColor()
        // Drawing code
        func old() {
        UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 0.3).setFill()
        UIRectFill(rect)
        var sideMargin:CGFloat = 30.0
        if (UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad) {
            // iPad
            sideMargin = 100
            //TODO: check landscape and protrait
        }
        let centerWidth = rect.size.width - 2 * sideMargin
        let centerHeight = centerWidth / 1.6
        //Todo: change the ratio when use iphone portrait
        print("######")
        print("width: \(rect.size.width)       height:\(rect.size.height)")
        
            
            
        if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone
            && (UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeLeft || UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeRight)  {
            print("Device current is \(UIDevice.currentDevice().orientation.rawValue)")
                let rectW:CGFloat = 250
                let rectH:CGFloat = 400
                let rectInPhone = CGRectMake((rect.width - rectW) / 2,(rect.height - rectH) / 2 , rectW, rectH)
                let interRect = CGRectIntersection(rectInPhone, rect)
                
                UIColor.clearColor().setFill()
                UIRectFill(interRect)
                
                let path2 = UIBezierPath(roundedRect: rectInPhone, cornerRadius: 3)
                path2.lineWidth = 1
                UIColor.whiteColor().setStroke()
                path2.stroke()
                let ty = (UIScreen.mainScreen().bounds.height - (UIScreen.mainScreen().bounds.width * 4 / 3)) / 2
                let y:CGFloat = rectInPhone.origin.x / rect.width
                let hp:CGFloat = rectInPhone.size.width / rect.width
                let x:CGFloat = (rectInPhone.origin.y - ty)/(rect.height - 2 * ty)
                let wp:CGFloat = rectInPhone.size.height / (rect.height - 2 * ty)
                print(x)
                print(y)
                print(wp)
                print(hp)
                self.ratio = RectangleRatio(x: x, y: y, wp: wp, hp: hp)
                let label:UILabel
                if UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeLeft{
                    label = UILabel(frame: CGRectMake(15 - rectInPhone.height/2 + (rect.width/2 - rectW/2-30-8), rect.height/2 - 15, rectH, 30))
                    label.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2))
                    self.cancelButton.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2))
                }else{
                    label = UILabel(frame: CGRectMake(rect.width - 15 - rectInPhone.height/2 - (rect.width/2 - rectW/2-30-8), rect.height/2 - 15, rectH, 30))
                    label.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI_2))
                    self.cancelButton.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI_2))
                }
                label.textAlignment = NSTextAlignment.Center
                label.textColor = UIColor.whiteColor()
                label.text = "Postion Card in this Frame"
                self.addSubview(label)

        } else {
            let holy = CGRectMake(rect.size.width/2 - centerWidth/2, rect.size.height/2 - centerHeight/2, centerWidth  , centerHeight)
            let holerect = CGRectIntersection(holy, rect)
            self.centerRect = holy
            
            UIColor.clearColor().setFill()
            UIRectFill(holerect)
            
            let path = UIBezierPath(roundedRect: holy, cornerRadius: 3)
            path.lineWidth = 1
            UIColor.whiteColor().setStroke()
            path.stroke()
            if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad{
                let x:CGFloat = holy.origin.x / rect.width
                let y:CGFloat = holy.origin.y / rect.height
                let wp:CGFloat = holy.size.width / rect.width
                let hp:CGFloat = holy.size.height / rect.height
                self.ratio = RectangleRatio(x: x, y: y, wp: wp, hp: hp)
            }else{
                let ty = (UIScreen.mainScreen().bounds.height - (UIScreen.mainScreen().bounds.width * 4 / 3)) / 2
                let x:CGFloat = holy.origin.x / rect.width
                let wp:CGFloat = holy.size.width / rect.width
                let y:CGFloat = (holy.origin.y - ty)/(rect.height - 2 * ty)
                let hp:CGFloat = holy.size.height / (rect.height - 2 * ty)
                print(x)
                print(y)
                print(wp)
                print(hp)
                self.ratio = RectangleRatio(x: x, y: y, wp: wp, hp: hp)
            }
            let label = UILabel(frame: CGRectMake(rect.size.width/2 - centerWidth/2 , rect.size.height/2 + centerHeight/2 + 8, centerWidth, 30))
            label.textAlignment = NSTextAlignment.Center
            label.textColor = UIColor.whiteColor()
            label.text = "Postion Card in this Frame"
            self.cancelButton.transform = CGAffineTransformIdentity
            self.addSubview(label)
            
        }
            

            
        
        
        }
        
        func new () {
            let moreView = UIView(frame: self.bounds)
            moreView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)
        
        
            let maskLayer = CAShapeLayer()
            let maskPath = CGPathCreateMutable()
            CGPathAddRoundedRect(maskPath, nil, CGRectInset(self.bounds, 100, 100), 10, 10)

            maskLayer.fillColor = UIColor(white: 0.5, alpha: 0.6).CGColor
            maskLayer.path = maskPath
        
            CGPathAddRect(maskPath, nil, self.bounds)
            
            maskLayer.fillRule = kCAFillRuleEvenOdd
            
            moreView.layer.mask = maskLayer
            self.addSubview(moreView)
            let path = UIBezierPath(roundedRect: CGRectInset(self.bounds, 100, 100), cornerRadius: 10)
            path.lineWidth = 1
            UIColor.whiteColor().setStroke()
            path.stroke()
            self.bringSubviewToFront(self.saveButton)
            self.bringSubviewToFront(self.cancelButton)
            
        }
        old()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone && UIDevice.currentDevice().orientation ==  UIDeviceOrientation.LandscapeLeft {
                    }
        if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone && UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeRight{
                    }
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

        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "deviceOrientationChangedNotification:", name: UIDeviceOrientationDidChangeNotification, object: nil)
    }
    
    func deviceOrientationChangedNotification(note : NSNotification){
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
    
    @IBAction func clickedCancelButton(sender: AnyObject) {
        delegate?.cancelFromImagePicker()
    }
    
    @IBAction func clickedSaveButton(sender: AnyObject) {
        delegate?.saveInImagePicker(self.ratio!)
    }
}
