//
//  HomeSearchBarView.swift
//  AIRun
//
//  Created by Bolo on 2025/1/22.
//

import UIKit

class HomeSearchBarView: UIView {
    
    var sendSearchHandle: ((_ text: String) -> Void)?
    var clearSearchTextHandle: (() -> Void)?
    private let bag: DisposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.createUI()
        self.createUILimit()
        self.addEvent()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var backBtn = UIButton().then {
        $0.setImage(UIImage.imgNamed(name: "btn_back_White"), for: .normal)
    }
    
    private lazy var containerView = UIView().then {
        $0.backgroundColor = .whiteColor(alpha: 0.1)
        $0.layer.cornerRadius = 17
        $0.layer.masksToBounds = true
    }
    
    lazy var searchTF = UITextField().then {
        $0.font = .regularFont(size: 15)
        $0.textColor = .whiteColor(alpha: 0.87)
        $0.attributedPlaceholder = NSAttributedString.init(string: "Search Characters", attributes: [.foregroundColor: UIColor.whiteColor(alpha: 0.2), .font: UIFont.regularFont(size: 15)])
        $0.clearButtonMode = .whileEditing
        $0.updateClearImage(named: "btn_search_delete")
        $0.delegate = self
        $0.returnKeyType = .search
    }
    
    private lazy var iconImgView = UIImageView().then {
        $0.image = UIImage.imgNamed(name: "icon_search_search")
    }
}

extension HomeSearchBarView {
    private func createUI() {
        addSubview(backBtn)
        addSubview(containerView)
        containerView.addSubview(iconImgView)
        containerView.addSubview(searchTF)
    }
    
    private func createUILimit() {
        backBtn.snp.makeConstraints { make in
            make.width.height.equalTo(24)
            make.leading.equalTo(16)
            make.bottom.equalTo(-9)
        }
        containerView.snp.makeConstraints { make in
            make.leading.equalTo(backBtn.snp.trailing).offset(6)
            make.centerY.equalTo(backBtn)
            make.trailing.equalTo(-16)
            make.height.equalTo(34)
        }
        iconImgView.snp.makeConstraints { make in
            make.leading.equalTo(12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }
        searchTF.snp.makeConstraints { make in
            make.leading.equalTo(iconImgView.snp.trailing).offset(4)
            make.trailing.equalTo(-12)
            make.centerY.equalToSuperview()
            make.height.equalTo(20)
        }
    }
    
    private func addEvent() {
        searchTF.rx.controlEvent(.editingChanged).subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            
            var text = self.searchTF.text ?? ""
            // 替换多个连续的空格为单个空格
            text = text.replacingOccurrences(of: " +", with: " ", options: .regularExpression)
            self.searchTF.text = text
            
            if self.searchTF.markedTextRange == nil, let text = self.searchTF.text, text.count > 30 {
                self.searchTF.text = text.substring(to: 30)
            }
            
            if text.isValidStr == false {
                self.clearSearchTextHandle?()
            }
            
        }).disposed(by: bag)
    }
}

extension HomeSearchBarView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // 禁止换行
        if string == "\n" {
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let text = self.searchTF.text ?? ""
        self.searchTF.resignFirstResponder()
        self.sendSearchHandle?(text)
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        self.clearSearchTextHandle?()
        return true
    }
}
