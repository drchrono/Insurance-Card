//
//  CenterView.swift
//  DRCCamera
//
//  Created by Kan Chen on 10/1/15.
//  Copyright © 2015 Kan Chen. All rights reserved.
//

import UIKit

class CenterView: UIView {
    
    let b = test()
    let c = OCViewController()
//    let a = G8Tesseract()
    override func drawRect(rect: CGRect) {
        let path = UIBezierPath(roundedRect: rect, cornerRadius: kCornerRadius)
        path.lineWidth = 1
        UIColor.whiteColor().setStroke()
        path.stroke()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.clearColor()
    }
    
}
