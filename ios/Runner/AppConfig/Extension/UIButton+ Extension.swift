//
//  Untitled 2.swift
//  AIRun
//
//  Created by AIRun on 2025/1/15.
//
import Foundation

extension UIButton {
    func setUrlImage(urlStr: String,
                     placeholder: UIImage? = UIImage.basicPlaceholderImg(),
                     state: UIControl.State = .normal,
                     loadFinish: ((_ isSucceed: Bool, _ image: UIImage?) -> Void)? = nil) {
        
        if urlStr.isValidStr {
            var tempUrl = urlStr
            if !urlStr.hasPrefix("https://") && !urlStr.hasPrefix("http://"){
                tempUrl = APPManager.default.config.staticUrlDomain + "/\(urlStr)"
            }
            self.kf.setImage(with: URL(string: tempUrl), for: state, placeholder: placeholder, completionHandler: { result in
               if loadFinish != nil {
                   let image = try? result.get().image
                   loadFinish!(true, image)
               }
           })
        }else{
            self.setImage(placeholder, for: .normal)
        }
    }
}

private struct AssociatedKey {
    static var defaultDurationTime: TimeInterval = 1.5 // 默认时间间隔
    static var clickDurationTime = "clickDurationTime"
    static var isIgnoreEvent = "isIgnoreEvent"
}

extension UIButton {
    func addClickTime(_ time: CGFloat = 1.5) {
        if time > 0 {
            self.isEnabled = false
            DispatchQueue.main.asyncAfter(deadline: .now() + time, execute: {
                self.isEnabled = true
            })
        }
    }
    
    static func initializeMethod(){
        if self !== UIButton.self {
            return
        }
        DispatchQueue.once(token: QueueConfig.buttonInit) {
            let originalSelector = #selector(sendAction(_:to:for:))
            let swizzledSelector = #selector(swizzle_sendAction(_:to:for:))
            let originalMethod = class_getInstanceMethod(UIButton.self, originalSelector)
            let swizzledMethod = class_getInstanceMethod(UIButton.self, swizzledSelector)
            let didAddMethod = class_addMethod(UIButton.self, originalSelector, method_getImplementation(swizzledMethod!), method_getTypeEncoding(swizzledMethod!))
            if didAddMethod {
                // 如果添加成功，则交换方法
                class_replaceMethod(UIButton.self, swizzledSelector, method_getImplementation(originalMethod!), method_getTypeEncoding(originalMethod!))
            } else {
                // 如果添加失败，则交换方法的具体实现
                method_exchangeImplementations(originalMethod!, swizzledMethod!)
            }
        }
    }
    /// Swizzled Method
    @objc private func swizzle_sendAction(_ action: Selector, to target: Any?, for event: UIEvent?) {
        clickDurationTime = clickDurationTime == 0 ? AssociatedKey.defaultDurationTime : clickDurationTime
        // 判断是否忽略连续点击事件
        // 如果不忽略false则关闭用户交互，点击间隔时间后打开用户交互
        // 如果忽略true则直接调用原有方法
        if !isIgnoreEvent {
            isUserInteractionEnabled = false
            DispatchQueue.main.asyncAfter(deadline: .now() + clickDurationTime, execute: {
                self.isUserInteractionEnabled = true
            })
        }
        swizzle_sendAction(action, to: target, for: event)
    }
    
    /// 点击事件时间间隔
    var clickDurationTime: TimeInterval {
        set {
            objc_setAssociatedObject(self, &AssociatedKey.clickDurationTime, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            if let time = objc_getAssociatedObject(self, &AssociatedKey.clickDurationTime) as? TimeInterval {
                return time
            }
            return AssociatedKey.defaultDurationTime
        }
    }

    /// 是否忽略连续点击事件
    var isIgnoreEvent: Bool {
        get {
            if let event = objc_getAssociatedObject(self, &AssociatedKey.isIgnoreEvent) as? Bool {
                return event
            }
            return false
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKey.isIgnoreEvent, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}


// 按钮点击范围
private var key: Void?
extension UIButton {
    
    public var clickSize: CGSize? {
        set {
            objc_setAssociatedObject(self, &key, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
        get {
            return objc_getAssociatedObject(self, &key) as? CGSize
        }
    }
    
    override open func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        var rect = CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height)
        let extra_w: CGFloat = -(clickSize?.width ?? 10)
        let extra_h: CGFloat = -(clickSize?.height ?? 10)
        
        rect = CGRectInset(rect, extra_w, extra_h)
        return CGRectContainsPoint(rect, point)
    }

}



enum ButtonLayoutType {
    case leftImageRightTitle // 系统默认
    case leftTitleRightImage
    case upImageDownTitle
    case upTitleDownImage
}

// MARK: 按钮更换位置

class LayoutButton: UIButton {
    /// 布局方式
    var layoutStyle: ButtonLayoutType = .leftImageRightTitle
    /// 图片和文字的间距，默认值5
    var midSpacing: CGFloat = 5.0
    /// 指定图片size
    var imageSize = CGSize.zero
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if imageSize.equalTo(.zero) {
            imageView?.sizeToFit()
        } else {
            imageView?.frame = CGRect(x: imageView!.x, y: imageView!.y, width: imageSize.width, height: imageSize.height)
        }
        titleLabel?.sizeToFit()
        
        switch layoutStyle {
        case .leftImageRightTitle:
            layoutHorizontal(withLeftView: imageView, rightView: titleLabel)
        case .leftTitleRightImage:
            layoutHorizontal(withLeftView: titleLabel, rightView: imageView)
        case .upImageDownTitle:
            layoutVertical(withUp: imageView, downView: titleLabel)
        case .upTitleDownImage:
            layoutVertical(withUp: titleLabel, downView: imageView)
        }
    }
    
    func layoutHorizontal(withLeftView leftView: UIView?, rightView: UIView?) {
        guard var leftViewFrame = leftView?.frame,
            var rightViewFrame = rightView?.frame else { return }
        
        if imageSize.equalTo(.zero) && layoutStyle == .leftImageRightTitle {
            leftViewFrame = CGRect(x: 0, y: 0, width: leftViewFrame.width, height: leftViewFrame.height)
        }
        let totalWidth: CGFloat = leftViewFrame.width + midSpacing + rightViewFrame.width
        
        leftViewFrame.origin.x = (frame.width - totalWidth) / 2.0
        leftViewFrame.origin.y = (frame.height - leftViewFrame.height) / 2.0
        leftView?.frame = leftViewFrame
        
        rightViewFrame.origin.x = leftViewFrame.maxX + midSpacing
        rightViewFrame.origin.y = (frame.height - rightViewFrame.height) / 2.0
        rightView?.frame = rightViewFrame
    }
    
    func layoutVertical(withUp upView: UIView?, downView: UIView?) {
        guard var upViewFrame = upView?.frame,
            var downViewFrame = downView?.frame else { return }
        
        let totalHeight: CGFloat = upViewFrame.height + midSpacing + downViewFrame.height
        
        upViewFrame.origin.y = (frame.height - totalHeight) / 2.0
        upViewFrame.origin.x = (frame.width - upViewFrame.width) / 2.0
        upView?.frame = upViewFrame
        
        downViewFrame.origin.y = upViewFrame.maxY + midSpacing
        downViewFrame.origin.x = (frame.width - downViewFrame.width) / 2.0
        downView?.frame = downViewFrame
    }

    override func setImage(_ image: UIImage?, for state: UIControl.State) {
        super.setImage(image, for: state)
        setNeedsLayout()
    }
    
    override func setTitle(_ title: String?, for state: UIControl.State) {
        super.setTitle(title, for: state)
        setNeedsLayout()
    }
    
    func setMidSpacing(_ midSpacing: CGFloat) {
        self.midSpacing = midSpacing
        setNeedsLayout()
    }
    
    func setImageSize(_ imageSize: CGSize) {
        self.imageSize = imageSize
        setNeedsLayout()
    }
    
}
