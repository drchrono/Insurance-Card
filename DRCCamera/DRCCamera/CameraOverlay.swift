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
        
        NSLog("######")
        print("width: \(rect.size.width)       height:\(rect.size.height)")
        let holy = CGRectMake(rect.size.width/2 - centerWidth/2, rect.size.height/2 - centerHeight/2, centerWidth  , centerHeight)
        let holerect = CGRectIntersection(holy, rect)
        self.centerRect = holy
        
        UIColor.clearColor().setFill()
        UIRectFill(holerect)
        
        let path = UIBezierPath(roundedRect: holy, cornerRadius: 3)
        path.lineWidth = 1
        UIColor.whiteColor().setStroke()
        path.stroke()
        
        let x:CGFloat = holy.origin.x / rect.width
        let y:CGFloat = holy.origin.y / rect.height
        let wp:CGFloat = holy.size.width / rect.width
        let hp:CGFloat = holy.size.height / rect.height
        self.ratio = RectangleRatio(x: x, y: y, wp: wp, hp: hp)
        
        
        let label = UILabel(frame: CGRectMake(rect.size.width/2 - centerWidth/2 , rect.size.height/2 + centerHeight/2 + 8, centerWidth, 30))
        label.textAlignment = NSTextAlignment.Center
        label.textColor = UIColor.whiteColor()
        label.text = "Postion Card in this Frame"
        self.addSubview(label)
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
        self.setNeedsDisplay()
        if let subView = self.subviews.last as? UILabel {
            subView.removeFromSuperview()
        }
    }
    
    @IBAction func clickedCancelButton(sender: AnyObject) {
        delegate?.cancelFromImagePicker()
    }
    
    @IBAction func clickedSaveButton(sender: AnyObject) {
        delegate?.saveInImagePicker(self.ratio!)
    }
}
