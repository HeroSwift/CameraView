import UIKit

// 配置
public class CameraViewConfiguration {

    // 引导文本颜色
    public var guideLabelTextColor = UIColor(red: 160 / 255, green: 160 / 255, blue: 160 / 255, alpha: 1)
    
    // 引导文本字体
    public var guideLabelTextFont = UIFont.systemFont(ofSize: 13)
    
    // 引导文本与录制按钮的距离
    public var guideLabelMarginBottom: CGFloat = 30
    
    // 引导文本几秒后淡出
    public var guideLabelFadeOutInterval: TimeInterval = 4
    
    // 引导文本
    public var guideLabelTitle = "轻触拍照，按住摄像"
    
    
    
    // 录制按钮默认半径
    public var captureButtonCenterRadiusNormal: CGFloat = 36
    
    // 录制按钮录制视频时的半径
    public var captureButtonCenterRadiusRecording: CGFloat = 24
    
    // 录制按钮中心圆的默认颜色
    public var captureButtonCenterColorNormal = UIColor.white
    
    // 录制按钮按下时中心圆的颜色
    public var captureButtonCenterColorPressed = UIColor(red: 240 / 255, green: 240 / 255, blue: 240 / 255, alpha: 1)
    
    // 录制按钮默认的圆环大小
    public var captureButtonRingWidthNormal: CGFloat = 6
    
    // 录制按钮录制时的圆环大小
    public var captureButtonRingWidthRecording: CGFloat = 30
    
    // 录制按钮圆环颜色
    public var captureButtonRingColor = UIColor(red: 230 / 255, green: 230 / 255, blue: 230 / 255, alpha: 0.9)
    
    // 录制按钮进度条轨道的大小
    public var captureButtonTrackWidth: CGFloat = 4
    
    // 录制按钮进度条轨道的颜色
    public var captureButtonTrackColor = UIColor(red: 0.11, green: 0.64, blue: 0.06, alpha: 0.9)
    
    // 录制按钮与底边的距离
    public var captureButtonMarginBottom: CGFloat = 50
    
    
    // 切换摄像头按钮与顶边的距离
    public var flipButtonMarginTop: CGFloat = 15
    
    // 切换摄像头按钮与右边的距离
    public var flipButtonMarginRight: CGFloat = 20
    
    // 切换摄像头按钮的宽度
    public var flipButtonWidth: CGFloat = 50
    
    // 切换摄像头按钮的高度
    public var flipButtonHeight: CGFloat = 44
    
    // 切换摄像头按钮的图片
    public var flipButtonImage = UIImage(named: "camera-flip", in: Bundle(for: CameraViewConfiguration.self), compatibleWith: nil)
    
    // 闪光灯按钮与切换摄像头按钮的距离
    public var flashButtonMarginRight: CGFloat = 14
    
    // 闪光灯按钮的宽度
    public var flashButtonWidth: CGFloat = 50
    
    // 闪光灯按钮的高度
    public var flashButtonHeight: CGFloat = 44
    
    // 闪光灯开启的图片
    public var flashOnImage = UIImage(named: "flash-on", in: Bundle(for: CameraViewConfiguration.self), compatibleWith: nil)
    
    // 闪光灯关闭的图片
    public var flashOffImage = UIImage(named: "flash-off", in: Bundle(for: CameraViewConfiguration.self), compatibleWith: nil)
    
    // 闪光灯自动的图片
    public var flashAutoImage = UIImage(named: "flash-auto", in: Bundle(for: CameraViewConfiguration.self), compatibleWith: nil)
    
    // 退出按钮与录制按钮的距离
    public var exitButtonMarginRight: CGFloat = 50
    
    // 退出按钮的宽度
    public var exitButtonWidth: CGFloat = 50
    
    // 退出按钮的高度
    public var exitButtonHeight: CGFloat = 44
    
    // 退出按钮的图片
    public var exitButtonImage = UIImage(named: "exit", in: Bundle(for: CameraViewConfiguration.self), compatibleWith: nil)
    
    // 确定按钮的半径
    public var okButtonCenterRadius: CGFloat = 38
    
    // 确定按钮的颜色
    public var okButtonCenterColor = UIColor.white
    
    // 确定按钮的图片
    public var okButtonImage = UIImage(named: "ok", in: Bundle(for: CameraViewConfiguration.self), compatibleWith: nil)
    
    public var okButtonRingWidth: CGFloat = 0
    
    // 取消按钮的半径
    public var cancelButtonCenterRadius: CGFloat = 38
    
    // 取消按钮的颜色
    public var cancelButtonCenterColor = UIColor(red: 255 / 255, green: 255 / 255, blue: 255 / 255, alpha: 0.9)
    
    // 取消按钮的图片
    public var cancelButtonImage = UIImage(named: "cancel", in: Bundle(for: CameraViewConfiguration.self), compatibleWith: nil)
    
    public var cancelButtonRingWidth: CGFloat = 0
    
    
    // 聚焦视图的宽度
    public var focusViewWidth: CGFloat = 40
    
    // 聚焦视图的高度
    public var focusViewHeight: CGFloat = 40
    
    // 聚焦视图的颜色
    public var focusViewColor = UIColor.green
    
    // 聚焦视图的粗细
    public var focusViewThickness: CGFloat = 1 / UIScreen.main.scale
    
    public var focusViewCrossLength: CGFloat = 6
    
    // 图片保存的目录
    public var photoDir = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!
    
    // 视频保存的目录
    public var videoDir = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!
    
    // 视频文件扩展名
    public var videoExtname = ".mp4"
    
    // 视频最短录制时长
    public var videoMinDuration: TimeInterval = 1
    
    // 视频最大录制时长
    public var videoMaxDuration: TimeInterval = 10
    
    public init() { }
    
}
