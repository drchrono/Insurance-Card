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
    class func scaleAndRotateImage(_ image : UIImage) -> UIImage{
        let kMaxResolution:CGFloat = 8000
        
        let imageRef = image.cgImage!
        let width:CGFloat = CGFloat(imageRef.width)
        let height:CGFloat = CGFloat(imageRef.height)
        
        var transform = CGAffineTransform.identity
        var bounds = CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height))
        
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
        let imageSize: CGSize = CGSize(width: width, height: height)
        var boundHeight: CGFloat
        let orient = image.imageOrientation
        switch orient{
        case UIImageOrientation.up: //EXIF = 1
            transform = CGAffineTransform.identity
            break
        case .upMirrored: //EXIF = 2
            transform = CGAffineTransform(translationX: imageSize.width, y: 0.0)
            transform = transform.scaleBy(x: -1.0, y: 1.0)
            break
        case .down: //EXIF = 3
            transform = CGAffineTransform(translationX: imageSize.width, y: imageSize.height)
            transform = transform.rotate(CGFloat(M_PI))
            break
        case .downMirrored: //EXIF = 4
            transform = CGAffineTransform(translationX: 0.0, y: imageSize.height)
            transform = transform.scaleBy(x: 1.0, y: -1.0)
        case .leftMirrored: //EXIF 5
            boundHeight = bounds.size.height
            bounds.size.height = bounds.size.width
            bounds.size.width = boundHeight
            transform = CGAffineTransform(translationX: imageSize.height, y: imageSize.width)
            transform = transform.scaleBy(x: -1.0, y: 1.0)
            transform = transform.rotate(CGFloat(3.0 * M_PI / 2.0))
            break
        case .left: // EXIF = 6
            boundHeight = bounds.size.height
            bounds.size.height = bounds.size.width
            bounds.size.width = boundHeight
            transform = CGAffineTransform(translationX: 0.0, y: imageSize.width)
            transform = transform.rotate(CGFloat(3.0 * M_PI / 2.0))
            break
        case .rightMirrored: //EXIF = 7
            boundHeight = bounds.size.height
            bounds.size.height = bounds.size.width
            bounds.size.width = boundHeight
            transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
            transform = transform.rotate(CGFloat( M_PI / 2.0))
            break
        case .right: //EXIF = 8
            boundHeight = bounds.size.height
            bounds.size.height = bounds.size.width
            bounds.size.width = boundHeight
            transform = CGAffineTransform(translationX: imageSize.height, y: 0.0)
            transform = transform.rotate(CGFloat(M_PI / 2.0))
            break
        }
        
        UIGraphicsBeginImageContext(bounds.size)
        let context:CGContext = UIGraphicsGetCurrentContext()!
        if orient == UIImageOrientation.right || orient == UIImageOrientation.left{
            context.scale(x: -scaleRatio, y: scaleRatio)
            context.translate(x: -height, y: 0)
        }else{
            context.scale(x: scaleRatio, y: -scaleRatio)
            context.translate(x: 0, y: -height)
        }
        context.concatCTM(transform)
        
        UIGraphicsGetCurrentContext()?.draw(in: CGRect(x: 0, y: 0, width: width, height: height), image: imageRef)
        let imageCopy: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return imageCopy
    }
    
    
    class func getImageCorrectedPerspectiv(_ image: CIImage , feature f: CIRectangleFeature) -> UIImage{
        let correctImage = image.applyingFilter("CIPerspectiveCorrection", withInputParameters: [
            "inputTopLeft": CIVector(cgPoint: f.topLeft),
            "inputTopRight": CIVector(cgPoint: f.topRight),
            "inputBottomLeft": CIVector(cgPoint: f.bottomLeft),
            "inputBottomRight": CIVector(cgPoint: f.bottomRight)])
        let context = CIContext(options: nil)
        let correctRef = context.createCGImage(correctImage, from: correctImage.extent)
        let correctUIImage = UIImage(cgImage: correctRef!)
        return correctUIImage
    }
    class func getImageCorrectedPerspectiveShrink(_ image: CIImage , feature f: CIRectangleFeature) -> UIImage{
        let horizonShrink = (f.topRight.x - f.topLeft.x) * 0.01
        let verticalShrink = (f.topRight.y - f.bottomRight.y) * 0.01
        let topLeft = CGPoint(x: f.topLeft.x + horizonShrink, y: f.topLeft.y - verticalShrink)
        let topRight = CGPoint(x: f.topRight.x - horizonShrink, y: f.topRight.y - verticalShrink)
        let bottomLeft = CGPoint(x: f.bottomLeft.x + horizonShrink, y: f.bottomLeft.y + verticalShrink)
        let bottomRight = CGPoint(x: f.bottomRight.x - horizonShrink, y: f.bottomRight.y + verticalShrink)
        let correctImage = image.applyingFilter("CIPerspectiveCorrection", withInputParameters: [
            "inputTopLeft": CIVector(cgPoint: topLeft),
            "inputTopRight": CIVector(cgPoint: topRight),
            "inputBottomLeft": CIVector(cgPoint: bottomLeft),
            "inputBottomRight": CIVector(cgPoint: bottomRight)])
        let context = CIContext(options: nil)
        let correctRef = context.createCGImage(correctImage, from: correctImage.extent)
        let correctUIImage = UIImage(cgImage: correctRef!)
        return correctUIImage
    }
}

extension UIImage{
    public func imageRotatedByDegrees(_ degrees: CGFloat, flip: Bool) -> UIImage {
        let radiansToDegrees: (CGFloat) -> CGFloat = {
            return $0 * (180.0 / CGFloat(M_PI))
        }
        let degreesToRadians: (CGFloat) -> CGFloat = {
            return $0 / 180.0 * CGFloat(M_PI)
        }
        
        // calculate the size of the rotated view's containing box for our drawing space
        let rotatedViewBox = UIView(frame: CGRect(origin: CGPoint.zero, size: size))
        let t = CGAffineTransform(rotationAngle: degreesToRadians(degrees));
        rotatedViewBox.transform = t
        let rotatedSize = rotatedViewBox.frame.size
        
        // Create the bitmap context
        UIGraphicsBeginImageContext(rotatedSize)
        let bitmap = UIGraphicsGetCurrentContext()
        
        // Move the origin to the middle of the image so we will rotate and scale around the center.
        bitmap?.translate(x: rotatedSize.width / 2.0, y: rotatedSize.height / 2.0);
        
        //   // Rotate the image context
        bitmap?.rotate(byAngle: degreesToRadians(degrees));
        
        // Now, draw the rotated/scaled image into the context
        var yFlip: CGFloat
        
        if(flip){
            yFlip = CGFloat(-1.0)
        } else {
            yFlip = CGFloat(1.0)
        }
        
        bitmap?.scale(x: yFlip, y: -1.0)
        bitmap?.draw(in: CGRect(x: -size.width / 2, y: -size.height / 2, width: size.width, height: size.height), image: cgImage!)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}
