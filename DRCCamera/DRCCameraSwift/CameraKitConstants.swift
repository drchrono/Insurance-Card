//
//  CameraKitConstants.swift
//  DRCCamera
//
//  Created by Kan Chen on 11/18/15.
//  Copyright © 2015 Kan Chen. All rights reserved.
//

import Foundation

struct RectangleRatio {
    var x:CGFloat
    var y:CGFloat
    var wp:CGFloat
    var hp:CGFloat

    init (x: CGFloat,y:CGFloat, wp:CGFloat, hp:CGFloat) {
        self.x = x
        self.y = y
        self.wp = wp
        self.hp = hp
    }

    init () {
        self.x = 0
        self.y = 0
        self.wp = 0
        self.hp = 0
    }
}

struct CameraKitConstants {
    static let shared : CameraKitConstants = CameraKitConstants()
    /// `rect` of the transparent rectangle in the center of MaskView in protrait mode
    let rectangleRectInProtrait : CGRect?
    /// `rect` of the transparent rectangle in the center of MaskView in landscape mode
    let rectangleRectInLandscape : CGRect?
    // ipad and ipadPro ratio are same, because Rect in iPad Pro is scaled
    static let rectangleRectRatioInProtrait = RectangleRatio(x: 100 / 768, y: 334.5 / 1024, wp: 568 / 768, hp: 355 / 1024)
    static let detectionRectangleRatioInProtrait = RectangleRatio(x: 84 / 768, y: (334.5 + 10) / 1024, wp: 600 / 768, hp: (355 + 20) / 1024)
    static let rectangleRectRatioInLandscape = RectangleRatio(x: 228/1024, y: 206.5/768, wp: 568/1024, hp: 355/768)
    static let detectionRectangleRatioInLandscape = RectangleRatio(x: 212/1024, y: (206.5+10)/768, wp: 600/1024, hp: (355+20)/768)

    let iphoneRectangleRatio: RectangleRatio?
    let iphoneRectangleLandscapeRatio: RectangleRatio?
    let iPhoneRectangleRectPortrait: CGRect?
    let iPhoneRectangleRectLandscape: CGRect?

    init () {
        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone {
            let iphoneSize = UIScreen.main.bounds.size
            if iphoneSize.width < iphoneSize.height{
                let longEdge = iphoneSize.height
                let shortEdge = iphoneSize.width
                let width = shortEdge - 60
                let height = width / 1.6
                iPhoneRectangleRectPortrait = CGRect(x: 30, y: (longEdge - height)/2 , width: width, height: height)
                iPhoneRectangleRectLandscape = CGRect( x: (longEdge - width)/2, y: (shortEdge - height)/2, width: width , height: height)
                let videoWidth = iphoneSize.width
                let videoHeight = videoWidth * 4 / 3
                iphoneRectangleRatio = RectangleRatio(x: 30 / videoWidth,
                    y: (videoHeight - height) / 2 / videoHeight,
                    wp: width / videoWidth,
                    hp: height / videoHeight)
                iphoneRectangleLandscapeRatio = RectangleRatio(x: (videoHeight - width) / 2 / videoHeight,
                    y: (videoWidth - height)/2/videoWidth,
                    wp: width / videoHeight,
                    hp: height / videoWidth)
            }else{
                let longEdge = iphoneSize.width
                let shortEdge = iphoneSize.height
                let width = shortEdge - 60
                let height = width / 1.6
                iPhoneRectangleRectPortrait = CGRect(x: 30, y: (longEdge - height)/2 , width: width , height: height)
                iPhoneRectangleRectLandscape = CGRect(x: (longEdge - width)/2, y: (shortEdge - height)/2, width: width, height: height)
                let videoHeight = shortEdge
                let videoWidth = videoHeight * 4 / 3
                iphoneRectangleRatio = RectangleRatio(x: (shortEdge - width)/2/shortEdge,
                    y: (videoWidth - height) / 2 / videoWidth,
                    wp: width / videoHeight,
                    hp: height / videoWidth)
                iphoneRectangleLandscapeRatio = RectangleRatio(x: (videoWidth - width)/2/videoWidth,
                    y: (videoHeight - height) / 2 / videoHeight,
                    wp: width / videoWidth,
                    hp: height / videoHeight)
            }
        } else {
            iphoneRectangleLandscapeRatio = nil
            iphoneRectangleRatio = nil
            iPhoneRectangleRectLandscape = nil
            iPhoneRectangleRectPortrait = nil
        }
        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad {
            let iPadDeviceSize = UIScreen.main.bounds.size
            if iPadDeviceSize == CGSize(width: 1024, height: 768) || iPadDeviceSize == CGSize(width: 768, height: 1024) {
                //iPad normal
                rectangleRectInProtrait = CGRect(x: 100, y: 334.5, width: 568, height: 355)
                rectangleRectInLandscape = CGRect(x: 228, y: 206.5, width: 568, height: 355)
            } else if iPadDeviceSize == CGSize(width: 1366, height: 1024) || iPadDeviceSize == CGSize(width: 1024, height: 1366) {
                //iPad Pro
                rectangleRectInProtrait = CGRect(x: 133, y: 446, width: 758, height: 474)
                rectangleRectInLandscape = CGRect(x: 304, y: 275, width: 758, height: 474)
            } else if iPadDeviceSize == CGSize(width: 1112, height: 834) || iPadDeviceSize == CGSize(width: 834, height: 1112) {
                // iPad 10.5 inch
                rectangleRectInProtrait = CGRect(x: 109, y: 363.5, width: 616, height: 385)
                rectangleRectInLandscape = CGRect(x: 248, y: 224.5, width: 616, height: 385)
            } else {
                let longEdge = max(iPadDeviceSize.width, iPadDeviceSize.height)
                let shortEdge = min(iPadDeviceSize.width, iPadDeviceSize.height)
                let rectWidth = round(shortEdge * 0.74)
                let rectHeight = round(rectWidth / 1.6)
                rectangleRectInProtrait = CGRect(origin: CGPoint(x: round((shortEdge - rectWidth)/2), y: round((longEdge - rectHeight)/2)),
                                                 size: CGSize(width: rectWidth, height: rectHeight))
                rectangleRectInLandscape = CGRect(origin: CGPoint(x: round((longEdge - rectWidth)/2), y: round((shortEdge - rectHeight)/2)),
                                                  size: CGSize(width: rectWidth, height: rectHeight))
            }
        } else {
            rectangleRectInProtrait = nil
            rectangleRectInLandscape = nil
        }
    }
}

