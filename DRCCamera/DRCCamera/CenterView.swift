//
//  CenterView.swift
//  DRCCamera
//
//  Created by Kan Chen on 10/1/15.
//  Copyright © 2015 Kan Chen. All rights reserved.
//

import UIKit

class CenterView: UIView {

    
    override func drawRect(rect: CGRect) {
//        let path2 = UIBezierPath(roundedRect: rect, cornerRadius: 10)
//        path2.lineWidth = 1
//        UIColor.whiteColor().setStroke()
//        path2.stroke()
//        addMask()
        let masklayer = CAShapeLayer()
        let path = CGPathCreateMutable()
        masklayer.frame = rect
        CGPathAddRect(path, nil, CGRectInset(rect, 0, 0))
        CGPathAddRoundedRect(path, nil, CGRectInset(rect, 1, 1), 5, 20)
        masklayer.fillColor = UIColor.whiteColor().CGColor
        masklayer.path = path
        masklayer.fillRule = kCAFillRuleEvenOdd
//        self.layer.masksToBounds = true
        
        self.layer.mask = masklayer
            }
    
    override func awakeFromNib() {
//        let rect = self.bounds
       

    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
//        self.backgroundColor = UIColor.clearColor()
        self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
//        addMask()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
//        self.backgroundColor = UIColor.clearColor()
        self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
//        addMask()
    }
    
//    func addMask(){
//        let rect = self.bounds
//        let masklayer = CAShapeLayer()
//        let path = CGPathCreateMutable()
//        masklayer.bounds = rect
//        CGPathAddRect(path, nil, CGRectInset(rect, 0, 0))
//        CGPathAddRoundedRect(path, nil, CGRectInset(rect, 1, 1), 10, 10)
//        masklayer.fillColor = UIColor.whiteColor().CGColor
//        masklayer.path = path
//        masklayer.fillRule = kCAFillRuleEvenOdd
//        
//        self.layer.mask = masklayer
//
//    }
    
}
