//
//  ViewController.swift
//  Example
//
//  Created by zhujl on 2018/9/12.
//  Copyright © 2018年 finstao. All rights reserved.
//

import UIKit
import AVFoundation
import CameraView

class ViewController: UIViewController {

    var cameraViewController: CameraViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        AVCaptureDevice.requestAccess(for: .video) { granted in
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func openCamera(_ sender: Any) {
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            print("authorized")
            break
            
        case .notDetermined:
            print("notDetermined")
            break
            
        default:
            print("notDetermined")
            break
        }
        
        let cameraViewController = CameraViewController()
        cameraViewController.configuration = CameraViewConfiguration()
        cameraViewController.delegate = self
        
        present(cameraViewController, animated: true, completion: nil)
        
        self.cameraViewController = cameraViewController
        
    }
    
}

extension ViewController: CameraViewDelegate {
    
    // 点击退出按钮
    func cameraViewDidExit(_ viewController: CameraViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }

    // 点击确定按钮选择照片
    func cameraViewDidCapturePhoto(_ viewController: CameraViewController, photoPath: String, photoSize: Int, photoWidth: Int, photoHeight: Int) {
        print("photo: \(photoPath) \(photoSize/(1024*1024)) \(photoWidth) \(photoHeight)")
    }
    
    // 点击确定按钮选择视频
    func cameraViewDidRecordVideo(_ viewController: CameraViewController, videoPath: String, videoSize: Int, videoDuration: Int, photoPath: String, photoSize: Int, photoWidth: Int, photoHeight: Int) {
        print("video: \(videoPath) \(Float(videoSize)/(1024*1024)) \(videoDuration)")
        print("photo: \(photoPath) \(Float(photoSize)/(1024*1024)) \(photoWidth) \(photoHeight)")
    }
    
    // 录制视频时间太短
    func cameraViewDidRecordDurationLessThanMinDuration(_ viewController: CameraViewController) {
        
    }
    
}

