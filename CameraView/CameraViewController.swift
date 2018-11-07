
import UIKit

public class CameraViewController: UIViewController {
    
    public var configuration: CameraViewConfiguration!
    
    public var onPhotoPicked: ((String, CGFloat, CGFloat) -> Void)?
    
    public var onVideoPicked: ((String, TimeInterval, String, CGFloat, CGFloat) -> Void)?
    
    public override var prefersStatusBarHidden: Bool {
        return true
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        let cameraView = CameraView(configuration: configuration)
        cameraView.delegate = self
        cameraView.translatesAutoresizingMaskIntoConstraints = false
        
        cameraView.requestPermissions()
        
        view.addSubview(cameraView)
        
        if #available(iOS 11.0, *) {
            view.addConstraints([
                NSLayoutConstraint(item: cameraView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: view.safeAreaInsets.top),
                NSLayoutConstraint(item: cameraView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: -view.safeAreaInsets.bottom),
                NSLayoutConstraint(item: cameraView, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: view.safeAreaInsets.left),
                NSLayoutConstraint(item: cameraView, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1, constant: -view.safeAreaInsets.right),
            ])
        }
        else {
            view.addConstraints([
                NSLayoutConstraint(item: cameraView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: cameraView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: cameraView, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: cameraView, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1, constant: 0),
            ])
        }
        
    }
    
    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

extension CameraViewController: CameraViewDelegate {
    
    public func cameraViewDidExit(_ cameraView: CameraView) {
        dismiss(animated: true, completion: nil)
    }
    
    public func cameraViewDidPickPhoto(_ cameraView: CameraView, photoPath: String, photoWidth: CGFloat, photoHeight: CGFloat) {
        dismiss(animated: true, completion: nil)
        onPhotoPicked?(photoPath, photoWidth, photoHeight)
    }
    
    public func cameraViewDidPickVideo(_ cameraView: CameraView, videoPath: String, videoDuration: TimeInterval, photoPath: String, photoWidth: CGFloat, photoHeight: CGFloat) {
        dismiss(animated: true, completion: nil)
        onVideoPicked?(videoPath, videoDuration, photoPath, photoWidth, photoHeight)
    }
    
    public func cameraViewDidRecordDurationLessThanMinDuration(_ cameraView: CameraView) {
        print("cameraViewDidRecordDurationLessThanMinDuration")
    }
    
    public func cameraViewWillCaptureWithoutPermissions(_ cameraView: CameraView) {
        print("cameraViewWillCaptureWithoutPermissions")
    }
    
    public func cameraViewDidPermissionsGranted(_ cameraView: CameraView) {
        print("cameraViewDidPermissionsGranted")
    }
    
    public func cameraViewDidPermissionsDenied(_ cameraView: CameraView) {
        print("cameraViewDidPermissionsDenied")
    }
    
}
