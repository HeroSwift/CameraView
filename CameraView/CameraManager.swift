
import UIKit
import AVFoundation

// 支持拍照，录视频

class CameraManager : NSObject {
    
    var captureSession = AVCaptureSession()
    
    // 前摄
    var frontCamera: AVCaptureDevice?
    var frontCameraInput: AVCaptureDeviceInput?
    
    // 后摄
    var backCamera: AVCaptureDevice?
    var backCameraInput: AVCaptureDeviceInput?
    
    // 麦克风
    var microphone: AVCaptureDevice?
    var microphoneInput: AVCaptureDeviceInput?
    
    // 二维码
    var metadataInput: AVCaptureMetadataInput?
    
    // 兼容 9 和 10+
    var photoOutput: AVCaptureOutput?
    var videoOutput: AVCaptureMovieFileOutput?
    var metadataOutput: AVCaptureMetadataOutput?
    
    var backgroundRecordingId: UIBackgroundTaskIdentifier?
    
    // 缩放
    var zoomFactor = CGFloat(0) {
        didSet {
            DispatchQueue.main.async {
                self.onZoomFactorChange?()
            }
        }
    }
    
    var lastZoomFactor = CGFloat(1)
    var minZoomFactor = CGFloat(1)
    var maxZoomFactor = CGFloat(5)
    
    // MARK: - 通用配置
    
    // 设备状态
    var deviceOrientation = UIDeviceOrientation.portrait
    
    // 预设
    var preset = AVCaptureSession.Preset.high
    
    // 暗光环境下开启自动增强
    var lowHightBoost = true
    
    // 当前的闪光灯模式
    var flashMode = AVCaptureDevice.FlashMode.off {
        didSet {
            DispatchQueue.main.async {
                self.onFlashModeChange?()
            }
        }
    }
    
    // 当前使用的摄像头
    var cameraPosition = AVCaptureDevice.Position.unspecified {
        didSet {
            DispatchQueue.main.async {
                self.onCameraPositionChange?()
            }
        }
    }
    
    // MARK: - 录制视频的配置
    
    // 保存视频文件的目录
    var videoDir = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!
    
    // 当前正在录制的视频文件路径
    var videoPath = ""
    
    var videoExtname = ".mp4"
    
    // 录制视频的最小时长，单位为秒
    var minVideoDuration = Double(1)
    
    // 录制视频的最大时长，单位为秒
    var maxVideoDuration = Double(10)
    
    
    
    //
    // MARK: - 拍照的配置
    //
    
    // Whether to capture still images at the highest resolution supported by the active device and format.
    var isHighResolutionEnabled = true
    
    // 是否可用 live 图片
    var liveMode = CameraLiveMode.off
    
    // live 图片的保存目录
    var livePhotoDir = NSTemporaryDirectory()
    
    
    
    //
    // MARK: - 回调
    //
    
    var onFlashModeChange: (() -> Void)?
    
    var onCameraPositionChange: (() -> Void)?
    
    var onZoomFactorChange: (() -> Void)?
    
    var onPermissionsGranted: (() -> Void)?
    
    var onPermissionsDenied: (() -> Void)?
    
    var onCaptureWithoutPermissions: (() -> Void)?
    
    var onRecordVideoDurationLessThanMinDuration: (() -> Void)?
    
    var onFinishCapturePhoto: ((UIImage?, Error?) -> Void)?
    
    var onFinishRecordVideo: ((String?, Error?) -> Void)?
    
    
    
    //
    // MARK: - 计算属性
    //
    
    // 当前使用的摄像头
    var currentCamera: AVCaptureDevice? {
        get {
            return cameraPosition == .back ? backCamera : frontCamera
        }
    }
    
}

extension CameraManager {
    
    // 申请权限
    func requestPermissions() {
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            // 已授权
            break
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    self.onPermissionsGranted?()
                }
                else {
                    self.onPermissionsDenied?()
                }
            }
            break
        default:
            // 拒绝
            break
        }
    }
    
    // 拍照
    func capturePhoto() {
        
        if #available(iOS 10.0, *) {
            capturePhoto10()
        }
        else {
            capturePhoto9()
        }
        
    }
    
    // 录制视频
    func startVideoRecording() {
        
        guard let output = videoOutput, !output.isRecording else {
            return
        }
        
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: videoDir) {
            try? fileManager.createDirectory(atPath: videoDir, withIntermediateDirectories: true, attributes: nil)
        }
        
        if UIDevice.current.isMultitaskingSupported {
            backgroundRecordingId = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
        }
        
        let connection = output.connection(with: .video)
        if cameraPosition == .front {
            connection?.isVideoMirrored = true
        }
        
        connection?.videoOrientation = getVideoOrientation(deviceOrientation: deviceOrientation)
        
        if flashMode == .on {
            setTorchMode(.on)
        }
        else if flashMode == .auto {
            setTorchMode(.auto)
        }
        
        let format = DateFormatter()
        format.dateFormat = "yyyy_MM_dd_HH_mm_ss"
        
        videoPath = "\(videoDir)/\(format.string(from: Date()))\(videoExtname)"
        
        output.startRecording(to: URL(fileURLWithPath: videoPath), recordingDelegate: self)
        
    }
    
    func stopVideoRecording() {
        
        guard let output = videoOutput, output.isRecording else {
            return
        }
        
        output.stopRecording()
        
    }
    
    func switchToFrontCamera() throws {
        
        try configureSession { isRunning in
            
            guard let device = frontCamera else {
                throw CameraError.invalidOperation
            }
            
            if let input = backCameraInput {
                removeInput(input)
            }
            
            frontCameraInput = try addInput(device: device)
            
            captureSession.sessionPreset = captureSession.canSetSessionPreset(preset) ? preset : .high
            
            flashMode = .off
            zoomFactor = 1
            cameraPosition = .front
            
        }
        
    }
    
    func switchToBackCamera() throws {
        
        try configureSession { isRunning in
            
            guard let device = backCamera else {
                throw CameraError.invalidOperation
            }
            
            if let input = frontCameraInput {
                removeInput(input)
            }
            
            backCameraInput = try addInput(device: device)
            
            captureSession.sessionPreset = captureSession.canSetSessionPreset(preset) ? preset : .high
            
            flashMode = .off
            zoomFactor = 1
            cameraPosition = .back
            
        }
        
    }
    
    func setFlashMode(_ flashMode: AVCaptureDevice.FlashMode) {
        
        guard let device = currentCamera else {
            return
        }
        
        if #available(iOS 10.0, *) {
            if let output = photoOutput {
                if (output as! AVCapturePhotoOutput).supportedFlashModes.contains(flashMode) {
                    self.flashMode = flashMode
                }
            }
        }
        else {
            if device.isFlashModeSupported(flashMode) {
                self.flashMode = flashMode
            }
        }
        
    }
    
    func setTorchMode(_ torchMode: AVCaptureDevice.TorchMode) {
        
        guard let device = currentCamera, device.hasTorch else {
            return
        }
        
        do {
            try configureDevice(device) {
                device.torchMode = torchMode
                if torchMode == .on {
                    try device.setTorchModeOn(level: 1.0)
                }
            }
        }
        catch {
            print(error.localizedDescription)
        }
        
    }
    
    
    
    // 镜头聚焦
    func focus(point: CGPoint) throws -> Bool {
        
        guard let device = currentCamera else {
            return false
        }
        
        let isFocusPointOfInterestSupported = device.isFocusPointOfInterestSupported
        let isExposurePointOfInterestSupported = device.isExposurePointOfInterestSupported
        
        if isFocusPointOfInterestSupported || isExposurePointOfInterestSupported {
            
            try device.lockForConfiguration()
            
            if isFocusPointOfInterestSupported {
                device.focusPointOfInterest = point
            }
            
            if isExposurePointOfInterestSupported {
                device.exposurePointOfInterest = point
            }
            
            device.unlockForConfiguration()
            
            return true
            
        }
        
        return false
        
    }
    
    // 开始缩放，记录当前缩放值作为初始值
    func startZoom() {
        lastZoomFactor = zoomFactor
    }
    
    // 缩放预览窗口
    func zoom(factor: CGFloat) throws {
        
        guard let device = currentCamera else {
            return
        }
        
        try device.lockForConfiguration()
        
        zoomFactor = min(maxZoomFactor, max(minZoomFactor, min(lastZoomFactor * factor, device.activeFormat.videoMaxZoomFactor)))
        
        device.videoZoomFactor = zoomFactor
        
        device.unlockForConfiguration()
        
    }
    
    func prepare(completionHandler: @escaping (Error?) -> Void) {
        
        if AVCaptureDevice.authorizationStatus(for: .video) != .authorized {
            onCaptureWithoutPermissions?()
        }
        
        // 枚举音视频设备
        func configureCaptureDevices() throws {
            
            let devices: [AVCaptureDevice]
            
            if #available(iOS 10.0, *) {
                let session = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .unspecified)
                devices = session.devices
            }
            else {
                devices = AVCaptureDevice.devices(for: .video)
            }
            
            for camera in devices {
                if camera.position == .front {
                    frontCamera = camera
                    try configureDevice(camera)
                }
                else if camera.position == .back {
                    backCamera = camera
                    try configureDevice(camera)
                }
            }
            
            microphone = AVCaptureDevice.default(for: .audio)
            
        }
        func configureDeviceInputs() throws {
            if let microphone = microphone {
                microphoneInput = try addInput(device: microphone)
            }
            if cameraPosition != .front {
                try switchToBackCamera()
            }
            else {
                try switchToFrontCamera()
            }
        }
        func configurePhotoOutput() throws {
            
            let settings = [AVVideoCodecKey: AVVideoCodecJPEG]
            
            if #available(iOS 10.0, *) {
                let photoOutput = AVCapturePhotoOutput()
                if captureSession.canAddOutput(photoOutput) {
                    photoOutput.isHighResolutionCaptureEnabled = isHighResolutionEnabled
                    photoOutput.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: settings)], completionHandler: nil)
                    if !photoOutput.isLivePhotoCaptureSupported {
                        liveMode = .unavailable
                    }
                    
                    captureSession.addOutput(photoOutput)
                    self.photoOutput = photoOutput
                }
            }
            else {
                let photoOutput = AVCaptureStillImageOutput()
                if captureSession.canAddOutput(photoOutput) {
                    photoOutput.outputSettings = settings
                    captureSession.addOutput(photoOutput)
                    self.photoOutput = photoOutput
                }
            }
            
        }
        func configureVideoOutput() throws {
            
            let videoOutput = AVCaptureMovieFileOutput()
            
            if captureSession.canAddOutput(videoOutput) {
                captureSession.addOutput(videoOutput)
                if let connection = videoOutput.connection(with: .video) {
                    if connection.isVideoStabilizationSupported {
                        connection.preferredVideoStabilizationMode = .auto
                    }
                }
                self.videoOutput = videoOutput
            }
        }
        
        
        DispatchQueue(label: "prepare").async {
            
            do {
                try configureCaptureDevices()
                try configureDeviceInputs()
                try configurePhotoOutput()
                try configureVideoOutput()
                self.captureSession.startRunning()
            }
            catch {
                DispatchQueue.main.async {
                    completionHandler(error)
                }
                return
            }
            
            DispatchQueue.main.async {
                completionHandler(nil)
            }
            
        }
    }
    
}

// 拍照
@available(iOS 10.0, *)
extension CameraManager: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?,
                     previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?,
                     resolvedSettings: AVCaptureResolvedPhotoSettings,
                     bracketSettings: AVCaptureBracketedStillImageSettings?,
                     error: Error?
        ) {
        
        if let error = error {
            onFinishCapturePhoto?(nil, error)
        }
        else if let buffer = photoSampleBuffer,
            let data = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: buffer, previewPhotoSampleBuffer: nil),
            let image = UIImage(data: data) {
            onFinishCapturePhoto?(image, nil)
        }
        else {
            onFinishCapturePhoto?(nil, CameraError.unknown)
        }
        
    }
}

// 录制视频
extension CameraManager: AVCaptureFileOutputRecordingDelegate {
    
    public func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        
        if let taskId = backgroundRecordingId {
            UIApplication.shared.endBackgroundTask(taskId)
            backgroundRecordingId = nil
        }
        
        if flashMode != .off {
            setTorchMode(.off)
        }
        
        var success = false
        
        if error == nil {
            if output.recordedDuration.seconds >= minVideoDuration {
                success = true
                onFinishRecordVideo?(videoPath, nil)
            }
            else {
                onRecordVideoDurationLessThanMinDuration?()
                onFinishRecordVideo?(nil, nil)
            }
        }
        else {
            onFinishRecordVideo?(nil, error)
        }
        
        if !success {
            try! FileManager.default.removeItem(atPath: videoPath)
            videoPath = ""
        }
        
    }
    
}

// 识别二维码
extension CameraManager: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection
        ) {
        
        if metadataObjects.count == 0 {
            return
        }
        
        let metadataObject = metadataObjects[0]
        
        if metadataObject.type == AVMetadataObject.ObjectType.qr {
            
            let qrcodeObject = metadataObject as! AVMetadataMachineReadableCodeObject
            
            if let stringValue = qrcodeObject.stringValue {
                
            }
            
        }
        
    }
}

// 工具方法
extension CameraManager {
    
    private func configureSession(callback: (_ isRunning: Bool) throws -> Void) throws {
        
        if captureSession.isRunning {
            
            captureSession.beginConfiguration()
            
            try callback(true)
            
            captureSession.commitConfiguration()
            
        }
        else {
            try callback(false)
        }
        
    }
    
    private func configureDevice(_ device: AVCaptureDevice, callback: () throws -> Void) throws {
        
        try device.lockForConfiguration()
        
        try callback()
        
        device.unlockForConfiguration()
        
    }
    
    private func configureDevice(_ device: AVCaptureDevice) throws {
        
        try configureDevice(device) {
            
            if device.isFocusModeSupported(.continuousAutoFocus) {
                device.focusMode = .continuousAutoFocus
            }
            if device.isSmoothAutoFocusSupported {
                device.isSmoothAutoFocusEnabled = true
            }
            if device.isExposureModeSupported(.continuousAutoExposure) {
                device.exposureMode = .continuousAutoExposure
            }
            if device.isWhiteBalanceModeSupported(.continuousAutoWhiteBalance) {
                device.whiteBalanceMode = .continuousAutoWhiteBalance
            }
            if device.isLowLightBoostSupported && lowHightBoost {
                device.automaticallyEnablesLowLightBoostWhenAvailable = true
            }
            
        }
        
    }
    
    private func addInput(device: AVCaptureDevice) throws -> AVCaptureDeviceInput {
        
        let input = try AVCaptureDeviceInput(device: device)
        
        if captureSession.canAddInput(input) {
            captureSession.addInput(input)
        }
        else {
            throw CameraError.inputsAreInvalid
        }
        
        return input
        
    }
    
    private func removeInput(_ input: AVCaptureDeviceInput) {
        
        if captureSession.inputs.contains(input) {
            captureSession.removeInput(input)
        }
        
    }
    
    func getVideoOrientation(deviceOrientation: UIDeviceOrientation) -> AVCaptureVideoOrientation {
        
        switch deviceOrientation {
        case .landscapeLeft:
            return .landscapeRight
        case .landscapeRight:
            return .landscapeLeft
        case .portraitUpsideDown:
            return .portraitUpsideDown
        default:
            return .portrait
        }
        
    }
    
    func getImageOrientation(deviceOrientation: UIDeviceOrientation) -> UIImageOrientation {
        
        let isBackCamera = cameraPosition == .back
        
        switch deviceOrientation {
        case .landscapeLeft:
            return isBackCamera ? .up : .downMirrored
        case .landscapeRight:
            return isBackCamera ? .down : .upMirrored
        case .portraitUpsideDown:
            return isBackCamera ? .left : .rightMirrored
        default:
            return isBackCamera ? .right : .leftMirrored
        }
        
    }
    
}

// 兼容 ios9 和 ios10+
extension CameraManager {
    
    @available(iOS 10.0, *)
    func capturePhoto10() {
        
        guard captureSession.isRunning, let photoOutput = photoOutput else {
            return
        }
        
        let settings = AVCapturePhotoSettings()
        
        if liveMode == .on {
            let livePhotoPath = "\(livePhotoDir)/live_photo_\(settings.uniqueID)"
            settings.livePhotoMovieFileURL = URL(fileURLWithPath: livePhotoPath)
        }
        
        settings.flashMode = flashMode
        settings.isHighResolutionPhotoEnabled = isHighResolutionEnabled
        
        let output = photoOutput as! AVCapturePhotoOutput
        
        output.capturePhoto(with: settings, delegate: self)
        
    }
    
    func capturePhoto9() {
        
        guard captureSession.isRunning, let currentCamera = currentCamera, let photoOutput = photoOutput else {
            return
        }
        
        try! configureDevice(currentCamera) {
            currentCamera.flashMode = flashMode
        }
        
        let output = photoOutput as! AVCaptureStillImageOutput
        if let connection = output.connection(with: .video) {
            output.captureStillImageAsynchronously(from: connection) { (sampleBuffer, error) in
                if let sampleBuffer = sampleBuffer {
                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                    let dataProvider = CGDataProvider(data: imageData! as CFData)
                    let cgImageRef = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: CGColorRenderingIntent.defaultIntent)
                    
                    // Set proper orientation for photo
                    // If camera is currently set to front camera, flip image
                    let image = UIImage(cgImage: cgImageRef!, scale: 1.0, orientation: self.getImageOrientation(deviceOrientation: self.deviceOrientation))
                    self.onFinishCapturePhoto?(image, nil)
                    
                }
            }
        }
        
    }
}

extension CameraManager {
    
    enum CameraError: Swift.Error {
        case captureSessionAlreadyRunning
        case captureSessionIsMissing
        case inputsAreInvalid
        case invalidOperation
        case noCamerasAvailable
        case unknown
    }
    
    enum CameraPosition {
        case front, back
    }
    
    enum CameraLiveMode {
        case on, off, unavailable
    }
    
}
