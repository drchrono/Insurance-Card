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

    override func draw(_ rect: CGRect) {
        
        let maskLayer = CAShapeLayer()
        let maskPath = CGMutablePath()
        // draw central rect
        if UIDevice.current().userInterfaceIdiom == UIUserInterfaceIdiom.phone{
            if rect.width < rect.height {
                maskPath.addRoundedRect(nil, rect: iphoneRectPortrait, cornerWidth: RectangleCornerRadius, cornerHeight: RectangleCornerRadius)
            } else {
                maskPath.addRoundedRect(nil, rect: iphoneRectLandscape, cornerWidth: RectangleCornerRadius, cornerHeight: RectangleCornerRadius)
            }
        }else{
            if rect.width < rect.height {
                maskPath.addRoundedRect(nil, rect: iPadRectPortrait, cornerWidth: RectangleCornerRadius, cornerHeight: RectangleCornerRadius)
            }else{
                maskPath.addRoundedRect(nil, rect: iPadRectLandscape, cornerWidth: RectangleCornerRadius, cornerHeight: RectangleCornerRadius)
            }
        }
        
        maskPath.addRect(nil, rect: rect)
        maskLayer.path = maskPath
        maskLayer.fillColor = UIColor.white().cgColor
        maskLayer.fillRule = kCAFillRuleEvenOdd
        self.layer.mask = maskLayer
        
        let path : UIBezierPath!
        if UIDevice.current().userInterfaceIdiom == UIUserInterfaceIdiom.phone{
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
        UIColor.white().setStroke()
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
