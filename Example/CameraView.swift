
import UIKit

public class CameraView: UIView {
    
    var cameraManager = CameraManager()
    
    var cameraIsReady = false
    
    var isCapturing = true
    
    //
    // MARK: - 拍摄界面
    //
    
    var captureView = CaptureView()
    
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
    
    var okButton = CircleView()
    var cancelButton = CircleView()
    
    //
    // MARK: - 录制界面 配置
    //
    
    var captureButtonCenterRadius = CGFloat(36)
    var captureButtonCenterColor = UIColor.white
    var captureButtonCenterColorPressed = UIColor(red: 240 / 255, green: 240 / 255, blue: 240 / 255, alpha: 1)
    var captureButtonRingWidth = CGFloat(6)
    var captureButtonRingColor = UIColor(red: 230 / 255, green: 230 / 255, blue: 230 / 255, alpha: 1)
    var captureButtonTrackWidth = CGFloat(6)
    var captureButtonTrackColor = UIColor(red: 41 / 255, green: 181 / 255, blue: 234 / 255, alpha: 1)
    var captureButtonMarginBottom = CGFloat(70)
    
    var positionButtonMarginTop = CGFloat(40)
    var positionButtonMarginRight = CGFloat(30)
    var flashButtonMarginRight = CGFloat(30)
    var exitButtonMarginRight = CGFloat(40)
    
    
    var okButtonCenterRadius = CGFloat(30)
    var okButtonCenterColor = UIColor(red: 230 / 255, green: 230 / 255, blue: 230 / 255, alpha: 1)
    var okButtonCenterColorPressed = UIColor(red: 240 / 255, green: 240 / 255, blue: 240 / 255, alpha: 1)
    var okButtonRingWidth = CGFloat(0)
    
    var cancelButtonCenterRadius = CGFloat(30)
    var cancelButtonCenterColor = UIColor(red: 230 / 255, green: 230 / 255, blue: 230 / 255, alpha: 1)
    var cancelButtonCenterColorPressed = UIColor(red: 240 / 255, green: 240 / 255, blue: 240 / 255, alpha: 1)
    var cancelButtonRingWidth = CGFloat(0)
    
    
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
                self.flashButton.alpha = 0
                self.positionButton.alpha = 0
                self.captureButton.alpha = 0
                self.exitButton.alpha = 0
                self.cancelButton.alpha = 1
                self.okButton.alpha = 1
            },
            completion: { _ in
                self.flashButton.isHidden = true
                self.positionButton.isHidden = true
                self.captureButton.isHidden = true
                self.exitButton.isHidden = true
            }
        )
        
        // 拍照预览
        if photoView.image != nil {
            photoView.isHidden = false
            captureView.isHidden = true
        }
        
        isCapturing = false
        
    }
    
    private func hidePreviewView() {
        
        chooseViewWidthConstraint.constant = 0
        
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            options: .curveEaseOut,
            animations: {
                self.chooseView.layoutIfNeeded()
                self.flashButton.alpha = 1
                self.positionButton.alpha = 1
                self.captureButton.alpha = 1
                self.exitButton.alpha = 1
                self.cancelButton.alpha = 0
                self.okButton.alpha = 0
            },
            completion: { _ in
                self.flashButton.isHidden = false
                self.positionButton.isHidden = false
                self.captureButton.isHidden = false
                self.exitButton.isHidden = false
            }
        )
        
        // 拍照预览
        if photoView.image != nil {
            photoView.isHidden = true
            captureView.isHidden = false
            photoView.image = nil
        }
        
        isCapturing = true
        
    }
    
}

//
// MARK: - 界面搭建
//

extension CameraView {
    
    private func addCaptureView() {
        
        captureView.translatesAutoresizingMaskIntoConstraints = false
        
        captureView.onFocusPointChange = {
            guard self.cameraIsReady, self.isCapturing else {
                return
            }
            do {
                try self.cameraManager.focus(point: $1)
                self.captureView.moveFocusView(to: $0)
            }
            catch {
                print(error.localizedDescription)
            }
        }
        
        captureView.onZoomStart = {
            self.cameraManager.startZoom()
        }
        
        captureView.onZoomFactorChange = {
            try! self.cameraManager.zoom(factor: $0)
        }
        
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
                do {
                    try self.cameraManager.displayPreview(on: self.captureView)
                    self.cameraIsReady = true
                }
                catch {
                    print(error.localizedDescription)
                }
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
        captureButton.trackWidth = captureButtonTrackWidth
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
        
        photoView.isHidden = true
        photoView.backgroundColor = .black
        photoView.translatesAutoresizingMaskIntoConstraints = false
        photoView.contentMode = .scaleAspectFit
        
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
        chooseView.clipsToBounds = true
        addSubview(chooseView)
        
        chooseViewWidthConstraint = NSLayoutConstraint(item: chooseView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 0)
        
        addOkButton()
        addCancelButton()
        
        addConstraints([
            NSLayoutConstraint(item: chooseView, attribute: .height, relatedBy: .equal, toItem: okButton, attribute: .height, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: chooseView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: chooseView, attribute: .centerY, relatedBy: .equal, toItem: captureButton, attribute: .centerY, multiplier: 1, constant: 0),
            chooseViewWidthConstraint
        ])
        
    }
    
    private func addOkButton() {
        
        okButton.alpha = 0
        okButton.delegate = self
        okButton.centerRadius = okButtonCenterRadius
        okButton.centerColor = okButtonCenterColor
        okButton.ringWidth = okButtonRingWidth
        
        okButton.translatesAutoresizingMaskIntoConstraints = false
        chooseView.addSubview(okButton)

        chooseView.addConstraints([
            NSLayoutConstraint(item: okButton, attribute: .left, relatedBy: .equal, toItem: chooseView, attribute: .left, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: okButton, attribute: .centerY, relatedBy: .equal, toItem: chooseView, attribute: .centerY, multiplier: 1, constant: 0),
        ])
        
    }
    
    private func addCancelButton() {
        
        cancelButton.alpha = 0
        cancelButton.delegate = self
        cancelButton.centerRadius = cancelButtonCenterRadius
        cancelButton.centerColor = cancelButtonCenterColor
        cancelButton.ringWidth = cancelButtonRingWidth
        
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        chooseView.addSubview(cancelButton)
        
        chooseView.addConstraints([
            NSLayoutConstraint(item: cancelButton, attribute: .right, relatedBy: .equal, toItem: chooseView, attribute: .right, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: cancelButton, attribute: .centerY, relatedBy: .equal, toItem: chooseView, attribute: .centerY, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: cancelButton, attribute: .centerY, relatedBy: .equal, toItem: chooseView, attribute: .centerY, multiplier: 1, constant: 0),
        ])
        
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
            if circleView == captureButton {
                cameraManager.capturePhoto { (photo, error) in
                    if let error = error {
                        print(error)
                    }
                    else if let photo = photo {
                        print(photo)
                        self.photoView.image = photo
                        self.showPreviewView()
                    }
                }
            }
            else if circleView == cancelButton {
                hidePreviewView()
            }
        }
    }
    
}
