
import UIKit
import AVFoundation

// 支持拍照，录视频
// 必须 ios 10+

class CameraManager : NSObject {
    
    var captureSession: AVCaptureSession?
    
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
    
    var photoOutput: AVCapturePhotoOutput?
    var movieOutput: AVCaptureMovieFileOutput?
    var metadataOutput: AVCaptureMetadataOutput?
    
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    // 当前使用的摄像头
    var cameraPosition = AVCaptureDevice.Position.unspecified
    
    //
    // MARK: - 拍照 配置
    //
    
    // Whether to capture still images at the highest resolution supported by the active device and format.
    var isHighResolutionEnabled = true
    
    // 是否可用 live 图片
    var liveMode = CameraLiveMode.off
    
    // live 图片的保存目录
    var livePhotoFileDir = NSTemporaryDirectory()
    
    // 当前的闪光灯模式
    var flashMode = AVCaptureDevice.FlashMode.off
    
    //
    // MARK: - 回调
    //
    
    var photoCaptureCompletionBlock: ((UIImage?, Error?) -> Void)?
    
    var metadataCaptureCompletionBlock: ((String) -> Void)?
    
}

extension CameraManager {
    
    func capturePhoto(completion: @escaping (UIImage?, Error?) -> Void) {
        
        guard let captureSession = captureSession, captureSession.isRunning, let photoOutput = photoOutput else {
            completion(nil, CameraError.captureSessionIsMissing)
            return
        }
        
        guard let previewLayer = previewLayer else {
            completion(nil, CameraError.invalidOperation)
            return
        }
        
        let settings = AVCapturePhotoSettings()
        
        if liveMode == .on {
            let path = "\(livePhotoFileDir)/photo_\(settings.uniqueID)"
            settings.livePhotoMovieFileURL = URL(fileURLWithPath: path)
        }
        
        if photoOutput.supportedFlashModes.contains(flashMode) {
            settings.flashMode = flashMode
        }
        
        let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
        let previewFormat: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
            kCVPixelBufferWidthKey as String: previewLayer.frame.width,
            kCVPixelBufferHeightKey as String: previewLayer.frame.height
        ]
        
        settings.previewPhotoFormat = previewFormat
        
        settings.isHighResolutionPhotoEnabled = isHighResolutionEnabled
        
        photoOutput.capturePhoto(with: settings, delegate: self)
        photoCaptureCompletionBlock = completion
        
    }
    
    func switchToFrontCamera() throws {
        
        if cameraPosition == .front {
            return
        }
        
        guard let captureSession = captureSession, captureSession.isRunning
        else {
            throw CameraError.captureSessionIsMissing
        }

        captureSession.beginConfiguration()
        
        let inputs = captureSession.inputs
        
        guard let backCameraInput = backCameraInput, inputs.contains(backCameraInput), let frontCamera = frontCamera
        else {
            throw CameraError.invalidOperation
        }
        
        frontCameraInput = try AVCaptureDeviceInput(device: frontCamera)
        
        captureSession.removeInput(backCameraInput)
        
        if captureSession.canAddInput(frontCameraInput!) {
            captureSession.addInput(frontCameraInput!)
            self.cameraPosition = .front
        }
        else {
            throw CameraError.invalidOperation
        }
        
        captureSession.commitConfiguration()
        
    }
    
    func switchToBackCamera() throws {
        
        if cameraPosition == .back {
            return
        }
        
        guard let captureSession = captureSession, captureSession.isRunning
        else {
            throw CameraError.captureSessionIsMissing
        }
        
        captureSession.beginConfiguration()
        
        let inputs = captureSession.inputs
        
        guard let frontCameraInput = frontCameraInput, inputs.contains(frontCameraInput), let backCamera = backCamera
        else {
            throw CameraError.invalidOperation
        }
        
        backCameraInput = try AVCaptureDeviceInput(device: backCamera)
        
        captureSession.removeInput(frontCameraInput)
        
        if captureSession.canAddInput(backCameraInput!) {
            captureSession.addInput(backCameraInput!)
            self.cameraPosition = .back
        }
        else {
            throw CameraError.invalidOperation
        }
        
        captureSession.commitConfiguration()
        
    }
    
    func displayPreview(on view: UIView) throws {
        
        guard let captureSession = captureSession, captureSession.isRunning else {
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
    func focus(point: CGPoint) throws {
        
        guard let backCamera = backCamera else {
            throw CameraError.invalidOperation
        }

        try backCamera.lockForConfiguration()
        
        backCamera.focusPointOfInterest = point
        backCamera.exposurePointOfInterest = point
        
        backCamera.focusMode = .continuousAutoFocus
        backCamera.exposureMode = .continuousAutoExposure
        
        backCamera.unlockForConfiguration()
        
    }
    
    func prepare(completionHandler: @escaping (Error?) -> Void) {
        
        func createCaptureSession() {
            captureSession = AVCaptureSession()
            captureSession?.sessionPreset = .high
        }
        func configureCaptureDevices() throws {
            
            let session = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .unspecified)
            
            for camera in session.devices {
                if camera.position == .front {
                    frontCamera = camera
                }
                else if camera.position == .back {
                    backCamera = camera
                    
                    // 自动聚焦
                    try camera.lockForConfiguration()
                    camera.focusMode = .continuousAutoFocus
                    camera.unlockForConfiguration()
                }
            }
            
            microphone = AVCaptureDevice.default(for: .audio)
        }
        func configureDeviceInputs() throws {
            
            guard let captureSession = captureSession else {
                throw CameraError.captureSessionIsMissing
            }
            
            if let backCamera = backCamera {
                backCameraInput = try AVCaptureDeviceInput(device: backCamera)
                
                if captureSession.canAddInput(backCameraInput!) {
                    captureSession.addInput(backCameraInput!)
                }
                else {
                    throw CameraError.inputsAreInvalid
                }
                
                cameraPosition = .back
            }
            else if let frontCamera = frontCamera {
                frontCameraInput = try AVCaptureDeviceInput(device: frontCamera)
                
                if captureSession.canAddInput(frontCameraInput!) {
                    captureSession.addInput(frontCameraInput!)
                }
                else {
                    throw CameraError.inputsAreInvalid
                }
                
                cameraPosition = .front
            }
            else {
                throw CameraError.noCamerasAvailable
            }
            
            if let microphone = microphone {
                microphoneInput = try AVCaptureDeviceInput(device: microphone)
                
                if captureSession.canAddInput(microphoneInput!) {
                    captureSession.addInput(microphoneInput!)
                }
                else {
                    throw CameraError.inputsAreInvalid
                }
            }
        }
        func configurePhotoOutput() throws {
            
            guard let captureSession = captureSession else {
                throw CameraError.captureSessionIsMissing
            }
            
            photoOutput = AVCapturePhotoOutput()
            
            guard let photoOutput = photoOutput else {
                throw CameraError.invalidOperation
            }
            
            if captureSession.canAddOutput(photoOutput) {
                
                photoOutput.isHighResolutionCaptureEnabled = isHighResolutionEnabled
                
                photoOutput.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecJPEG])], completionHandler: nil)
                
                if !photoOutput.isLivePhotoCaptureSupported {
                    liveMode = .unavailable
                }
                
                captureSession.addOutput(photoOutput)
            }
            
            captureSession.startRunning()
            
        }
        
        DispatchQueue(label: "prepare").async {
            
            do {
                createCaptureSession()
                try configureCaptureDevices()
                try configureDeviceInputs()
                try configurePhotoOutput()
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
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        
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

// 识别二维码
extension CameraManager: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
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
