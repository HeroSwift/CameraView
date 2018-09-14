
import UIKit
import AVFoundation

// 支持拍照，录视频

class CameraManager : NSObject {
    
    var isGreatThanIos10 = true
    
    var captureSession = AVCaptureSession()
    
    // 当前使用的摄像头
    var cameraPosition = AVCaptureDevice.Position.unspecified {
        didSet {
            onCameraPositionChange?()
        }
    }
    
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
    var movieOutput: AVCaptureMovieFileOutput?
    var metadataOutput: AVCaptureMetadataOutput?
    
    var preset = AVCaptureSession.Preset.high
    
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    var backgroundRecordingId: UIBackgroundTaskIdentifier?
    
    // 缩放
    var zoomFactor = CGFloat(0) {
        didSet {
            onZoomFactorChange?()
        }
    }
    
    var lastZoomFactor = CGFloat(1)
    var minZoomFactor = CGFloat(1)
    var maxZoomFactor = CGFloat(5)
    
    
    
    //
    // MARK: - 配置
    //
    
    // 设备状态
    var deviceOrientation = UIDeviceOrientation.portrait
    
    // 暗光环境下开启自动增强
    var lowHightBoost = true
    
    // Whether to capture still images at the highest resolution supported by the active device and format.
    var isHighResolutionEnabled = true
    
    // 是否可用 live 图片
    var liveMode = CameraLiveMode.off
    
    // live 图片的保存目录
    var livePhotoFileDir = NSTemporaryDirectory()
    
    // 当前的闪光灯模式
    var flashMode = AVCaptureDevice.FlashMode.off {
        didSet {
            onFlashModeChange?()
        }
    }
    
    //
    // MARK: - 回调
    //
    
    var onFlashModeChange: (() -> Void)?
    
    var onCameraPositionChange: (() -> Void)?
    
    var onZoomFactorChange: (() -> Void)?
    
    var photoCaptureCompletionBlock: ((UIImage?, Error?) -> Void)?
    
    var metadataCaptureCompletionBlock: ((String) -> Void)?
    
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
    
    // 拍照
    func capturePhoto(completion: @escaping (UIImage?, Error?) -> Void) {
        
        if isGreatThanIos10 {
            capturePhoto10(completion: completion)
        }
        else {
            capturePhoto9(completion: completion)
        }
        
    }
    
    // 录制视频
    func startVideoRecording() {
        
        guard let output = movieOutput, !output.isRecording else {
            return
        }
        
        if UIDevice.current.isMultitaskingSupported {
            backgroundRecordingId = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
        }
        
        let connection = output.connection(with: .video)
        if cameraPosition == .front {
            connection?.isVideoMirrored = true
        }
        
        connection?.videoOrientation = getVideoOrientation(deviceOrientation: deviceOrientation)
        
        let filePath = ""
        
        output.startRecording(to: URL(fileURLWithPath: filePath), recordingDelegate: self)
        
    }
    
    func stopVideoRecording() {
        
        guard let output = movieOutput, output.isRecording else {
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
        
        if isGreatThanIos10 {
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
    
    func displayPreview(on view: UIView) throws {
        
        guard captureSession.isRunning else {
            throw CameraError.captureSessionIsMissing
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        guard let previewLayer = previewLayer else {
            throw CameraError.invalidOperation
        }
        
        previewLayer.frame = view.frame
        previewLayer.videoGravity = .resizeAspect
        previewLayer.connection?.videoOrientation = .portrait
        
        view.clipsToBounds = true
        view.layer.insertSublayer(previewLayer, at: 0)

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
        
        if #available(iOS 10.0, *) {
            isGreatThanIos10 = false
        }
        else {
            isGreatThanIos10 = false
        }
        
        // 枚举音视频设备
        func configureCaptureDevices() throws {
            
            let session = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .unspecified)
            
            for camera in session.devices {
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
            
            if isGreatThanIos10 {
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
        func configureMovieOutput() throws {
            
            let movieOutput = AVCaptureMovieFileOutput()
            
            if captureSession.canAddOutput(movieOutput) {
                captureSession.addOutput(movieOutput)
                if let connection = movieOutput.connection(with: .video) {
                    if connection.isVideoStabilizationSupported {
                        connection.preferredVideoStabilizationMode = .auto
                    }
                }
                self.movieOutput = movieOutput
            }
        }
        
        
        DispatchQueue(label: "prepare").async {
            
            do {
                try configureCaptureDevices()
                try configureDeviceInputs()
                try configurePhotoOutput()
                try configureMovieOutput()
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
extension CameraManager: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?,
                     previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?,
                     resolvedSettings: AVCaptureResolvedPhotoSettings,
                     bracketSettings: AVCaptureBracketedStillImageSettings?,
                     error: Error?
    ) {
        
        if let error = error {
            photoCaptureCompletionBlock?(nil, error)
        }
        else if let buffer = photoSampleBuffer,
            let data = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: buffer, previewPhotoSampleBuffer: nil),
            let image = UIImage(data: data) {
            photoCaptureCompletionBlock?(image, nil)
        }
        else {
            photoCaptureCompletionBlock?(nil, CameraError.unknown)
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
        
        if error != nil {
            print("视频录制失败")
        }
        else {
            print(outputFileURL.absoluteString)
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
                metadataCaptureCompletionBlock?(stringValue)
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
    
    private func getVideoOrientation(deviceOrientation: UIDeviceOrientation) -> AVCaptureVideoOrientation {
        
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
    
    private func getImageOrientation(deviceOrientation: UIDeviceOrientation) -> UIImageOrientation {
        
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
    
    func capturePhoto10(completion: @escaping (UIImage?, Error?) -> Void) {
        
        guard captureSession.isRunning, let photoOutput = photoOutput else {
            completion(nil, CameraError.captureSessionIsMissing)
            return
        }
        
        let settings = AVCapturePhotoSettings()
        
        if liveMode == .on {
            let path = "\(livePhotoFileDir)/photo_\(settings.uniqueID)"
            settings.livePhotoMovieFileURL = URL(fileURLWithPath: path)
        }
        
        settings.flashMode = flashMode
        settings.isHighResolutionPhotoEnabled = isHighResolutionEnabled
        
        let output = photoOutput as! AVCapturePhotoOutput

        output.capturePhoto(with: settings, delegate: self)
        
        photoCaptureCompletionBlock = completion
        
    }
    
    func capturePhoto9(completion: @escaping (UIImage?, Error?) -> Void) {
        
        guard captureSession.isRunning, let currentCamera = currentCamera, let photoOutput = photoOutput else {
            completion(nil, CameraError.captureSessionIsMissing)
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
                    completion(image, nil)
                    
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
