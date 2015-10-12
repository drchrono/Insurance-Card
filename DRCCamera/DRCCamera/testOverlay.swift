//
//  testOverlay.swift
//  DRCCamera
//
//  Created by Kan Chen on 10/1/15.
//  Copyright © 2015 Kan Chen. All rights reserved.
//

import UIKit

class testOverlay: UIView {

    @IBOutlet weak var width: NSLayoutConstraint!
    @IBOutlet weak var height: NSLayoutConstraint!
    @IBOutlet weak var centerView: CenterView!
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    override func awakeFromNib() {
        let newRect = calculatePosition().0
        self.width.constant = newRect.width
        self.height.constant = newRect.height
        self.layoutIfNeeded()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "deviceOrientationChangedNotification:", name: UIDeviceOrientationDidChangeNotification, object: nil)
    }
    
    func deviceOrientationChangedNotification(note : NSNotification){
        guard let _ = self.superview else {
            return
        }
        
        let newRect = calculatePosition().0
        let duration:NSTimeInterval = 0.2
//        CATransaction.begin()
//        CATransaction.setValue(duration, forKey: kCATransactionAnimationDuration)
        
//        self.centerView.layer.mask?.position = newRect.origin
//        self.centerView.layer.mask?.bounds = CGRectMake(0, 0, newRect.width , newRect.height)
//        CATransaction.commit()

        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.width.constant = newRect.width
            self.height.constant = newRect.height
            self.layoutIfNeeded()
            }) { (success:Bool) -> Void in
                if !success {
                    print("no animation")
                }
        }
        
        
    }

    func calculatePosition() -> (CGRect,CGRect,CGAffineTransform){
        let rect = UIScreen.mainScreen().bounds
        var sideMargin:CGFloat = 30.0
        if (UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad) {
            // iPad
            sideMargin = 100
            //TODO: check landscape and protrait
        }
        let centerWidth = rect.size.width - 2 * sideMargin
        let centerHeight = centerWidth / 1.6
        let labelRect: CGRect
        let labelTransform: CGAffineTransform
        let rectInCenter: CGRect
        
        if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone
            && (UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeLeft || UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeRight)  {
                print("Device current is \(UIDevice.currentDevice().orientation.rawValue)")
                let rectW:CGFloat = 250
                let rectH:CGFloat = 400
                rectInCenter = CGRectMake((rect.width - rectW) / 2,(rect.height - rectH) / 2 , rectW, rectH)
                
                                // end calculation
                if UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeLeft{
                    labelRect = CGRectMake(15 - rectInCenter.height/2 + (rect.width/2 - rectW/2-30-8), rect.height/2 - 15, rectH, 30)
                    labelTransform = CGAffineTransformMakeRotation(CGFloat(M_PI_2))
                }else{
                    labelRect = CGRectMake(rect.width - 15 - rectInCenter.height/2 - (rect.width/2 - rectW/2-30-8), rect.height/2 - 15, rectH, 30)
                    labelTransform = CGAffineTransformMakeRotation(CGFloat(-M_PI_2))
                }
                
        } else {
            rectInCenter = CGRectMake(rect.size.width/2 - centerWidth/2, rect.size.height/2 - centerHeight/2, centerWidth  , centerHeight)
            
                       // end calculation
            labelRect = CGRectMake(rect.size.width/2 - centerWidth/2 , rect.size.height/2 + centerHeight/2 + 8, centerWidth, 30)
            labelTransform = CGAffineTransformIdentity
        }
        return (rectInCenter, labelRect, labelTransform)
    }

}
