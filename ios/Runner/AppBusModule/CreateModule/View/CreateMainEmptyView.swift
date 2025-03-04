//
//  CreateMainEmptyView.swift
//  AIRun
//
//  Created by Bolo on 2025/2/7.
//

import UIKit

class CreateMainEmptyView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.createUI()
        self.createUILimit()
        self.addEvent()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var ttLab = UILabel().then {
        $0.text = "Create Character"
        $0.font = .mediumFont(size: 17)
        $0.textColor = .whiteColor(alpha: 0.95)
    }
    
    lazy var createBtn = UIButton().then {
        $0.backgroundColor = .clear
    }
    
    private lazy var cTLab = UILabel().then {
        $0.text = "Create"
        $0.font = .blackFont(size: 26)
        $0.textColor = .white
    }
    
    private lazy var cDLab = UILabel().then {
        $0.text = "Start from scratch and create a new character"
        $0.numberOfLines = 0
        $0.font = .regularFont(size: 14)
        $0.textColor = .whiteColor(alpha: 0.6)
    }
    
    private lazy var cAImgView = UIImageView().then {
        $0.image = UIImage.imgNamed(name: "btn_create_add")
    }
    
    lazy var uploadBtn = UIButton().then {
        $0.backgroundColor = .clear
    }
    
    private lazy var uTLab = UILabel().then {
        $0.text = "Upload"
        $0.font = .blackFont(size: 26)
        $0.textColor = .white
    }
    
    private lazy var uDLab = UILabel().then {
        $0.text = "Upload a json or character card image file"
        $0.numberOfLines = 0
        $0.font = .regularFont(size: 14)
        $0.textColor = .whiteColor(alpha: 0.6)
    }
    
    
    private lazy var uAImgView = UIImageView().then {
        $0.image = UIImage.imgNamed(name: "btn_create_add")
    }
    
    private lazy var ddLab = UILabel().then {
        $0.isHidden = true
        $0.text = "My Characters"
        $0.font = .blackFont(size: 18)
        $0.textColor = .white
    }
}

extension CreateMainEmptyView {
    @discardableResult
    func updateUI(isEmpty: Bool) -> CGFloat {
        if isEmpty {
            createBtn.setBackgroundImage(UIImage.imgNamed(name: "bg_create_create_2"), for: .normal)
            uploadBtn.setBackgroundImage(UIImage.imgNamed(name: "bg_create_upload_2"), for: .normal)
            createBtn.snp.remakeConstraints { make in
                make.top.equalTo(ttLab.snp.bottom).offset(20)
                make.leading.trailing.equalToSuperview().inset(16)
                make.height.equalTo(142)
            }
            uploadBtn.snp.remakeConstraints { make in
                make.top.equalTo(createBtn.snp.bottom).offset(16)
                make.leading.trailing.equalToSuperview().inset(16)
                make.height.equalTo(142)
            }
            self.ddLab.isHidden = true
            return 350
        }else {
            createBtn.setBackgroundImage(UIImage.imgNamed(name: "bg_create_create"), for: .normal)
            uploadBtn.setBackgroundImage(UIImage.imgNamed(name: "bg_create_upload"), for: .normal)
            createBtn.snp.remakeConstraints { make in
                make.top.equalTo(ttLab.snp.bottom).offset(20)
                make.leading.equalToSuperview().inset(16)
                make.width.equalTo(uploadBtn.snp.width)
                make.height.equalTo(188)
            }
            uploadBtn.snp.remakeConstraints { make in
                make.leading.equalTo(createBtn.snp.trailing).offset(11)
                make.top.equalTo(createBtn.snp.top)
                make.trailing.equalToSuperview().inset(16)
                make.height.equalTo(188)
            }
            self.ddLab.isHidden = false
            return 280
        }
    }
}

extension CreateMainEmptyView {
    private func createUI() {
        self.backgroundColor = .clear
        
        self.addSubview(ttLab)
        
        self.addSubview(createBtn)
        createBtn.addSubview(cTLab)
        createBtn.addSubview(cDLab)
        createBtn.addSubview(cAImgView)
        
        self.addSubview(uploadBtn)
        uploadBtn.addSubview(uTLab)
        uploadBtn.addSubview(uDLab)
        uploadBtn.addSubview(uAImgView)
        
        self.addSubview(ddLab)
    }
    
    private func createUILimit() {
        ttLab.snp.makeConstraints { make in
            make.leading.equalTo(16)
            make.top.equalTo(11)
            make.height.equalTo(20)
        }
        
        createBtn.snp.makeConstraints { make in
            make.top.equalTo(ttLab.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(142)
        }
        cTLab.snp.makeConstraints { make in
            make.leading.top.equalTo(12)
        }
        cDLab.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(12)
            make.top.equalTo(cTLab.snp.bottom).offset(2)
        }
        cAImgView.snp.makeConstraints { make in
            make.leading.bottom.equalToSuperview().inset(12)
            make.width.height.equalTo(58)
        }
        
        uploadBtn.snp.makeConstraints { make in
            make.top.equalTo(createBtn.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(142)
        }
        uTLab.snp.makeConstraints { make in
            make.leading.top.equalTo(12)
        }
        uDLab.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(12)
            make.top.equalTo(uTLab.snp.bottom).offset(2)
        }
        uAImgView.snp.makeConstraints { make in
            make.leading.bottom.equalToSuperview().inset(12)
            make.width.height.equalTo(58)
        }
        
        ddLab.snp.makeConstraints { make in
            make.leading.equalTo(16)
            make.top.equalTo(createBtn.snp.bottom).offset(24)
        }
    }
    
    private func addEvent() {
        
    }
}
