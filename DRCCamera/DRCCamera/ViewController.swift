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
    @IBAction func click2(_ sender: AnyObject) {
    }
    @IBAction func click(_ sender: AnyObject) {
    }
    @IBAction func clickedNew(_ sender: AnyObject) {
        let vc = CameraViewController.viewControllerFromNib()
        vc.delegate = self
        vc.showCaremaIfPossible(inViewController: self)
    }

    func cameraViewController(_ cameraViewController: CameraViewController, didTakeImage image: UIImage?) {
        self.imageView.image = image
    }

}

