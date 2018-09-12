
import UIKit

public class CameraView: UIView {
    
    var cameraManager = CameraManager()
    
    //
    // MARK: - 拍摄界面
    //
    
    var captureView = UIView()
    
    var flashButton = SimpleButton()
    var positionButton = SimpleButton()
    
    var exitButton = SimpleButton()
    var captureButton = CircleView()
    
    //
    // MARK: - 选择界面
    //
    
    
    
    // 放拍好的预览图
    var photoView = UIImageView()

    var chooseView = UIView()
    var chooseViewWidthConstraint: NSLayoutConstraint!
    
    var okButton = SimpleButton()
    var cancelButton = SimpleButton()
    
    //
    // MARK: - 录制界面 配置
    //
    
    var captureButtonCenterRadius = CGFloat(30)
    var captureButtonCenterColor = UIColor.white
    var captureButtonCenterColorPressed = UIColor(red: 240 / 255, green: 240 / 255, blue: 240 / 255, alpha: 1)
    var captureButtonRingWidth = CGFloat(4)
    var captureButtonRingColor = UIColor(red: 230 / 255, green: 230 / 255, blue: 230 / 255, alpha: 1)
    var captureButtonTrackColor = UIColor(red: 41 / 255, green: 181 / 255, blue: 234 / 255, alpha: 1)
    var captureButtonMarginBottom = CGFloat(50)
    
    var positionButtonMarginTop = CGFloat(40)
    var positionButtonMarginRight = CGFloat(40)
    var flashButtonMarginRight = CGFloat(20)
    var exitButtonMarginRight = CGFloat(40)
    
    
    
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        
        backgroundColor = .clear
        
        addCaptureView()
        addPreviewView()
        
    }
    
    private func showPreviewView() {
        
        chooseViewWidthConstraint.constant = bounds.width / 2
        
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            options: .curveEaseOut,
            animations: {
                self.chooseView.layoutIfNeeded()
                self.cancelButton.alpha = 1
                self.okButton.alpha = 1
            },
            completion: nil
        )
        
        captureButton.isHidden = true
        exitButton.isHidden = true
        flashButton.isHidden = true
        positionButton.isHidden = true
        
        // 拍照预览
        if photoView.image != nil {
            photoView.isHidden = false
            captureView.isHidden = true
        }
        
    }
    
    private func hidePreviewView() {
        
        chooseViewWidthConstraint.constant = 0
        
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            options: .curveEaseOut,
            animations: {
                self.chooseView.layoutIfNeeded()
                self.cancelButton.alpha = 0
                self.okButton.alpha = 0
            },
            completion: { _ in
                self.captureButton.isHidden = false
                self.exitButton.isHidden = false
            }
        )
        
        flashButton.isHidden = false
        positionButton.isHidden = false
        
        // 拍照预览
        if photoView.image != nil {
            photoView.isHidden = true
            captureView.isHidden = false
            photoView.image = nil
        }
        
    }
    
}

//
// MARK: - 界面搭建
//

extension CameraView {
    
    private func addCaptureView() {
        
        captureView.translatesAutoresizingMaskIntoConstraints = false
        captureView.backgroundColor = .red
        addSubview(captureView)
        
        addConstraints([
            NSLayoutConstraint(item: captureView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: captureView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: captureView, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: captureView, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: 0),
        ])
        
        addPositionButton()
        addFlashButton()
        
        addCaptureButton()
        addExitButton()
        
        cameraManager.prepare { error in
            if let error = error {
                print(error)
            }
            else {
                try? self.cameraManager.displayPreview(on: self.captureView)
            }
        }
        
    }

    private func addPositionButton() {
        
        positionButton.setTitle("后", for: .normal)
        positionButton.backgroundColor = .blue
        positionButton.translatesAutoresizingMaskIntoConstraints = false

        addSubview(positionButton)
        
        addConstraints([
            NSLayoutConstraint(item: positionButton, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: positionButtonMarginTop),
            NSLayoutConstraint(item: positionButton, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: -positionButtonMarginRight),
        ])
        
        positionButton.onClick = {
            switch self.cameraManager.cameraPosition {
            case .front:
                try? self.cameraManager.switchToBackCamera()
                self.positionButton.setTitle("后", for: .normal)
                break
            case .back:
                try? self.cameraManager.switchToFrontCamera()
                self.positionButton.setTitle("前", for: .normal)
                break
            case .unspecified:
                try? self.cameraManager.switchToBackCamera()
                break
            }
        }
        
    }
    
    private func addFlashButton() {
        
        flashButton.setTitle("off", for: .normal)
        flashButton.backgroundColor = UIColor.cyan
        flashButton.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(flashButton)
        
        addConstraints([
            NSLayoutConstraint(item: flashButton, attribute: .centerY, relatedBy: .equal, toItem: positionButton, attribute: .centerY, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: flashButton, attribute: .right, relatedBy: .equal, toItem: positionButton, attribute: .left, multiplier: 1, constant: -flashButtonMarginRight),
        ])
        
        flashButton.onClick = {
            switch self.cameraManager.flashMode {
            case .auto:
                self.cameraManager.flashMode = .on
                self.flashButton.setTitle("on", for: .normal)
                break
            case .on:
                self.cameraManager.flashMode = .off
                self.flashButton.setTitle("off", for: .normal)
                break
            case .off:
                self.cameraManager.flashMode = .auto
                self.flashButton.setTitle("auto", for: .normal)
                break
            }
        }
        
    }
    
    private func addCaptureButton() {
        
        captureButton.delegate = self
        captureButton.centerRadius = captureButtonCenterRadius
        captureButton.centerColor = captureButtonCenterColor
        captureButton.ringWidth = captureButtonRingWidth
        captureButton.ringColor = captureButtonRingColor
        captureButton.trackWidth = captureButtonRingWidth
        captureButton.trackColor = captureButtonTrackColor
        
        captureButton.sizeToFit()
        captureButton.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(captureButton)
        
        addConstraints([
            NSLayoutConstraint(item: captureButton, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: captureButton, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: -captureButtonMarginBottom),
        ])
        
    }
    
    private func addExitButton() {
        
        exitButton.setTitle("退出", for: .normal)
        exitButton.backgroundColor = UIColor.brown
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(exitButton)
        
        addConstraints([
            NSLayoutConstraint(item: exitButton, attribute: .centerY, relatedBy: .equal, toItem: captureButton, attribute: .centerY, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: exitButton, attribute: .right, relatedBy: .equal, toItem: captureButton, attribute: .left, multiplier: 1, constant: -exitButtonMarginRight),
        ])
        
    }
    
    private func addPreviewView() {
        
        addPhotoView()
        addChooseView()
        
    }
    
    private func addPhotoView() {
        
        photoView.translatesAutoresizingMaskIntoConstraints = false
        photoView.backgroundColor = .green
        photoView.isHidden = true
        addSubview(photoView)
        
        addConstraints([
            NSLayoutConstraint(item: photoView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: photoView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: photoView, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: photoView, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: 0),
        ])
        
    }
    
    private func addChooseView() {
        
        chooseView.translatesAutoresizingMaskIntoConstraints = false
        chooseView.backgroundColor = UIColor.red

        addSubview(chooseView)
        
        chooseViewWidthConstraint = NSLayoutConstraint(item: chooseView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 0)
        
        addConstraints([
            NSLayoutConstraint(item: chooseView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 100),
            NSLayoutConstraint(item: chooseView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: chooseView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0),
            chooseViewWidthConstraint
        ])

        addOkButton()
        addCancelButton()
        
    }
    
    private func addOkButton() {
        
        okButton.setTitle("OK", for: .normal)
        okButton.backgroundColor = UIColor.brown
        okButton.translatesAutoresizingMaskIntoConstraints = false
        chooseView.addSubview(okButton)

        addConstraints([
            NSLayoutConstraint(item: okButton, attribute: .left, relatedBy: .equal, toItem: chooseView, attribute: .left, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: okButton, attribute: .centerY, relatedBy: .equal, toItem: chooseView, attribute: .centerY, multiplier: 1, constant: 0),
        ])
        
        okButton.onClick = {
            
        }
        
    }
    
    private func addCancelButton() {
        
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.backgroundColor = UIColor.blue
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        chooseView.addSubview(cancelButton)
        
        addConstraints([
            NSLayoutConstraint(item: cancelButton, attribute: .right, relatedBy: .equal, toItem: chooseView, attribute: .right, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: cancelButton, attribute: .centerY, relatedBy: .equal, toItem: chooseView, attribute: .centerY, multiplier: 1, constant: 0),
        ])
        
        cancelButton.onClick = {
            self.hidePreviewView()
        }
        
    }
    
}

//
// MARK: - 点击事件
//

extension CameraView {
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let first = touches.first else {
            return
        }
        
        // 坐标计算参考文档 https://developer.apple.com/documentation/avfoundation/avcapturedevice/1385853-focuspointofinterest
        // 焦点 (0,0) 表示画面的左上角，(1, 1) 表示画面的右下角
        // 这套坐标系统的计算基于横屏的设备状态，并且 home 键在右边，而无视设备当前真实的横竖屏状态

        // 因为我们是竖屏应用
        // 因此这里需要坐标转换
        let point = (first as UITouch).location(in: captureView)
        let screenSize = captureView.bounds.size
        
        let x = point.y / screenSize.height
        let y = 1 - point.x / screenSize.width
        
        print("\(x) \(y) \(point) \(screenSize)")
        
        try! cameraManager.focus(point: CGPoint(x: x, y: y))
        
    }
}

//
// MARK: - 圆形按钮的事件响应
//

extension CameraView: CircleViewDelegate {
    
    public func circleViewDidTouchDown(_ circleView: CircleView) {
        
    }
    
    public func circleViewDidTouchUp(_ circleView: CircleView, _ inside: Bool) {
        if inside {
            cameraManager.capturePhoto { (photo, error) in
                if let error = error {
                    print(error)
                }
                else if let photo = photo {
                    self.photoView.image = photo
                    self.showPreviewView()
                }
            }
        }
    }
    
}
