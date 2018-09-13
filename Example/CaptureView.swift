
import UIKit

public class CaptureView: UIView {
    
    var onFocusPointChange: ((_ tapPoint: CGPoint, _ focusPoint: CGPoint) -> Void)?
    var onZoomStart: (() -> Void)?
    var onZoomFactorChange: ((_ zoomFactor: CGFloat) -> Void)?
    
    private let focusView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        
        backgroundColor = .black
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGesture(tap:)))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.delegate = self
        addGestureRecognizer(tapGesture)
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinchGesture(pinch:)))
        pinchGesture.delegate = self
        addGestureRecognizer(pinchGesture)
        
        focusView.backgroundColor = .white
        focusView.isHidden = true
        focusView.alpha = 0
        addSubview(focusView)
        
    }
    
    func moveFocusView(to point: CGPoint) {
        
        focusView.isHidden = false
        focusView.center = point
        focusView.transform = CGAffineTransform(scaleX: 2, y: 2)
        
        UIView.animateKeyframes(withDuration: 1.5, delay: 0, options: .calculationModeLinear, animations: {
            
            // 淡入，从放大状态到真实尺寸
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.2, animations: {
                self.focusView.alpha = 1
                self.focusView.transform = CGAffineTransform.identity
            })
            
            // 淡出
            UIView.addKeyframe(withRelativeStartTime: 0.8, relativeDuration: 0.2, animations: {
                self.focusView.alpha = 0
            })
            
        }, completion: { success in
            if success {
                self.focusView.isHidden = true
            }
        })
        
    }
    
    @objc private func tapGesture(tap: UITapGestureRecognizer) {
        
        // 坐标计算参考文档 https://developer.apple.com/documentation/avfoundation/avcapturedevice/1385853-focuspointofinterest
        // 焦点 (0,0) 表示画面的左上角，(1, 1) 表示画面的右下角
        // 这套坐标系统的计算基于横屏的设备状态，并且 home 键在右边，而无视设备当前真实的横竖屏状态
        
        let screenSize = bounds.size
        
        let tapPoint = tap.location(in: self)
        let x = tapPoint.y / screenSize.height
        let y = 1 - tapPoint.x / screenSize.width
        let focusPoint = CGPoint(x: x, y: y)
        
        onFocusPointChange?(tapPoint, focusPoint)

    }
    
    @objc private func pinchGesture(pinch: UIPinchGestureRecognizer) {
        onZoomFactorChange?(pinch.scale)
    }
    
}

extension CaptureView: UIGestureRecognizerDelegate {
    
    public override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer is UIPinchGestureRecognizer {
            onZoomStart?()
        }
        return true
    }
    
}

