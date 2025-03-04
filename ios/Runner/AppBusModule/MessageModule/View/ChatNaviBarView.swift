//
//  ChatNaviBarView.swift
//  AIRun
//
//  Created by Bolo on 2025/2/11.
//

import UIKit

class ChatNaviBarView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.createUI()
        self.createUILimit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var backBtn = UIButton().then {
        $0.setImage(UIImage.imgNamed(name: "btn_back_White"), for: .normal)
    }
    
    lazy var nickLab: UILabel = {
        let lab = UILabel()
        lab.textColor = .white
        lab.font = .regularFont(size: 16)
        return lab
    }()
    
    lazy var headPic = UIImageView().then {
        $0.layer.cornerRadius = 17
        $0.layer.masksToBounds = true
    }
    
    lazy var userBtn = UIButton().then {
        $0.backgroundColor = .clear
    }
}

extension ChatNaviBarView {
    func loadChatInfo(model: ChatInfoDataModel, type: ALConversationType) {

        if type == .privete {
            headPic.loadNetImage(url: model.headPic, cropType: .equalProportion)
            nickLab.text = model.nickname
        }else {
            headPic.image = UIImage.imgNamed(name: model.headPic)
            nickLab.text = type == .userSecretaryId ? "Offical Notice" : "System Message"
        }
    }
}

extension ChatNaviBarView {
    private func createUI() {
        self.addSubview(backBtn)
        self.addSubview(headPic)
        self.addSubview(nickLab)
        self.addSubview(userBtn)
    }
    
    private func createUILimit() {
        backBtn.snp.makeConstraints { make in
            make.width.height.equalTo(24)
            make.leading.equalTo(16)
            make.bottom.equalTo(-9)
        }
        headPic.snp.makeConstraints { make in
            make.leading.equalTo(backBtn.snp.trailing).offset(10)
            make.centerY.equalTo(backBtn)
            make.width.height.equalTo(34)
        }
        nickLab.snp.makeConstraints { make in
            make.leading.equalTo(headPic.snp.trailing).offset(8)
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalTo(backBtn)
        }
        userBtn.snp.makeConstraints { make in
            make.leading.equalTo(headPic.snp.leading)
            make.trailing.equalTo(nickLab.snp.trailing)
            make.height.equalTo(34)
            make.centerY.equalTo(backBtn)
        }
    }
    
}
