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

    var cameraViewController: CameraViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func openCamera(_ sender: Any) {
        
        let cameraViewController = CameraViewController(configuration: CameraViewConfiguration(), delegate: self)
        
        present(cameraViewController, animated: true, completion: nil)
        
        self.cameraViewController = cameraViewController
        
    }
    
}

extension ViewController: CameraViewDelegate {
    
    public func cameraViewDidExit(_ cameraView: CameraView) {
        cameraViewController?.dismiss(animated: true, completion: nil)
    }
}

