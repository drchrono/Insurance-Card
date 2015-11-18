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
        CGPathAddRoundedRect(maskPath, nil, CameraKitConstants.RectangleRectProtrait, RectangleCornerRadius, RectangleCornerRadius)
        CGPathAddRect(maskPath, nil, rect)
        maskLayer.path = maskPath
        maskLayer.fillColor = UIColor.whiteColor().CGColor
        maskLayer.fillRule = kCAFillRuleEvenOdd
        self.layer.mask = maskLayer
        
        let path = UIBezierPath(roundedRect: CameraKitConstants.RectangleRectProtrait, cornerRadius: RectangleCornerRadius)
        path.lineWidth = 1
        UIColor.whiteColor().setStroke()
        path.stroke()
    }
    

}
