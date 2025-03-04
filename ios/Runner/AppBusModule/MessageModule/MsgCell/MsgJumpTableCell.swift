//
//  MsgJumpTableCell.swift
//  AIRun
//
//  Created by AIRun on 20248/23.
//

import UIKit

/// 枚举消息类型，在官方和私信UI不同
class MsgXiaoMiEnumTableCell: MsgBaseTableCell {
    // 官方
    var jumpCellData: MsgJumpCellData?
    fileprivate var disposeBag = DisposeBag()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func createSubviews() {
        super.createSubviews()
        self.containerView.addSubview(italicLabel)
        
        italicLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(12)
            make.width.lessThanOrEqualTo(maxWidth)
            make.top.equalToSuperview().offset(10)
            make.height.greaterThanOrEqualTo(0)
            make.bottom.equalToSuperview().offset(-10)
        }
    }
    
    /// 显示斜体
    lazy var italicLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .appTitle1Color()
        lab.font = .regularFont(size: 16)
        lab.numberOfLines = 0
        return lab
    }()
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func fillWithData(data: MsgBaseCellData, chatInfo: ChatInfoDataModel) {
        // 停止之前的动画
        
        super.fillWithData(data: data, chatInfo: chatInfo)
        self.jumpCellData = data as? MsgJumpCellData
        bubbleImgView.isHidden = false
        bubbleImgView.image = self.jumpCellData?.bubbleImg
        italicLabel.textColor = self.jumpCellData?.direction == .inComing ? UIColor.appItalicColor() : UIColor.appBgColor()
        
        self.creteUILimit()
        
        let uid = self.jumpCellData?.msgModel?.fromUid ?? 0
        let imgName: String
        if uid == ALConversationType.userSecretaryId.rawValue {
            imgName = "icon_chat_xiaomi"
        }else {
            imgName = "icon_chat_system"
        }
        self.headPicView.image = UIImage.imgNamed(name: imgName)

        let text = self.jumpCellData?.msgModel?.contentModel?.text
        if let enumType = self.jumpCellData?.msgModel?.contentModel?.msg_enum {
            self.italicLabel.text = MsgCellDataManager.getLocalEnumMsgContent(msgEnumType: enumType)
        }else {
            self.italicLabel.text = text ?? ""
        }
    }
    
}

/// 枚举消息类型，在官方和私信UI不同
class MsgJumpTableCell: MsgBaseTableCell {

    // 私信
    var jumpCellData: MsgJumpCellData?
    fileprivate var disposeBag = DisposeBag()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
   
    override func createSubviews() {
        super.createSubviews()
        self.bubbleImgView.isHidden = true
        self.containerView.isHidden = true
        self.headPicView.isHidden = true
        self.nickLab.isHidden = true
        self.contentView.addSubview(bgView)
        bgView.addSubview(blurView)
        bgView.addSubview(italicLabel)

        bgView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(8)
            make.centerX.equalToSuperview()
            make.width.lessThanOrEqualTo(UIScreen.screenWidth-32)
        }
        blurView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        italicLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(10)
            make.top.bottom.equalToSuperview().inset(8)
            make.centerY.equalToSuperview().priority(.low)
        }
        
    }
    
    lazy var italicLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .appTitle1Color()
        lab.font = .regularFont(size: 16)
        lab.numberOfLines = 0
        return lab
    }()
    
    lazy var bgView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        return view
    }()
    
    lazy var blurView: UIVisualEffectView = {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        return view
    }()

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func fillWithData(data: MsgBaseCellData, chatInfo: ChatInfoDataModel) {
        super.fillWithData(data: data, chatInfo: chatInfo)
        self.jumpCellData = data as? MsgJumpCellData

        let tempAttributedStr = NSMutableAttributedString()
        if let enumType = self.jumpCellData?.msgModel?.contentModel?.msg_enum {
            self.italicLabel.text = MsgCellDataManager.getLocalEnumMsgContent(msgEnumType: enumType)
        }else {
            self.italicLabel.attributedText = tempAttributedStr
        }
    }
   

}

class MsgJumpCellData: MsgBaseCellData {
            
    override init(direction: ALMsgDirection) {
        super.init(direction: direction)
    }
   
}

