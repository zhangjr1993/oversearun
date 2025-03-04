//
//  UIView+Extension.swift
//  AIRun
//
//  Created by AIRun on 20247/7.
//

import Foundation

public enum ShakeDirection {
    case horizontal
    case vertical
}

public enum ShakeAnimationType {
    case linear
    case easeIn
    case easeOut
    case easeInOut
}


/// 圆角
extension UIView {
    
    /// 添加渐变色背景
    public final func addGradientLayer(colors: [CGColor], frame: CGRect, startPoint: CGPoint = CGPoint(x: 0, y: 0), endPoint: CGPoint = CGPoint(x: 1, y: 0), locations: [NSNumber] = [0, 1]) {
        let GTLayer : CAGradientLayer =  CAGradientLayer()
        GTLayer.startPoint = startPoint
        GTLayer.endPoint = endPoint
        GTLayer.colors = colors
        GTLayer.frame = frame
        GTLayer.locations = locations
        self.layer.insertSublayer(GTLayer, at: 0)
    }
    
    public func clipAllCorner(radius: CGFloat) {
        self.layer.masksToBounds = true
        self.layer.cornerRadius = radius
    }
    
    public func clipCorner(_ rectCorner: UIRectCorner, radius: CGFloat, rect: CGRect? = nil) {
        let layerRect = rect ?? self.bounds
        let maskPath = UIBezierPath(roundedRect: layerRect,
                                    byRoundingCorners: rectCorner,
                                    cornerRadii: CGSize(width: radius, height: radius))
        let maskLayer = CAShapeLayer()
        maskLayer.path = maskPath.cgPath
        
        maskLayer.frame = layerRect
        self.layer.mask = maskLayer
    }
}

// MARK: - shake
extension UIView {
    public func shake(direction: ShakeDirection = .horizontal, duration: TimeInterval = 1, animationType: ShakeAnimationType = .easeOut, space: CGFloat = 10.0, completion:(() -> Void)? = nil) {
        CATransaction.begin()
        let animation: CAKeyframeAnimation
        switch direction {
        case .horizontal:
            animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        case .vertical:
            animation = CAKeyframeAnimation(keyPath: "transform.translation.y")
        }
        switch animationType {
        case .linear:
            animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        case .easeIn:
            animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
        case .easeOut:
            animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        case .easeInOut:
            animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        }
        CATransaction.setCompletionBlock(completion)
        animation.duration = duration
        animation.values = [-space, space, -space, space, -space/2.0, space/2.0, -space/4.0, space/4.0, 0.0 ]
        layer.add(animation, forKey: "shake")
        CATransaction.commit()
    }
   
    func addBgShadow(_ color: UIColor = UIColor.black.withAlphaComponent(0.25), _ radius: CGFloat = 4.0, _ offset: CGSize = CGSize(width: 0, height: 2), _ opac: CGFloat = 1.0) {
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOffset = offset
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = radius
    }
    
}

//extension UIView {
//    /// 翻转动画
//    func addFilpAnimation(duration: CGFloat = 1.0) {
//        UIView.animate(withDuration: duration, animations: {
//            self.transform = self.transform.scaledBy(x: -1, y: 1)
//        })
//    }
//}

extension UIView {
    var x: CGFloat {
        get { frame.origin.x }
        set {
            var rect = frame
            rect.origin.x = newValue
            frame = rect
        }
    }
    var y: CGFloat {
        get { frame.origin.y }
        set {
            var rect = frame
            rect.origin.y = newValue
            frame = rect
        }
    }
    var width: CGFloat {
        get { frame.width }
        set {
            var rect = frame
            rect.size.width = newValue
            frame = rect
        }
    }
    var height: CGFloat {
        get { frame.height }
        set {
            var rect = frame
            rect.size.height = newValue
            frame = rect
        }
    }
    var size: CGSize {
        get { frame.size }
        set {
            var rect = frame
            rect.size = newValue
            frame = rect
        }
    }
    var centerX: CGFloat {
        get { center.x }
        set {
            var point = center
            point.x = newValue
            center = point
        }
    }
    var centerY: CGFloat {
        get { center.y }
        set {
            var point = center
            point.y = newValue
            center = point
        }
    }
}
