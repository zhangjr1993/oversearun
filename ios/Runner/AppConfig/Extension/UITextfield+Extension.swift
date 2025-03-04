//
//  UITextfield+Extension.swift
//  AIRun
//
//  Created by AIRun on 20247/13.
//

import Foundation

extension UITextField {
    
    private struct PlaceholderColorKey {
        static var identifier: String = "PlaceholderColorKey"
    }
    
    var placeholderColor: UIColor {
        get {
            return objc_getAssociatedObject(self, &PlaceholderColorKey.identifier) as! UIColor
        }
        set(newColor){
            objc_setAssociatedObject(self, &PlaceholderColorKey.identifier, newColor, .OBJC_ASSOCIATION_COPY_NONATOMIC)
            let attrString = NSMutableAttributedString(string: self.placeholder ?? "", attributes: [NSAttributedString.Key.foregroundColor: newColor, NSAttributedString.Key.font: self.font ?? UIFont.systemFont(ofSize: 15)])
            self.attributedPlaceholder = attrString
        }
    }
    
    func updateClearImage(named: String = "btn_input_delete") {
        if let btn = self.value(forKey: "_clearButton") as? UIButton {
            btn.setImage(UIImage.imgNamed(name: named), for: .normal)
        }else {
            var btn: UIButton?
            for item in self.subviews {
                if item is UIButton {
                    btn = item as? UIButton
                    break
                }
            }
            btn?.setImage(UIImage.imgNamed(name: named), for: .normal)
        }
    }
}
