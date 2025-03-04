//
//  BasePopView.swift
//  AIRun
//
//  Created by AIRun on 20247/11.
//

import UIKit

class BasePopView: UIView, UIGestureRecognizerDelegate{
    
    /// 动画类型
    open var animationType: BasePopupAnimationType = .alert
    /// 是否可以点击背景隐藏
    open var enableTouchHide: Bool = true
    
    private let animateDuration: TimeInterval = 0.3
    
    open var bgColor: UIColor = UIColor.appBgColor().withAlphaComponent(0.6)
    
    var popHideBlock: (() -> Void)?

    private lazy var backgroundView: UIView = {
        let view = UIView()
        view.frame = UIScreen.main.bounds
        view.backgroundColor = bgColor
        view.alpha = 0
        if enableTouchHide {
            let tap = UITapGestureRecognizer.init(target: self, action: #selector(hide))
            tap.delegate = self
            view.addGestureRecognizer(tap)
        }
        return view
    }()
    
    public init() {
        super.init(frame: .zero)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc open func show(in view: UIView = UIApplication.shared.keyWindow!) {
        view.addSubview(backgroundView)
        animationType.showAnimation(contentView: self, backgroundView: backgroundView, animationDuration: animateDuration)()
    }
    
    @objc open func hide() {
        self.popHideBlock?()
        animationType.hideAnimation(contentView: self, backgroundView: backgroundView, animationDuration: animateDuration)()
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let touchView = touch.view, touchView == self.backgroundView {
            return true
        }
        return false
    }
    
}

public enum BasePopupAnimationType {
    case alert, sheet
    
    typealias AnimationComplete = () -> Void
    
    private static let alertScale: CGFloat = 0.9
    
    func showAnimation(contentView: UIView, backgroundView: UIView, animationDuration: TimeInterval) -> AnimationComplete {
        backgroundView.addSubview(contentView)
        switch self {
        case .alert:
            return {
                
                if contentView.constraints.count == 0 {
                    contentView.center = backgroundView.center
                } else {
                    let constraintX = NSLayoutConstraint(item: contentView, attribute: .centerX, relatedBy: .equal, toItem: backgroundView, attribute: .centerX, multiplier: 1, constant: 0)
                    let constraintY = NSLayoutConstraint(item: contentView, attribute: .centerY, relatedBy: .equal, toItem: backgroundView, attribute: .centerY, multiplier: 1, constant: 0)
                    backgroundView.addConstraints([constraintX, constraintY])
                    backgroundView.layoutIfNeeded()
                }
                
                contentView.transform = CGAffineTransform(scaleX: BasePopupAnimationType.alertScale, y: BasePopupAnimationType.alertScale)
                UIView.animate(withDuration: animationDuration) {
                    backgroundView.alpha = 1
                    contentView.transform = CGAffineTransform(scaleX: 1, y: 1)
                }
            }
        case .sheet:
            return {
                if contentView.constraints.count == 0 {
                    contentView.center = backgroundView.center
                    contentView.frame.origin.y = backgroundView.bounds.size.height
                } else {

                    let constraintX = NSLayoutConstraint(item: contentView, attribute: .centerX, relatedBy: .equal, toItem: backgroundView, attribute: .centerX, multiplier: 1, constant: 0)
                    let constraintBottom = NSLayoutConstraint(item: contentView, attribute: .top, relatedBy: .equal, toItem: backgroundView, attribute: .bottom, multiplier: 1, constant: 0)
                    backgroundView.addConstraints([constraintX, constraintBottom])
                    backgroundView.layoutIfNeeded()
                }
                
                UIView.animate(withDuration: animationDuration) {
                    backgroundView.alpha = 1
                    contentView.transform = CGAffineTransform(translationX: 0, y: -contentView.bounds.size.height)
                }
            }
        }
    }
    
    func hideAnimation(contentView: UIView, backgroundView: UIView, animationDuration: TimeInterval) -> AnimationComplete {
        switch self {
        case .alert:
            return {
                UIView.animate(withDuration: animationDuration, animations: {
                    backgroundView.alpha = 0
                    contentView.transform = CGAffineTransform(scaleX: BasePopupAnimationType.alertScale, y: BasePopupAnimationType.alertScale)
                }) { (_) in
                    backgroundView.removeFromSuperview()
                    contentView.removeFromSuperview()
                }
            }
        case .sheet:
            return {
                UIView.animate(withDuration: animationDuration, animations: {
                    backgroundView.alpha = 0
                    contentView.transform = CGAffineTransform(translationX: 0, y: 0)
                }) { (_) in
                    backgroundView.removeFromSuperview()
                    contentView.removeFromSuperview()
                }
            }
        }
    }
}
