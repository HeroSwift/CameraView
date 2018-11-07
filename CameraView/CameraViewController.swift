
import UIKit

public class CameraViewController: UIViewController {
    
    private var cameraView: CameraView!
    
    public convenience init(configuration: CameraViewConfiguration, delegate: CameraViewDelegate) {
        
        self.init()
        
        self.cameraView = CameraView(configuration: configuration)
        cameraView.delegate = delegate

    }
    
    public override var prefersStatusBarHidden: Bool {
        return true
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
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


