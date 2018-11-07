//
//  ViewController.swift
//  Example
//
//  Created by zhujl on 2018/9/12.
//  Copyright © 2018年 finstao. All rights reserved.
//

import UIKit
import CameraView

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func openCamera(_ sender: Any) {
        
        let cameraViewController = CameraViewController()
        cameraViewController.configuration = CameraViewConfiguration()
        
        cameraViewController.onPhotoPicked = { photoPath, photoWidth, photoHeight in
            print("\(photoPath) \(photoWidth) \(photoHeight)")
        }
        
        cameraViewController.onVideoPicked = { videoPath, videoDuration, photoPath, photoWidth, photoHeight in
            print("\(videoPath) \(videoDuration) \(photoPath) \(photoWidth) \(photoHeight)")
        }
        
        present(cameraViewController, animated: true, completion: nil)
    }
    
}

