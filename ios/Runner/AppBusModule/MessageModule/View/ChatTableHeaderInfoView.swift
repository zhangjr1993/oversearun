//
//  ChatTableHeaderInfoView.swift
//  AIRun
//
//  Created by Bolo on 2025/2/13.
//

import UIKit

class ChatTableHeaderInfoView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.createUI()
        self.createUILimit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var nickLab = UILabel().then {
        $0.textColor = .white
        $0.font = .blackFont(size: 16)
        $0.textAlignment = .center
    }
    
    private lazy var headPic = UIImageView().then {
        $0.layer.cornerRadius = 24
        $0.layer.masksToBounds = true
    }
    
    private lazy var profileLab = UILabel().then {
        $0.textColor = .whiteColor(alpha: 0.6)
        $0.font = .regularFont(size: 15)
        $0.numberOfLines = 0
        $0.textAlignment = .center
    }
    
    private lazy var creatorLab = UILabel().then {
        $0.textColor = .whiteColor(alpha: 0.6)
        $0.font = .regularFont(size: 15)
        $0.textAlignment = .center
    }
}

extension ChatTableHeaderInfoView {
    private func createUI() {
        addSubview(headPic)
        addSubview(nickLab)
        addSubview(profileLab)
        addSubview(creatorLab)
    }
    
    private func createUILimit() {
        headPic.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(16)
            make.width.height.equalTo(48)
        }
        nickLab.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalTo(headPic.snp.bottom).offset(8)
            make.height.equalTo(16)
        }
        profileLab.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalTo(nickLab.snp.bottom).offset(4)
        }
        creatorLab.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalTo(profileLab.snp.bottom).offset(4)
            make.height.equalTo(16)
        }
    }
   
    func loadInfoData(model: ChatInfoDataModel) -> CGRect {
        headPic.loadNetImage(url: model.headPic)
        nickLab.text = model.nickname
        profileLab.text = model.profile
        creatorLab.text = "@\(model.creator.nickname)"
        let pSize = profileLab.sizeThatFits(CGSize(width: UIScreen.screenWidth-32, height: CGFLOAT_MAX))
        let height = 32 + 48+8 + 16+4 + pSize.height+4 + 16+4
        return CGRect(origin: .zero, size: CGSize(width: UIScreen.screenWidth, height: height))
    }
    
}
