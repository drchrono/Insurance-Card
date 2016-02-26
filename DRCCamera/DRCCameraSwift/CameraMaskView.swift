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
    let iPadRectPortrait: CGRect!
    let iPadRectLandscape: CGRect!

    override func drawRect(rect: CGRect) {
        
        let maskLayer = CAShapeLayer()
        let maskPath = CGPathCreateMutable()
        // draw central rect
        if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone{
            if rect.width < rect.height {
                CGPathAddRoundedRect(maskPath, nil, iphoneRectPortrait, RectangleCornerRadius, RectangleCornerRadius)
            } else {
                CGPathAddRoundedRect(maskPath, nil, iphoneRectLandscape, RectangleCornerRadius, RectangleCornerRadius)
            }
        }else{
            if rect.width < rect.height {
                CGPathAddRoundedRect(maskPath, nil, iPadRectPortrait, RectangleCornerRadius, RectangleCornerRadius)
            }else{
                CGPathAddRoundedRect(maskPath, nil, iPadRectLandscape, RectangleCornerRadius, RectangleCornerRadius)
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
            if rect.width < rect.height {
                path = UIBezierPath(roundedRect: iPadRectPortrait, cornerRadius: RectangleCornerRadius)
            } else {
                path = UIBezierPath(roundedRect: iPadRectLandscape, cornerRadius: RectangleCornerRadius)
            }
        }
        path.lineWidth = 1
        UIColor.whiteColor().setStroke()
        path.stroke()
    }
    
    override init(frame: CGRect) {
        if let rect = CameraKitConstants.singleton.iPhoneRectangleRectPortrait {
            self.iphoneRectPortrait = rect
        } else {
            self.iphoneRectPortrait = CGRect(x: 0, y: 0, width: 10, height: 10)
        }
        if let rect = CameraKitConstants.singleton.iPhoneRectangleRectLandscape {
            self.iphoneRectLandscape = rect
        } else {
            self.iphoneRectLandscape = CGRect(x: 0, y: 0, width: 10, height: 10)
        }
        if let rect = CameraKitConstants.singleton.RectangleRectProtrait {
            self.iPadRectPortrait = rect
        } else {
            self.iPadRectPortrait = CGRect(x: 0, y: 0, width: 10, height: 10)
        }
        if let rect = CameraKitConstants.singleton.RectangleRectLandscape {
            self.iPadRectLandscape = rect
        } else {
            self.iPadRectLandscape = CGRect(x: 0, y: 0, width: 10, height: 10)
        }
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        if let rect = CameraKitConstants.singleton.iPhoneRectangleRectPortrait {
            self.iphoneRectPortrait = rect
        } else {
            self.iphoneRectPortrait = CGRect(x: 0, y: 0, width: 10, height: 10)
        }
        if let rect = CameraKitConstants.singleton.iPhoneRectangleRectLandscape {
            self.iphoneRectLandscape = rect
        } else {
            self.iphoneRectLandscape = CGRect(x: 0, y: 0, width: 10, height: 10)
        }
        if let rect = CameraKitConstants.singleton.RectangleRectProtrait {
            self.iPadRectPortrait = rect
        } else {
            self.iPadRectPortrait = CGRect(x: 0, y: 0, width: 10, height: 10)
        }
        if let rect = CameraKitConstants.singleton.RectangleRectLandscape {
            self.iPadRectLandscape = rect
        } else {
            self.iPadRectLandscape = CGRect(x: 0, y: 0, width: 10, height: 10)
        }
        super.init(coder: aDecoder)
    }
}
