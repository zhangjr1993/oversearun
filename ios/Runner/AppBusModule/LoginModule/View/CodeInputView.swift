//
//  CodeInputView.swift
//  AIRun
//
//  Created by AIRun on 2025/1/20.
//

import UIKit

class CodeTextfield: UITextField {
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
}

class CodeInputView: UIView {

    private let bag: DisposeBag = DisposeBag()
    private var itemArray: [UILabel] = []
    private let codeCount = 4

    var fieldTextChangedBlock: ((_ code: String?) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        createUI()
        addEvent()
        setCodeSubViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var textfield: CodeTextfield = {
        let field = CodeTextfield()
        field.backgroundColor = .clear
        field.returnKeyType = .done
        field.isHidden = true
        field.delegate = self
        field.keyboardType = .asciiCapable
        return field
    }()
    lazy var tapBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.backgroundColor = .clear
        return btn
    }()
}

extension CodeInputView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.fieldTextChangedBlock?(self.textfield.text)
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == " " {
            return false
        }
        
        return true
    }
}

extension CodeInputView {
    
    private func createUI() {
        addSubview(textfield)
        addSubview(tapBtn)
        textfield.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        tapBtn.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    private func setCodeSubViews() {
        let itemW: CGFloat = (UIScreen.screenWidth - 75) / CGFloat(codeCount)
        let itemH: CGFloat = 92
        var rect = CGRect(x: 21, y: 0, width: itemW, height: itemH)
        for i in 0..<codeCount {
            let numLab = createNumLab(rect: rect)
            self.addSubview(numLab)
            rect.origin.x = CGRectGetMaxX(rect) + 11
            itemArray.append(numLab)
        }
    }
    
    private func addEvent() {
        tapBtn.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            self.textfield.becomeFirstResponder()
        }).disposed(by: bag)
        
        textfield.rx.controlEvent(.editingChanged).subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            if let text = self.textfield.text {
                if text.count > codeCount {
                    self.textfield.text = String(text.prefix(codeCount))
                }
                //字符串转数组
                var stringArray: [String] = []
                var temp = ""
                
                for index in 0..<text.count {
                    temp = (text as NSString).substring(with: NSMakeRange(index, 1))
                    if temp.isValidStr {
                        stringArray.append(temp)
                    }
                }

                // 设置格子数字
                for i in 0..<self.itemArray.count {
                    let lab = self.itemArray[i]
                    if i < stringArray.count {
                        lab.text = stringArray[i]
                        lab.layer.borderColor = UIColor.whiteColor(alpha: 0.87).cgColor
                    }else {
                        lab.text = ""
                        lab.layer.borderColor = UIColor.whiteColor(alpha: 0.05).cgColor
                    }
                }
            }
            self.fieldTextChangedBlock?(self.textfield.text)
        }).disposed(by: bag)
    }
    
    private func createNumLab(rect: CGRect) -> UILabel {
        let lab = UILabel(frame: rect)
        lab.textColor = .white
        lab.font = .mediumFont(size: 24)
        lab.textAlignment = .center
        lab.layer.cornerRadius = 8
        lab.layer.borderWidth = 1
        lab.layer.borderColor = UIColor.whiteColor(alpha: 0.05).cgColor
        lab.backgroundColor = UIColor.appGaryColor()
        lab.layer.masksToBounds = true
        return lab
    }
}
