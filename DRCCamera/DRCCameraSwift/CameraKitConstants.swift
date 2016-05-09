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
    static let singleton : CameraKitConstants = CameraKitConstants()
    let RectangleRectProtrait : CGRect?
    let RectangleRectLandscape : CGRect?
    // ipad and ipadPro ratio are same, because Rect in iPad Pro is scaled
    static let RectangleRectRatio = RectangleRatio(x: 100 / 768, y: 334.5 / 1024, wp: 568 / 768, hp: 355 / 1024)
    static let DetectionRectangleRatio = RectangleRatio(x: 84 / 768, y: (334.5 + 10) / 1024, wp: 600 / 768, hp: (355 + 20) / 1024)
    static let RectangleRectLandscapeRatio = RectangleRatio(x: 228/1024, y: 206.5/768, wp: 568/1024, hp: 355/768)
    static let DetectionRectangleLandscapeRatio = RectangleRatio(x: 212/1024, y: (206.5+10)/768, wp: 600/1024, hp: (355+20)/768)

    let iphoneRectangleRatio: RectangleRatio?
    let iphoneRectangleLandscapeRatio: RectangleRatio?
    let iPhoneRectangleRectPortrait: CGRect?
    let iPhoneRectangleRectLandscape: CGRect?

    init () {
        if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone {
            let iphoneSize = UIScreen.mainScreen().bounds.size
            if iphoneSize.width < iphoneSize.height{
                let longEdge = iphoneSize.height
                let shortEdge = iphoneSize.width
                let width = shortEdge - 60
                let height = width / 1.6
                iPhoneRectangleRectPortrait = CGRectMake(30, (longEdge - height)/2 , width, height)
                iPhoneRectangleRectLandscape = CGRectMake( (longEdge - width)/2, (shortEdge - height)/2, width , height)
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
                iPhoneRectangleRectPortrait = CGRectMake(30, (longEdge - height)/2 , width , height)
                iPhoneRectangleRectLandscape = CGRectMake((longEdge - width)/2, (shortEdge - height)/2, width, height)
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
        if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad {
            let iPadDeviceSize = UIScreen.mainScreen().bounds.size
            if iPadDeviceSize == CGSize(width: 1024, height: 768) || iPadDeviceSize == CGSize(width: 768, height: 1024) {
                //iPad normal
                RectangleRectProtrait = CGRect(x: 100, y: 334.5, width: 568, height: 355)
                RectangleRectLandscape = CGRect(x: 228, y: 206.5, width: 568, height: 355)
            } else if iPadDeviceSize == CGSize(width: 1366, height: 1024) || iPadDeviceSize == CGSize(width: 1024, height: 1366) {
                //iPad Pro
                RectangleRectProtrait = CGRect(x: 133, y: 446, width: 758, height: 474)
                RectangleRectLandscape = CGRect(x: 304, y: 275, width: 758, height: 474)
            } else {
                // Unkown
                RectangleRectProtrait = nil
                RectangleRectLandscape = nil
            }
        } else {
            RectangleRectProtrait = nil
            RectangleRectLandscape = nil
        }
    }

    func initForIphone(){

    }

    
}

