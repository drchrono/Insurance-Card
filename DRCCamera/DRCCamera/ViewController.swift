//
//  ViewController.swift
//  DRCCamera
//
//  Created by Kan Chen on 9/28/15.
//  Copyright © 2015 Kan Chen. All rights reserved.
//

import UIKit
import DRCCameraSwift
class ViewController: UIViewController, CameraViewControllerDelegate{

    @IBOutlet weak var overlay: UIImageView!
    @IBOutlet weak var cropView: UIImageView!
    @IBOutlet weak var detectView: UIImageView!
    @IBOutlet var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBOutlet weak var click2: UIButton!
    @IBAction func click2(sender: AnyObject) {
    }
    @IBAction func click(sender: AnyObject) {
    }
    @IBAction func clickedNew(sender: AnyObject) {
        let vc = CameraViewController.ViewControllerFromNib()
        vc.delegate = self
        vc.showCaremaIfPossible(inViewController: self)
    }

    func cameraViewControllerDidTakeImage(image: UIImage?) {
        self.dismissViewControllerAnimated(true) { () -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.imageView.image = image
            })

        }
    }

}

