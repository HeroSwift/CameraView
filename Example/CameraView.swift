
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
    var flipButton = SimpleButton()
    
    var exitButton = SimpleButton()
    var captureButton = CircleView()
    
    //
    // MARK: - 选择界面
    //
    
    // 放拍好的预览图
    var previewView = PreviewView(frame: .zero)
    
    var chooseView = UIView()
    var chooseViewWidthConstraint: NSLayoutConstraint!
    
    var okButton = CircleView()
    var cancelButton = CircleView()
    
    //
    // MARK: - 录制界面 配置
    //
    
    var captureButtonCenterRadiusNormal = CGFloat(36)
    var captureButtonCenterRadiusRecording = CGFloat(24)
    var captureButtonCenterColor = UIColor.white
    var captureButtonCenterColorPressed = UIColor(red: 240 / 255, green: 240 / 255, blue: 240 / 255, alpha: 1)
    var captureButtonRingWidthNormal = CGFloat(6)
    var captureButtonRingWidthRecording = CGFloat(30)
    var captureButtonRingColor = UIColor(red: 230 / 255, green: 230 / 255, blue: 230 / 255, alpha: 1)
    var captureButtonTrackWidth = CGFloat(4)
    var captureButtonTrackColor = UIColor(red: 41 / 255, green: 181 / 255, blue: 234 / 255, alpha: 1)
    var captureButtonMarginBottom = CGFloat(50)
    
    var flipButtonMarginTop = CGFloat(24)
    var flipButtonMarginRight = CGFloat(20)
    var flashButtonMarginRight = CGFloat(14)
    var exitButtonMarginRight = CGFloat(50)
    
    
    var okButtonCenterRadius = CGFloat(38)
    var okButtonCenterColor = UIColor.white
    var okButtonRingWidth = CGFloat(0)
    
    var cancelButtonCenterRadius = CGFloat(38)
    var cancelButtonCenterColor = UIColor(red: 255 / 255, green: 255 / 255, blue: 255 / 255, alpha: 0.9)
    var cancelButtonRingWidth = CGFloat(0)
    
    
    var recordingTimer: Timer?
    
    
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
        
        cameraManager.onFlashModeChange = {
            
            switch self.cameraManager.flashMode {
            case .auto:
                self.flashButton.setImage(UIImage(named: "flash-auto"), for: .normal)
                break
            case .on:
                self.flashButton.setImage(UIImage(named: "flash-on"), for: .normal)
                break
            case .off:
                self.flashButton.setImage(UIImage(named: "flash-off"), for: .normal)
                break
            }
            
        }
        
        cameraManager.onPermissionsGranted = {
            print("onPermissionsGranted")
        }
        
        cameraManager.onPermissionsDenied = {
            print("onPermissionsDenied")
        }
        
        cameraManager.onCaptureWithoutPermissions = {
            print("onCaptureWithoutPermissions")
        }
        
        cameraManager.onRecordVideoDurationLessThanMinDuration = {
            print("onRecordVideoDurationLessThanMinDuration")
        }
        
        cameraManager.onFinishCapturePhoto =  { (photo, error) in
            if let error = error {
                print(error)
            }
            else if let photo = photo {
                self.showPreviewView()
                self.previewView.image = photo
            }
        }
        
        cameraManager.onFinishRecordVideo = { (videoPath, error) in
            if let error = error {
                print(error)
            }
            else if let videoPath = videoPath {
                self.showPreviewView()
                self.previewView.startVideoPlaying(videoPath: videoPath)
            }
            self.stopRecordingTimer()
        }
        
        addCaptureView()
        addPreviewView()
        
    }
    
    private func showPreviewView() {
        
        chooseViewWidthConstraint.constant = 230
        
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            options: .curveEaseOut,
            animations: {
                self.chooseView.layoutIfNeeded()
                self.flashButton.alpha = 0
                self.flipButton.alpha = 0
                self.captureButton.alpha = 0
                self.exitButton.alpha = 0
                self.cancelButton.alpha = 1
                self.okButton.alpha = 1
            },
            completion: { _ in
                self.flashButton.isHidden = true
                self.flipButton.isHidden = true
                self.captureButton.isHidden = true
                self.exitButton.isHidden = true
            }
        )
        
        previewView.isHidden = false
        captureView.isHidden = true
        
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
                self.flipButton.alpha = 1
                self.captureButton.alpha = 1
                self.exitButton.alpha = 1
                self.cancelButton.alpha = 0
                self.okButton.alpha = 0
            },
            completion: { _ in
                self.flashButton.isHidden = false
                self.flipButton.isHidden = false
                self.captureButton.isHidden = false
                self.exitButton.isHidden = false
            }
        )
        
        previewView.isHidden = true
        captureView.isHidden = false
        
        if previewView.image != nil {
            previewView.image = nil
        }
        else {
            previewView.stopVideoPlaying()
        }
        
        isCapturing = true
        
    }
    
    public func requestPermissions() {
        cameraManager.requestPermissions()
    }
    
    public override func layoutSubviews() {
        
        let currentDevice = UIDevice.current
        let orientation = currentDevice.orientation
        
        if !orientation.isFlat {
            cameraManager.deviceOrientation = orientation
            captureView.updateLayer(orientation: cameraManager.getVideoOrientation(deviceOrientation: orientation))
        }
        
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
                if try self.cameraManager.focus(point: $1) {
                    self.captureView.moveFocusView(to: $0)
                }
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
        
        addFlipButton()
        addFlashButton()
        
        addCaptureButton()
        addExitButton()
        
        cameraManager.prepare { error in
            if let error = error {
                print(error)
            }
            else {
                self.captureView.bind(
                    session: self.cameraManager.captureSession,
                    orientation: self.cameraManager.getVideoOrientation(deviceOrientation: self.cameraManager.deviceOrientation)
                )
                self.cameraIsReady = true
            }
        }
        
    }

    private func addFlipButton() {
        
        flipButton.setImage(UIImage(named: "camera-flip"), for: .normal)
        flipButton.translatesAutoresizingMaskIntoConstraints = false

        addSubview(flipButton)
        
        addConstraints([
            NSLayoutConstraint(item: flipButton, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: flipButtonMarginTop),
            NSLayoutConstraint(item: flipButton, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: -flipButtonMarginRight),
            NSLayoutConstraint(item: flipButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 50),
            NSLayoutConstraint(item: flipButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 44),
        ])
        
        flipButton.onClick = {
            switch self.cameraManager.cameraPosition {
            case .front:
                try? self.cameraManager.switchToBackCamera()
                break
            case .back:
                try? self.cameraManager.switchToFrontCamera()
                break
            case .unspecified:
                try? self.cameraManager.switchToBackCamera()
                break
            }
        }
        
    }
    
    private func addFlashButton() {
        
        flashButton.setImage(UIImage(named: "flash-off"), for: .normal)
        flashButton.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(flashButton)
        
        addConstraints([
            NSLayoutConstraint(item: flashButton, attribute: .centerY, relatedBy: .equal, toItem: flipButton, attribute: .centerY, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: flashButton, attribute: .right, relatedBy: .equal, toItem: flipButton, attribute: .left, multiplier: 1, constant: -flashButtonMarginRight),
            NSLayoutConstraint(item: flashButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 50),
            NSLayoutConstraint(item: flashButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 44),
        ])
        
        flashButton.onClick = {
            switch self.cameraManager.flashMode {
            case .auto:
                self.cameraManager.setFlashMode(.on)
                break
            case .on:
                self.cameraManager.setFlashMode(.off)
                break
            case .off:
                self.cameraManager.setFlashMode(.auto)
                break
            }
        }
        
    }
    
    private func addCaptureButton() {
        
        captureButton.delegate = self
        captureButton.centerRadius = captureButtonCenterRadiusNormal
        captureButton.centerColor = captureButtonCenterColor
        captureButton.ringWidth = captureButtonRingWidthNormal
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
        
        exitButton.setImage(UIImage(named: "exit"), for: .normal)
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(exitButton)
        
        addConstraints([
            NSLayoutConstraint(item: exitButton, attribute: .centerY, relatedBy: .equal, toItem: captureButton, attribute: .centerY, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: exitButton, attribute: .right, relatedBy: .equal, toItem: captureButton, attribute: .left, multiplier: 1, constant: -exitButtonMarginRight),
            NSLayoutConstraint(item: exitButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 50),
            NSLayoutConstraint(item: exitButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 44),
        ])
        
    }
    
    private func addPreviewView() {
        
        previewView.isHidden = true
        previewView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(previewView)
        
        addConstraints([
            NSLayoutConstraint(item: previewView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: previewView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: previewView, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: previewView, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: 0),
        ])
        
        addChooseView()
        
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
        okButton.centerImage = UIImage(named: "ok")
        
        okButton.translatesAutoresizingMaskIntoConstraints = false
        chooseView.addSubview(okButton)

        chooseView.addConstraints([
            NSLayoutConstraint(item: okButton, attribute: .right, relatedBy: .equal, toItem: chooseView, attribute: .right, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: okButton, attribute: .centerY, relatedBy: .equal, toItem: chooseView, attribute: .centerY, multiplier: 1, constant: 0),
        ])
        
    }
    
    private func addCancelButton() {
        
        cancelButton.alpha = 0
        cancelButton.delegate = self
        cancelButton.centerRadius = cancelButtonCenterRadius
        cancelButton.centerColor = cancelButtonCenterColor
        cancelButton.ringWidth = cancelButtonRingWidth
        cancelButton.centerImage = UIImage(named: "cancel")
        
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        chooseView.addSubview(cancelButton)
        
        chooseView.addConstraints([
            NSLayoutConstraint(item: cancelButton, attribute: .left, relatedBy: .equal, toItem: chooseView, attribute: .left, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: cancelButton, attribute: .centerY, relatedBy: .equal, toItem: chooseView, attribute: .centerY, multiplier: 1, constant: 0),
        ])
        
    }
    
}

//
// MARK: - 录制视频的定时器
//

extension CameraView {
    
    func startRecordingTimer() {
        recordingTimer = Timer.scheduledTimer(timeInterval: 1 / 60, target: self, selector: #selector(CameraView.onRecordingDurationUpdate), userInfo: nil, repeats: true)
        print("start timer")
        
        captureButton.centerRadius = captureButtonCenterRadiusRecording
        captureButton.ringWidth = captureButtonRingWidthRecording
        captureButton.sizeToFit()
        captureButton.setNeedsLayout()
        captureButton.setNeedsDisplay()
    }
    
    private func stopRecordingTimer() {
        guard let timer = recordingTimer else {
            return
        }
        timer.invalidate()
        self.recordingTimer = nil
        print("stop timer")
        
        captureButton.centerRadius = captureButtonCenterRadiusNormal
        captureButton.ringWidth = captureButtonRingWidthNormal
        captureButton.trackValue = 0
        captureButton.sizeToFit()
        captureButton.setNeedsLayout()
        captureButton.setNeedsDisplay()
    }
    
    @objc private func onRecordingDurationUpdate() {
        guard let output = cameraManager.videoOutput else {
            return
        }
        
        let currentTime = output.recordedDuration.seconds
        captureButton.trackValue = currentTime / cameraManager.maxVideoDuration
        captureButton.setNeedsDisplay()
        
        if currentTime >= cameraManager.maxVideoDuration {
            cameraManager.stopVideoRecording()
        }
        
    }
    
}

//
// MARK: - 圆形按钮的事件响应
//

extension CameraView: CircleViewDelegate {
    
    public func circleViewDidTouchDown(_ circleView: CircleView) {
        
    }
    
    public func circleViewDidLongPressStart(_ circleView: CircleView) {
        if circleView == captureButton {
            cameraManager.startVideoRecording()
            startRecordingTimer()
        }
    }
    
    public func circleViewDidLongPressEnd(_ circleView: CircleView) {
        if circleView == captureButton {
            cameraManager.stopVideoRecording()
        }
    }
    
    public func circleViewDidTouchUp(_ circleView: CircleView, _ inside: Bool, _ isLongPress: Bool) {
        if inside && !isLongPress {
            if circleView == captureButton {
                cameraManager.capturePhoto()
            }
            else if circleView == cancelButton {
                hidePreviewView()
            }
        }
    }
    
}
