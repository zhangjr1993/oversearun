//
//  Untitled.swift
//  AIRun
//
//  Created by AIRun on 2025/1/15.
//

import Foundation


extension UIColor {
    convenience init(hex: Int) {
        
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255.0,
            green: CGFloat((hex >> 8) & 0xFF) / 255.0,
            blue: CGFloat(hex & 0xFF) / 255.0,
            alpha: 1.0
        )
    }
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
        self.init(
            red: r / 255.0,
            green: g / 255.0,
            blue: b / 255.0,
            alpha: a
        )
    }
    
    convenience init(hexStr: String) {
        var colorString: String = hexStr.trimmed().uppercased()
        if colorString.hasPrefix("#") {
            colorString.remove(at: colorString.startIndex)
        }
        if colorString.count != 6 {
            self.init(white: 1, alpha: 1)
            return
        }
        var colorValue: UInt64 = 0
        Scanner(string: colorString).scanHexInt64(&colorValue)
        self.init(hex: Int(colorValue))
    }
}

extension UIColor {

    
    // 斜体字颜色
    static func appItalicColor(alpha: CGFloat = 1) -> UIColor {
        return UIColor.init(hexStr: "#59442E").withAlphaComponent(alpha)
    }
    
    //
    static func appTitle1Color() -> UIColor {
        return UIColor.init(hexStr: "#F2F4F6")
    }
    
    /// 白色字体 透明度
    static func whiteColor(alpha: CGFloat = 1) -> UIColor {
        return UIColor.white.withAlphaComponent(alpha)
    }
    
    // 灰白色
    static func appTitle2Color() -> UIColor {
        return UIColor.init(hexStr: "#F2F4F6").withAlphaComponent(0.6)
    }
    
    static func appTitle3Color() -> UIColor {
        return UIColor.init(hexStr: "#F2F4F6").withAlphaComponent(0.3)
    }
    
    /// 棕色
    static func appBrownColor(_ alpha: CGFloat = 1) ->  UIColor {
        return UIColor.init(hexStr: "#610134").withAlphaComponent(alpha)
    }
    
    // link黄色
    static func appLinkColor() -> UIColor {
        return UIColor.init(hexStr: "#FFEF9B")
    }
  
 
    
    /// 页面黑色背景
    static func appBgColor() -> UIColor {
        return UIColor.init(hexStr: "#1F1F1F")
    }
    
    /// 黑灰色背景  --  输入框
    static func appGaryColor() -> UIColor {
        return UIColor.init(hexStr: "#FFFFFF").withAlphaComponent(0.05)
    }
    
//    /// 黑色透明背景
//    static func app0309BgColor() -> UIColor {
//        return UIColor.init(hexStr: "#030921")
//    }
    
    /// 粉色
    static func appPinkColor() -> UIColor {
        return UIColor.init(hexStr: "#F8C0DC")
    }
    
    // 弹窗取消按钮背景灰色
    static func appCancelColor() -> UIColor {
        return UIColor.whiteColor(alpha: 0.05)
    }
   
    // 红色
    static func appRedColor() -> UIColor {
        return UIColor.init(hexStr: "#E94359")
    }
    // 黄色
    static func appYellowColor() -> UIColor {
        return UIColor.init(hexStr: "#FFE293")
    }
    
    static func lineGradientColors() -> [UIColor] {
        return [UIColor.init(hexStr: "#FBDAD3"),
                UIColor.init(hexStr: "#FFDBE7"),
                UIColor.init(hexStr: "#CFCEF9")]
    }
    
    static func appGradientColor() -> [CGColor] {
        return [UIColor.init(hexStr: "#FBDAD3").cgColor,
                UIColor.init(hexStr: "#FFDBE7").cgColor,
                UIColor.init(hexStr: "#CFCEF9").cgColor]
    }

    static func appGradientDisColor() -> [CGColor] {
        return [UIColor.init(hexStr: "#FBDAD3").withAlphaComponent(0.7).cgColor,
                UIColor.init(hexStr: "#FFDBE7").withAlphaComponent(0.7).cgColor,
                UIColor.init(hexStr: "#CFCEF9").withAlphaComponent(0.7).cgColor]
    }
    
    static func popupBgColors() -> [CGColor] {
        return [UIColor.init(hexStr: "#47454F").cgColor,
                UIColor.init(hexStr: "#38353A").cgColor]
    }
}

