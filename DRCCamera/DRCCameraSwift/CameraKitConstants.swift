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
    static let RectangleRectRatio = RectangleRatio(x: 100 / 768, y: 334.5 / 1024, wp: 568 / 768, hp: 355 / 1024)
    static let DetectionRectangleRatio = RectangleRatio(x: 84 / 768, y: (334.5 + 10) / 1024, wp: 600 / 768, hp: (355 + 20) / 1024)
}

