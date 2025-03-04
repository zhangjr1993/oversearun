//
//  BaseTextView.swift
//  AIRun
//
//  Created by AIRun on 20247/19.
//

import UIKit

@IBDesignable

open class BaseTextView: UITextView {
    public let placeLabel: UILabel = UILabel()
    private var placeLabelConstraints = [NSLayoutConstraint]()
    @IBInspectable open var placeholder: String = "" {
        didSet {
            placeLabel.text = placeholder
        }
    }
    override open var font: UIFont! {
        didSet {
            if placeholdFont == nil {
                placeLabel.font = font
            }
        }
    }
    open var placeholdFont: UIFont? {
        didSet {
            let font = (placeholdFont != nil) ? placeholdFont : self.font
            placeLabel.font = font
        }
    }
    
    open var placeholdColor: UIColor? {
        didSet {
            placeLabel.textColor = placeholdColor
        }
    }
    override open var textAlignment: NSTextAlignment {
        didSet {
            placeLabel.textAlignment = textAlignment
        }
    }
    override open var text: String! {
        didSet {
            textDidChange()
        }
    }
    override open var attributedText: NSAttributedString! {
        didSet {
            textDidChange()
        }
    }
    
    override open var textContainerInset: UIEdgeInsets {
        didSet {
            updateConstraintsForPlaceholderLabel()
        }
    }
    
    override public init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    
    private func commonInit() {
      
        NotificationCenter.default.addObserver(self,
            selector: #selector(textDidChange),name:  UITextView.textDidChangeNotification, object: nil)
        
        self.backgroundColor = .appGaryColor()
        placeLabel.font = font
        placeLabel.textColor = UIColor.appTitle3Color()
        placeLabel.textAlignment = textAlignment
        placeLabel.text = placeholder
        placeLabel.numberOfLines = 0
        placeLabel.backgroundColor = UIColor.clear
        placeLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(placeLabel)
        updateConstraintsForPlaceholderLabel()
    }
    
    private func updateConstraintsForPlaceholderLabel() {
        var newConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(\(textContainerInset.left + textContainer.lineFragmentPadding))-[placeholder]",
            options: [],
            metrics: nil,
            views: ["placeholder": placeLabel])
        newConstraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-(\(textContainerInset.top))-[placeholder]",
            options: [],
            metrics: nil,
            views: ["placeholder": placeLabel])
        newConstraints.append(NSLayoutConstraint(
            item: self,
            attribute: .height,
            relatedBy: .greaterThanOrEqual,
            toItem: placeLabel,
            attribute: .height,
            multiplier: 1.0,
            constant: textContainerInset.top + textContainerInset.bottom
        ))
        newConstraints.append(NSLayoutConstraint(
            item: placeLabel,
            attribute: .width,
            relatedBy: .equal,
            toItem: self,
            attribute: .width,
            multiplier: 1.0,
            constant: -(textContainerInset.left + textContainerInset.right + textContainer.lineFragmentPadding * 2.0)
            ))
        removeConstraints(placeLabelConstraints)
        addConstraints(newConstraints)
        placeLabelConstraints = newConstraints
    }
    
    @objc private func textDidChange() {
        placeLabel.isHidden = !text.isEmpty
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        placeLabel.preferredMaxLayoutWidth = textContainer.size.width - textContainer.lineFragmentPadding * 2.0
    }

    deinit {
        
        NotificationCenter.default.removeObserver(self,
            name: UITextView.textDidChangeNotification,
            object: nil)
    }
    
}
