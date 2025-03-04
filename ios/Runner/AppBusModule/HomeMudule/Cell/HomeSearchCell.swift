//
//  HomeSearchCell.swift
//  AIRun
//
//  Created by Bolo on 2025/1/22.
//

import UIKit

class HomeSearchCell: UITableViewCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.createUI()
        self.createUILimit()
        self.addEvent()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    private lazy var containerView = UIView().then {
        $0.backgroundColor = .whiteColor(alpha: 0.05)
        $0.layer.cornerRadius = 12
    }
    
    private lazy var headerImgView = UIImageView().then {
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 8
    }
    
    private lazy var nickLab = UILabel().then {
        $0.textColor = .white
        $0.font = .mediumFont(size: 16)
    }
    
    private lazy var profileLab = UILabel().then {
        $0.textColor = .whiteColor(alpha: 0.38)
        $0.font = .regularFont(size: 15)
        $0.numberOfLines = 4
    }
    
    private lazy var chatImgView = UIImageView().then {
        $0.image = UIImage.imgNamed(name: "icon_home_chat")
    }
    
    private lazy var chatNumLab = UILabel().then {
        $0.font = .regularFont(size: 14)
        $0.textColor = UIColor.whiteColor(alpha: 0.6)
    }
}

extension HomeSearchCell {
    func loadDataModel(_ model: HomeSearchModel, _ keys: String) {
        let attributedStr = NSMutableAttributedString(string: model.nickname, attributes: [.font: UIFont.mediumFont(size: 16), .foregroundColor: UIColor.white])
        
        // Create regex pattern for case-insensitive search
        if let regex = try? NSRegularExpression(pattern: NSRegularExpression.escapedPattern(for: keys), options: .caseInsensitive) {
            let range = NSRange(model.nickname.startIndex..., in: model.nickname)
            let matches = regex.matches(in: model.nickname, options: [], range: range)
            
            // Apply highlight color to all matches
            matches.forEach { match in
                attributedStr.addAttribute(.foregroundColor, value: UIColor.appYellowColor(), range: match.range)
            }
        }
        
        self.nickLab.attributedText = attributedStr
        self.profileLab.text = model.profile
        self.chatNumLab.text = model.msgNum
        self.headerImgView.loadNetImage(url: model.headPic, cropType: .equalProportion)
        
        self.profileLab.snp.updateConstraints { make in
            make.bottom.equalTo(model.profile.isValidStr ? -10 : -4)
        }
    }
}

extension HomeSearchCell {
    private func createUI() {
        self.selectionStyle = .none
        self.backgroundColor = .clear

        contentView.addSubview(containerView)
        containerView.addSubview(headerImgView)
        containerView.addSubview(nickLab)
        containerView.addSubview(chatImgView)
        containerView.addSubview(chatNumLab)
        containerView.addSubview(profileLab)
    }
    
    private func createUILimit() {
        containerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalTo(12)
            make.height.greaterThanOrEqualTo(70)
            make.bottom.equalToSuperview()
        }
        
        headerImgView.snp.makeConstraints { make in
            make.leading.top.equalTo(12)
            make.width.height.equalTo(48)
        }
        nickLab.snp.makeConstraints { make in
            make.leading.equalTo(headerImgView.snp.trailing).offset(8)
            make.trailing.equalToSuperview().inset(12)
            make.top.equalTo(headerImgView.snp.top).offset(2)
            make.height.equalTo(19)
        }
        chatImgView.snp.makeConstraints { make in
            make.leading.equalTo(nickLab.snp.leading)
            make.top.equalTo(nickLab.snp.bottom).offset(7)
            make.width.height.equalTo(16)
        }
        chatNumLab.snp.makeConstraints { make in
            make.leading.equalTo(chatImgView.snp.trailing).offset(2)
            make.centerY.equalTo(chatImgView)
        }
       
        profileLab.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(12)
            make.top.equalTo(headerImgView.snp.bottom).offset(8)
            make.bottom.equalTo(-10)
        }
    }
    
    private func addEvent() {
        
    }
}
