//
//  BaseView.swift
//  AIRun
//
//  Created by Bolo on 2025/1/20.
//

import UIKit

class BaseView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.createUI()
        self.createUILimit()
        self.addEvent()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createUI() {
        
    }
    
    func createUILimit() {
        
    }
    
    func addEvent() {
        
    }
}

// MARK: - TextView含背景、字数显示lab
class BaseContainerTextView: UIView {
    /// 编辑回调
    open var editTextDidChanged: ((_ text: String) -> Void)?
    /// 字数限制
    open var maxLimit = 3000 {
        didSet {
            self.limitLab.text = "\(textView.text.count)/\(maxLimit)"
        }
    }
    /// 清除按钮，有内容就要显示的和系统Mode不一致
    open var isCleanMode = true {
        didSet {
            self.clearBtn.isHidden = isCleanMode
        }
    }
    /// 是否显示字数label
    open var isShowLimit = true {
        didSet {
            self.limitLab.isHidden = !isShowLimit
            self.customLayoutSubviews()
        }
    }
    /// 填充默认内容
    open var content: String {
        get {
            return self.textView.text
        }
        set {
            self.textView.text = newValue
            if newValue.count > maxLimit {
                self.textView.text = String(newValue.prefix(maxLimit))
            }
            self.limitLab.text = "\(self.textView.text.count)/\(maxLimit)"
            self.updateBtnStatus()
        }
    }
    // 间距
    open var contentInsets: UIEdgeInsets = UIEdgeInsets(top: 10, left: 12, bottom: -36, right: -12) {
        didSet {
            textView.snp.remakeConstraints { make in
                make.top.equalTo(contentInsets.top)
                make.leading.equalTo(contentInsets.left)
                make.bottom.equalTo(contentInsets.bottom)
                make.trailing.equalTo(contentInsets.right)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createSubviews()
        customLayoutSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var textView = BaseTextView().then {
        $0.textContainer.lineFragmentPadding = 0
        $0.textContainerInset = .zero
        $0.backgroundColor = .clear
        $0.font = .regularFont(size: 15)
        $0.textColor = UIColor.whiteColor(alpha: 0.87)
        $0.placeholdColor = UIColor.whiteColor(alpha: 0.2)
        $0.placeholdFont = .regularFont(size: 15)
        $0.showsVerticalScrollIndicator = false
        $0.delegate = self
    }
    
    lazy var clearBtn = UIButton().then {
        $0.setImage(UIImage.imgNamed(name: "btn_search_delete"), for: .normal)
        $0.setImage(UIImage.imgNamed(name: "btn_search_delete"), for: .highlighted)
        $0.addTarget(self, action: #selector(clickClearBtn), for: .touchUpInside)
    }
    
    lazy var limitLab = UILabel().then {
        $0.textColor = UIColor.whiteColor(alpha: 0.2)
        $0.font = .regularFont(size: 14)
    }
}

extension BaseContainerTextView {
    private func updateBtnStatus() {
        self.clearBtn.isHidden = !(isCleanMode && self.textView.text.count > 0)
    }
    
    @objc private func clickClearBtn() {
        self.content = ""
        self.editTextDidChanged?(self.textView.text)
    }
    
    private func createSubviews() {
        self.backgroundColor = UIColor.init(hexStr: "#282828")
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 8
        
        self.addSubview(textView)
        self.addSubview(limitLab)
        self.addSubview(clearBtn)
    }
    
    public func customLayoutSubviews() {
        
        textView.snp.remakeConstraints { make in
            make.top.equalTo(contentInsets.top)
            make.leading.equalTo(contentInsets.left)
            make.bottom.equalTo(contentInsets.bottom)
            make.trailing.equalTo(contentInsets.right)
        }
        
        limitLab.snp.remakeConstraints { make in
            make.trailing.equalTo(-16)
            make.bottom.equalTo(-8)
        }
        
        if isShowLimit {
            clearBtn.snp.remakeConstraints { make in
                make.centerY.equalTo(limitLab.snp.centerY)
                make.trailing.equalTo(limitLab.snp.leading).offset(-4)
                make.width.height.equalTo(16)
            }
        }else {
            clearBtn.snp.remakeConstraints { make in
                make.centerY.equalTo(limitLab.snp.centerY)
                make.trailing.equalTo(-12)
                make.width.height.equalTo(16)
            }
        }
    }
}

extension BaseContainerTextView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
    
        var text = textView.text ?? ""
        // 替换多个连续的空格为单个空格
        text = text.replacingOccurrences(of: " +", with: " ", options: .regularExpression)
        textView.text = text
        
        if let lang = textView.textInputMode?.primaryLanguage, lang == "zh-Hans", let selectedRange = textView.markedTextRange {
            let position = textView.position(from: selectedRange.start, offset: 0)
            if position != nil {
                return
            }
        }
        
        if let tempStr = textView.text, tempStr.count > maxLimit {
            textView.text = String(tempStr.prefix(maxLimit))
            textView.scrollRangeToVisible(NSRange(location: 0, length: maxLimit))
        }
        
        self.limitLab.text = "\(textView.text.count)/\(maxLimit)"
        self.updateBtnStatus()
        self.editTextDidChanged?(textView.text)
    }
    
    /// 首尾不可换行空格，文中多个换行空格只保留一个
    /// 尾部空格在提交参数时去掉
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // 禁止换行
        if text == "\n" {
            if range.location == 0 {
                return false
            }else {
                let len = range.location-1 > textView.text.count ? textView.text.count-1 : range.location-1
                let lastStr = textView.text.substring(from: len)
                if lastStr == "\n" {
                    return false
                }
                if textView.text.count > range.location {
                    let behindStr = textView.text.substring(from: range.location)
                    if behindStr == "\n" {
                        return false
                    }
                }
            }
        }
        
        if text == " " {
            if range.location == 0 {
                return false
            }else {
                let len = range.location-1 > textView.text.count ? textView.text.count-1 : range.location-1
                let lastStr = textView.text.substring(from: len)
                if lastStr == " " {
                    return false
                }
                if textView.text.count > range.location {
                    let behindStr = textView.text.substring(from: range.location)
                    if behindStr == " " {
                        return false
                    }
                }
            }
        }

        return true
    }
}


// MARK: ------------------------------------------------------------------------------------
// MARK: - Textfield含背景、字数显示lab
class BaseContainerTextfield: UIView {
    private let bag: DisposeBag = DisposeBag()
    /// 编辑回调
    open var editDidChanged: ((_ text: String?) -> Void)?
    /// 字数限制
    open var maxLimit = 30 {
        didSet {
            self.limitLab.text = "\(self.textfield.text?.count ?? 0)/\(maxLimit)"
        }
    }
    /// 清除按钮，有内容才显示的和系统Mode不一致
    open var isCleanMode = true {
        didSet {
            self.clearBtn.isHidden = isCleanMode
        }
    }
    open var contentInsets: UIEdgeInsets = UIEdgeInsets(top: 13, left: 12, bottom: -13, right: -12)
    /// 禁止换行
    open var isDisableLine = true
    /// 禁止空格
    open var isDisableSpace = true
    /// 填充默认内容
    open var content: String {
        get {
            return self.textfield.text ?? ""
        }
        set {
            self.textfield.text = newValue
            if newValue.count > maxLimit {
                self.textfield.text = String(newValue.prefix(maxLimit))
            }
            self.updateBtnStatus()
            self.limitLab.text = "\(self.textfield.text?.count ?? 0)/\(maxLimit)"
        }
    }
    
    open var placeholder: String? {
        didSet {
            self.textfield.attributedPlaceholder = NSAttributedString.init(string: placeholder ?? "", attributes: [.foregroundColor: UIColor.whiteColor(alpha: 0.2), .font: UIFont.regularFont(size: 15)])
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createSubviews()
        bindEvent()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var textfield = UITextField().then {
        $0.backgroundColor = .clear
        $0.font = .regularFont(size: 15)
        $0.textColor = UIColor.whiteColor(alpha: 0.87)
        $0.delegate = self
    }
    
    lazy var clearBtn = UIButton().then {
        $0.setImage(UIImage.imgNamed(name: "btn_search_delete"), for: .normal)
        $0.setImage(UIImage.imgNamed(name: "btn_search_delete"), for: .highlighted)
        $0.addTarget(self, action: #selector(clickClearBtn), for: .touchUpInside)
    }
    
    lazy var limitLab = UILabel().then {
        $0.textColor = UIColor.whiteColor(alpha: 0.2)
        $0.font = .regularFont(size: 14)
    }
}

extension BaseContainerTextfield {
    private func updateBtnStatus() {
        self.clearBtn.isHidden = !(isCleanMode && (self.textfield.text?.count ?? 0 > 0))
    }
    
    @objc private func clickClearBtn() {
        self.content = ""
        self.editDidChanged?(self.textfield.text)
    }
    
    private func createSubviews() {
        self.backgroundColor = UIColor.init(hexStr: "#282828")
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 8
        
        self.addSubview(textfield)
        self.addSubview(clearBtn)
        self.addSubview(limitLab)
        
        self.clearBtn.isHidden = !isCleanMode
        
        if !isCleanMode {
            textfield.snp.makeConstraints { make in
                make.top.equalTo(contentInsets.top)
                make.leading.equalTo(contentInsets.left)
                make.bottom.equalTo(contentInsets.bottom)
                make.trailing.equalTo(-50+contentInsets.right)
            }
        }else {
            textfield.snp.makeConstraints { make in
                make.top.equalTo(contentInsets.top)
                make.leading.equalTo(contentInsets.left)
                make.bottom.equalTo(contentInsets.bottom)
                make.trailing.equalTo(clearBtn.snp.leading).offset(contentInsets.right)
            }
            clearBtn.snp.makeConstraints { make in
                make.trailing.equalTo(-50)
                make.centerY.equalToSuperview()
                make.width.height.equalTo(16)
            }
        }
        
        limitLab.snp.makeConstraints { make in
            make.trailing.equalTo(-12)
            make.centerY.equalToSuperview()
        }
        
    }
    
    private func bindEvent() {
        textfield.rx.controlEvent(.editingChanged).subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            
            var text = self.textfield.text ?? ""
            // 替换多个连续的空格为单个空格
            text = text.replacingOccurrences(of: " +", with: " ", options: .regularExpression)
            self.textfield.text = text

            if self.textfield.markedTextRange == nil, let text = self.textfield.text, text.count > self.maxLimit {
                self.textfield.text = text.substring(to: self.maxLimit)
            }
            
            if self.textfield.markedTextRange == nil {
                self.limitLab.text = "\(self.textfield.text?.count ?? 0)/\(maxLimit)"
                self.editDidChanged?(self.textfield.text)
            }
            
            self.updateBtnStatus()
            
        }).disposed(by: bag)
    }
}

extension BaseContainerTextfield: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // 禁止换行
        if string == "\n" && self.isDisableLine {
            self.textfield.resignFirstResponder()
            return false
        }
        
        if string == " " {
            if range.location == 0 {
                return false
            }else {
                let text = textField.text ?? ""
                let len = range.location-1 > text.count ? text.count-1 : range.location-1
                let lastStr = text.substring(from: len)
                if lastStr == " " {
                    return false
                }
                if text.count > range.location {
                    let behindStr = text.substring(from: range.location)
                    if behindStr == " " {
                        return false
                    }
                }
            }
        }
        
        return true
    }
    
}

