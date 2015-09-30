//
//  ImageHandler.swift
//  DRCCamera
//
//  Created by Kan Chen on 9/28/15.
//  Copyright © 2015 Kan Chen. All rights reserved.
//

import Foundation
import UIKit

class ImageHandler {
    class func scaleAndRotateImage(image : UIImage) -> UIImage{
        let kMaxResolution:CGFloat = 8000
        
        let imageRef = image.CGImage!
        let width:CGFloat = CGFloat(CGImageGetWidth(imageRef))
        let height:CGFloat = CGFloat(CGImageGetHeight(imageRef))
        
        var transform = CGAffineTransformIdentity
        var bounds = CGRectMake(0, 0, CGFloat(width), CGFloat(height))
        
        if width > kMaxResolution || height > kMaxResolution {
            let ratio: CGFloat = width / height
            if ratio > 1 {
                bounds.size.width = kMaxResolution
                bounds.size.height = bounds.size.width / ratio
            } else {
                bounds.size.height = kMaxResolution
                bounds.size.width = bounds.size.height * ratio
            }
        }
        
        let scaleRatio = bounds.size.width / width
        let imageSize: CGSize = CGSizeMake(width, height)
        var boundHeight: CGFloat
        let orient = image.imageOrientation
        switch orient{
        case UIImageOrientation.Up: //EXIF = 1
            transform = CGAffineTransformIdentity
            break
        case .UpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0)
            transform = CGAffineTransformScale(transform, -1.0, 1.0)
            break
        case .Down: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height)
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI))
            break
        case .DownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height)
            transform = CGAffineTransformScale(transform, 1.0, -1.0)
        case .LeftMirrored: //EXIF 5
            boundHeight = bounds.size.height
            bounds.size.height = bounds.size.width
            bounds.size.width = boundHeight
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width)
            transform = CGAffineTransformScale(transform, -1.0, 1.0)
            transform = CGAffineTransformRotate(transform, CGFloat(3.0 * M_PI / 2.0))
            break
        case .Left: // EXIF = 6
            boundHeight = bounds.size.height
            bounds.size.height = bounds.size.width
            bounds.size.width = boundHeight
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width)
            transform = CGAffineTransformRotate(transform, CGFloat(3.0 * M_PI / 2.0))
            break
        case .RightMirrored: //EXIF = 7
            boundHeight = bounds.size.height
            bounds.size.height = bounds.size.width
            bounds.size.width = boundHeight
            transform = CGAffineTransformMakeScale(-1.0, 1.0)
            transform = CGAffineTransformRotate(transform, CGFloat( M_PI / 2.0))
            break
        case .Right: //EXIF = 8
            boundHeight = bounds.size.height
            bounds.size.height = bounds.size.width
            bounds.size.width = boundHeight
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0)
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI / 2.0))
            break
        }
        
        UIGraphicsBeginImageContext(bounds.size)
        let context:CGContextRef = UIGraphicsGetCurrentContext()!
        if orient == UIImageOrientation.Right || orient == UIImageOrientation.Left{
            CGContextScaleCTM(context, -scaleRatio, scaleRatio)
            CGContextTranslateCTM(context, -height, 0)
        }else{
            CGContextScaleCTM(context, scaleRatio, -scaleRatio)
            CGContextTranslateCTM(context, 0, -height)
        }
        CGContextConcatCTM(context, transform)
        
        CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imageRef)
        let imageCopy: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return imageCopy
    }
}