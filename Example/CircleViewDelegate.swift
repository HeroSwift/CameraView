
import UIKit

public protocol CircleViewDelegate {

    func circleViewDidTouchDown(_ circleView: CircleView)

    func circleViewDidTouchUp(_ circleView: CircleView, _ inside: Bool)
    
    func circleViewDidTouchMove(_ circleView: CircleView, _ x: CGFloat, _ y: CGFloat)

    func circleViewDidTouchEnter(_ circleView: CircleView)

    func circleViewDidTouchLeave(_ circleView: CircleView)

}

public extension CircleViewDelegate {

    func circleViewDidTouchDown(_ circleView: CircleView) { }

    func circleViewDidTouchUp(_ circleView: CircleView, _ inside: Bool) { }

    func circleViewDidTouchMove(_ circleView: CircleView, _ x: CGFloat, _ y: CGFloat) { }
    
    func circleViewDidTouchEnter(_ circleView: CircleView) { }

    func circleViewDidTouchLeave(_ circleView: CircleView) { }

}
