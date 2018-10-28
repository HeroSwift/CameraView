
import UIKit

public protocol CameraViewDelegate {
    
    // 点击退出按钮
    func cameraViewDidExit(_ cameraView: CameraView)
    
    // 点击确定按钮
    func cameraViewDidSubmit(_ cameraView: CameraView, _ filePath: String, _ duration: TimeInterval)
    
    // 录制视频时间太短
    func cameraViewDidRecordDurationLessThanMinDuration(_ cameraView: CameraView)
    
    // 用户点击同意授权
    func cameraViewDidPermissionsGranted(_ cameraView: CameraView)
    
    // 用户点击拒绝授权
    func cameraViewDidPermissionsDenied(_ cameraView: CameraView)

}

public extension CameraViewDelegate {
    
    func cameraViewDidExit(_ cameraView: CameraView) { }
    
    func cameraViewDidSubmit(_ cameraView: CameraView, _ filePath: String, _ duration: TimeInterval) { }

    func cameraViewDidRecordDurationLessThanMinDuration(_ cameraView: CameraView) { }
    
    func cameraViewDidPermissionsGranted(_ cameraView: CameraView) { }
    
    func cameraViewDidPermissionsDenied(_ cameraView: CameraView) { }
    
}
