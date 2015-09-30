//
//  ViewController.swift
//  DRCCamera
//
//  Created by Kan Chen on 9/28/15.
//  Copyright © 2015 Kan Chen. All rights reserved.
//

import UIKit

class ViewController: UIViewController , DRCCustomImagePickerControllerDelegate{

    @IBOutlet weak var detectView: UIImageView!
    @IBOutlet var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func click(sender: AnyObject) {
        let customPicker = DRCCustomImagePickerController()
        customPicker.customDelegate = self
        customPicker.showImagePicker(inViewController: self)
        customPicker.enableImageDetecting = true
    }
    
    func customImagePickerDidFinishPickingImage(rectImage: UIImage, detectedRectImage: UIImage?) {
        imageView.image = rectImage
        detectView.image = detectedRectImage
    }
}
