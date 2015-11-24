//
//  CameraMaskView.swift
//  DRCCamera
//
//  Created by Kan Chen on 11/18/15.
//  Copyright © 2015 Kan Chen. All rights reserved.
//

import UIKit



class CameraMaskView: UIView {
    let RectangleCornerRadius:CGFloat = 10
    let iphoneRectPortrait: CGRect!
    let iphoneRectLandscape:CGRect!
    override func drawRect(rect: CGRect) {
        
        let maskLayer = CAShapeLayer()
        let maskPath = CGPathCreateMutable()
        // draw central rect
        if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone{
            if rect.width < rect.height{
                CGPathAddRoundedRect(maskPath, nil, iphoneRectPortrait, RectangleCornerRadius, RectangleCornerRadius)
            }else{
                CGPathAddRoundedRect(maskPath, nil, iphoneRectLandscape, RectangleCornerRadius, RectangleCornerRadius)
            }
        }else{
            if rect.width == 768 {
                CGPathAddRoundedRect(maskPath, nil, CameraKitConstants.RectangleRectProtrait, RectangleCornerRadius, RectangleCornerRadius)
            }else{
                CGPathAddRoundedRect(maskPath, nil, CameraKitConstants.RectangleRectLandscape, RectangleCornerRadius, RectangleCornerRadius)
            }
        }
        
        CGPathAddRect(maskPath, nil, rect)
        maskLayer.path = maskPath
        maskLayer.fillColor = UIColor.whiteColor().CGColor
        maskLayer.fillRule = kCAFillRuleEvenOdd
        self.layer.mask = maskLayer
        
        let path : UIBezierPath!
        if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone{
            if rect.width < rect.height{
                path = UIBezierPath(roundedRect: iphoneRectPortrait, cornerRadius: RectangleCornerRadius)
            }else{
                path = UIBezierPath(roundedRect: iphoneRectLandscape, cornerRadius: RectangleCornerRadius)
            }
        }else{
            switch rect.width{
            case 768:
                path = UIBezierPath(roundedRect: CameraKitConstants.RectangleRectProtrait, cornerRadius: RectangleCornerRadius)
            case 1024:
                path = UIBezierPath(roundedRect: CameraKitConstants.RectangleRectLandscape, cornerRadius: RectangleCornerRadius)
            default:
                path = UIBezierPath(roundedRect: CGRectMake(0, 0, 10, 10), cornerRadius: RectangleCornerRadius)
        }
        }
        path.lineWidth = 1
        UIColor.whiteColor().setStroke()
        path.stroke()
    }
    
    
    override init(frame: CGRect) {
        let constants = CameraKitConstants()
        self.iphoneRectPortrait = constants.iPhoneRectangleRectPortrait
        self.iphoneRectLandscape = constants.iPhoneRectangleRectLandscape
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        let constants = CameraKitConstants()
        self.iphoneRectPortrait = constants.iPhoneRectangleRectPortrait
        self.iphoneRectLandscape = constants.iPhoneRectangleRectLandscape
        super.init(coder: aDecoder)
    }
}
