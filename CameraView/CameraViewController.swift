
import UIKit

public class CameraViewController: UIViewController {
    
    public var configuration: CameraViewConfiguration!
    
    public var onPhotoPicked: ((String) -> Void)?
    
    public var onVideoPicked: ((String, Int) -> Void)?
    
    public override var prefersStatusBarHidden: Bool {
        return true
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        let cameraView = CameraView(configuration: configuration)
        cameraView.delegate = self
        cameraView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(cameraView)
        
        cameraView.requestPermissions()
        
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
    
    public func cameraViewDidSubmit(_ cameraView: CameraView, _ filePath: String, _ duration: TimeInterval) {
        dismiss(animated: true, completion: nil)
    }
}
