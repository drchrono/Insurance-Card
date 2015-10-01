//
//  ViewController.swift
//  DRCCamera
//
//  Created by Kan Chen on 9/28/15.
//  Copyright © 2015 Kan Chen. All rights reserved.
//

import UIKit

class ViewController: UIViewController , DRCCustomImagePickerControllerDelegate{

    @IBOutlet weak var overlay: UIImageView!
    @IBOutlet weak var cropView: UIImageView!
    @IBOutlet weak var detectView: UIImageView!
    @IBOutlet var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        let rectView = CenterView(frame: CGRectInset(self.view.bounds, 100, 100))
//        rectView.backgroundColor = UIColor.clearColor()
//        self.view.addSubview(rectView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    var picker: DRCCustomImagePickerController?

    @IBOutlet weak var click2: UIButton!
    @IBAction func click2(sender: AnyObject) {
        let customPicker = DRCCustomImagePickerController()
        customPicker.customDelegate = self
        customPicker.showImagePicker(inViewController: self)
        customPicker.enableImageDetecting = true
//        customPicker.method = 1
        self.picker = customPicker
    }
    @IBAction func click(sender: AnyObject) {
        let customPicker = DRCCustomImagePickerController()
        customPicker.customDelegate = self
        customPicker.showImagePicker(inViewController: self)
        customPicker.enableImageDetecting = true
//        customPicker.method = 0
        self.picker = customPicker
    }
    
    func customImagePickerDidFinishPickingImage(rectImage: UIImage, detectedRectImage: UIImage?) {
        imageView.image = rectImage
        detectView.image = detectedRectImage
        
        if let image = picker?.testImage {
            
            cropView.image = image
        }
        if let image = picker?.overlay{
            overlay.image = image
        }
    }
}

