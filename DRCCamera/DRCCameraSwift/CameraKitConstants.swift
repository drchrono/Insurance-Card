//
//  CameraKitConstants.swift
//  DRCCamera
//
//  Created by Kan Chen on 11/18/15.
//  Copyright © 2015 Kan Chen. All rights reserved.
//

import Foundation

struct CameraKitConstants {
    static let RectangleSizeProtrait = CGSize(width: 568, height: 355)
    static let RectangleRectProtrait = CGRectMake(100, 334.5, 568, 355)
    static let RectangleRectLandscape = CGRectMake(228, 206.5, 568, 355)
    static let RectangleRectRatio = RectangleRatio(x: 100 / 768, y: 334.5 / 1024, wp: 568 / 768, hp: 355 / 1024)
    static let DetectionRectangleRatio = RectangleRatio(x: 84 / 768, y: (334.5 + 10) / 1024, wp: 600 / 768, hp: (355 + 20) / 1024)
    static let RectangleRectLandscapeRatio = RectangleRatio(x: 228/1024, y: 206.5/768, wp: 568/1024, hp: 355/768)
    static let DetectionRectangleLandscapeRatio = RectangleRatio(x: 212/1024, y: (206.5+10)/768, wp: 600/1024, hp: (355+20)/768)
}

