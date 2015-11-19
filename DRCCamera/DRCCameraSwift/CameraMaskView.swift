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
    override func drawRect(rect: CGRect) {
        let maskLayer = CAShapeLayer()
        let maskPath = CGPathCreateMutable()
        if rect.width == 768 {
        CGPathAddRoundedRect(maskPath, nil, CameraKitConstants.RectangleRectProtrait, RectangleCornerRadius, RectangleCornerRadius)
        }else{
             CGPathAddRoundedRect(maskPath, nil, CameraKitConstants.RectangleRectLandscape, RectangleCornerRadius, RectangleCornerRadius)
        }
        CGPathAddRect(maskPath, nil, rect)
        maskLayer.path = maskPath
        maskLayer.fillColor = UIColor.whiteColor().CGColor
        maskLayer.fillRule = kCAFillRuleEvenOdd
        self.layer.mask = maskLayer
        
        let path : UIBezierPath!
        switch rect.width{
        case 768:
            path = UIBezierPath(roundedRect: CameraKitConstants.RectangleRectProtrait, cornerRadius: RectangleCornerRadius)
        case 1024:
            path = UIBezierPath(roundedRect: CameraKitConstants.RectangleRectLandscape, cornerRadius: RectangleCornerRadius)
        default:
            path = UIBezierPath(roundedRect: CGRectMake(0, 0, 10, 10), cornerRadius: RectangleCornerRadius)
        }
        
        path.lineWidth = 1
        UIColor.whiteColor().setStroke()
        path.stroke()
    }
    

}
