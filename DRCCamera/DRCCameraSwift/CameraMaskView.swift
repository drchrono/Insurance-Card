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
        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone {
            if rect.width < rect.height {
                maskPath.__addRoundedRect(transform: nil, rect: iphoneRectPortrait, cornerWidth: RectangleCornerRadius, cornerHeight: RectangleCornerRadius)
            } else {
                maskPath.__addRoundedRect(transform: nil, rect: iphoneRectLandscape, cornerWidth: RectangleCornerRadius, cornerHeight: RectangleCornerRadius)
            }
        }else{
            if rect.width < rect.height {
                maskPath.__addRoundedRect(transform: nil, rect: iPadRectPortrait, cornerWidth: RectangleCornerRadius, cornerHeight: RectangleCornerRadius)
            }else{
                maskPath.__addRoundedRect(transform: nil, rect: iPadRectLandscape, cornerWidth: RectangleCornerRadius, cornerHeight: RectangleCornerRadius)
            }
        }
        maskPath.addRect(rect)
//        CGPathAddRect(maskPath, nil, rect)
        maskLayer.path = maskPath
        maskLayer.fillColor = UIColor.white.cgColor
        maskLayer.fillRule = CAShapeLayerFillRule.evenOdd
        self.layer.mask = maskLayer
        
        let path : UIBezierPath!
        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone{
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
        UIColor.white.setStroke()
        path.stroke()
    }
    
    override init(frame: CGRect) {
        if let rect = CameraKitConstants.shared.iPhoneRectangleRectPortrait {
            self.iphoneRectPortrait = rect
        } else {
            self.iphoneRectPortrait = CGRect(x: 0, y: 0, width: 10, height: 10)
        }
        if let rect = CameraKitConstants.shared.iPhoneRectangleRectLandscape {
            self.iphoneRectLandscape = rect
        } else {
            self.iphoneRectLandscape = CGRect(x: 0, y: 0, width: 10, height: 10)
        }
        if let rect = CameraKitConstants.shared.rectangleRectInProtrait {
            self.iPadRectPortrait = rect
        } else {
            self.iPadRectPortrait = CGRect(x: 0, y: 0, width: 10, height: 10)
        }
        if let rect = CameraKitConstants.shared.rectangleRectInLandscape {
            self.iPadRectLandscape = rect
        } else {
            self.iPadRectLandscape = CGRect(x: 0, y: 0, width: 10, height: 10)
        }
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        if let rect = CameraKitConstants.shared.iPhoneRectangleRectPortrait {
            self.iphoneRectPortrait = rect
        } else {
            self.iphoneRectPortrait = CGRect(x: 0, y: 0, width: 10, height: 10)
        }
        if let rect = CameraKitConstants.shared.iPhoneRectangleRectLandscape {
            self.iphoneRectLandscape = rect
        } else {
            self.iphoneRectLandscape = CGRect(x: 0, y: 0, width: 10, height: 10)
        }
        if let rect = CameraKitConstants.shared.rectangleRectInProtrait {
            self.iPadRectPortrait = rect
        } else {
            self.iPadRectPortrait = CGRect(x: 0, y: 0, width: 10, height: 10)
        }
        if let rect = CameraKitConstants.shared.rectangleRectInLandscape {
            self.iPadRectLandscape = rect
        } else {
            self.iPadRectLandscape = CGRect(x: 0, y: 0, width: 10, height: 10)
        }
        super.init(coder: aDecoder)
    }
}
