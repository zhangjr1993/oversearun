//
//  ChatListTableCell.swift
//  AIRun
//
//  Created by AIRun on 20248/10.
//

import UIKit

class ChatListTableCell: UITableViewCell {
    
    var mid = 0

    private let bag: DisposeBag = DisposeBag()
    public var itemIndex: Int = 0 {
        didSet {
            if itemIndex == 0 {
                containerView.snp.remakeConstraints { make in
                    make.leading.trailing.equalToSuperview().inset(16)
                    make.top.equalToSuperview()
                    make.height.equalTo(68+16)
                }
            }else if itemIndex == -1 {
                containerView.snp.remakeConstraints { make in
                    make.leading.trailing.equalToSuperview().inset(16)
                    make.bottom.equalToSuperview()
                    make.height.equalTo(68+16)
                }
            }else {
                containerView.snp.remakeConstraints { make in
                    make.leading.trailing.equalToSuperview().inset(16)
                    make.height.equalTo(68+16)
                    make.centerY.equalToSuperview()
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    deinit {
        
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.layer.masksToBounds = true
        self.contentView.backgroundColor = UIColor.clear
        self.backgroundColor = UIColor.clear
        self.selectionStyle = .none
        createSubviews()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        return view
    }()
    
    lazy var headImgView: UIImageView = {
        let imgView = UIImageView()
        imgView.layer.cornerRadius = 24
        imgView.clipsToBounds = true
        imgView.image = UIImage.basicPlaceholderImg()
        imgView.contentMode = .scaleAspectFill
        imgView.backgroundColor = .appBgColor()
        return imgView
    }()
    
    lazy var badgeLabel: UILabel = {
        let lab = UILabel()
        lab.backgroundColor = .appRedColor()
        lab.textColor = .white
        lab.font = .mediumFont(size: 13)
        lab.textAlignment = .center
        lab.layer.masksToBounds = true
        lab.layer.cornerRadius = 10
        lab.layer.borderColor = UIColor.white.cgColor
        lab.layer.borderWidth = 1
        lab.isHidden = true
        return lab
    }()
    
    lazy var nameLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .white
        lab.font = .mediumFont(size: 17)
        return lab
    }()
    lazy var contentLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .whiteColor(alpha: 0.6)
        lab.font = UIFont.regularFont(size: 15)
        return lab
    }()
    lazy var timeLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .whiteColor(alpha: 0.6)
        lab.font = UIFont.regularFont(size: 13)
        lab.textAlignment = .right
        lab.setContentCompressionResistancePriority(.required, for: .horizontal)
        return lab
    }()
    
    
    var conversationModel: V2TIMConversation? {
        didSet {
            guard let conversationModel else { return}
            
            if conversationModel.unreadCount > 0 {
                self.badgeLabel.isHidden = false
                self.badgeLabel.text = conversationModel.unreadCount > 99 ? "99+" : "\(conversationModel.unreadCount)"
            }else {
                self.badgeLabel.isHidden = true
            }
            let badgeWidth = self.badgeLabel.sizeThatFits(CGSize(width: UIScreen.screenHeight, height: 20)).width
            self.badgeLabel.snp.updateConstraints { make in
                make.width.equalTo(max(20, badgeWidth+12))
            }
            self.timeLabel.text = ""
            self.contentLabel.text = ""
            if let lastMsg = conversationModel.lastMessage,let date = lastMsg.timestamp { // 时间展示
                self.timeLabel.text = NSDate.messageTimeString(date: date)
            }
            
            if let draftText = conversationModel.draftText , draftText.isValidStr {
                let tempAttributedStr = NSMutableAttributedString()
                tempAttributedStr.append(NSAttributedString(string: "[Draft]",attributes: [.foregroundColor: UIColor.appRedColor()]))
                tempAttributedStr.append(NSAttributedString(string: draftText,attributes: [.foregroundColor: UIColor.appTitle2Color()]))
                self.contentLabel.attributedText = tempAttributedStr
            }else{
                if !self.showContentLabelText(msg: conversationModel.lastMessage) {
                    updateListShowMessage()
                }
            }
            
            let mid = conversationModel.userID.intValue
            self.mid = mid
            if let cacheModel = AppDBManager.default.getAIBasicInfoData(mid: mid) {
                nameLabel.text = cacheModel.nickname
                headImgView.loadNetImage(url: cacheModel.headPic)

            }else if mid == ALConversationType.userSystemId.rawValue || mid == ALConversationType.userSecretaryId.rawValue {

                nameLabel.text = mid == ALConversationType.userSecretaryId.rawValue ? "Offical Notice" : "System Message"
                headImgView.image = UIImage.imgNamed(name: mid == ALConversationType.userSecretaryId.rawValue ? "icon_chat_xiaomi" : "icon_chat_system")
            }else {
                nameLabel.text = conversationModel.showName
                headImgView.loadNetImage(url: conversationModel.faceUrl ?? "")
            }
        }
    }
    
    
    func updateListShowMessage() {

        if let userID = conversationModel?.userID {
            V2TIMManager.sharedInstance().getC2CHistoryMessageList(userID, count: 10, lastMsg: nil) { msgs in
                if let tempMsgs = msgs {
                    for msg in tempMsgs {
                        if self.showContentLabelText(msg: msg) {
                            break
                        }
                    }
                }
            } fail: { code, errorStr in
            }
        }
    }
    func showContentLabelText(msg: V2TIMMessage?) -> Bool {

        var isShowText = false
//        var contentColor = UIColor.whiteColor(alpha: 0.6)
        if let lastMsg = msg {
            if let extraStr = String(data: lastMsg.customElem.data, encoding: .utf8), let msgModel = ALMsgModel.deserialize(from: extraStr) {
                if msgModel.msgType == 1 {
                    if let contentModel = ALMsgContentModel.deserialize(from: msgModel.msgContent) {
                        self.contentLabel.text = contentModel.text
                        isShowText = true
                    }
                }else if msgModel.msgType == 2 {
                    if let contentModel = ALMsgContentModel.deserialize(from: msgModel.msgContent) {
                        self.contentLabel.text = contentModel.text
                        isShowText = true
                    }
                }else if msgModel.msgType == 6 {
                    if let contentModel = ALMsgContentModel.deserialize(from: msgModel.msgContent) {
                        if contentModel.text.isValidStr {
                            self.contentLabel.text = contentModel.text
                        }else {
                            let enumType = contentModel.msg_enum
                            self.contentLabel.text = MsgCellDataManager.getLocalEnumMsgContent(msgEnumType: enumType)
                        }
                        isShowText = true
                    }
                }
            }
        }
//        self.contentLabel.textColor = contentColor
        return isShowText
    }
        
    func createSubviews() {
        contentView.addSubview(containerView)
        contentView.addSubview(headImgView)
        contentView.addSubview(badgeLabel)
        contentView.addSubview(nameLabel)
        contentView.addSubview(contentLabel)
        contentView.addSubview(timeLabel)
        
        containerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(68+16)
            make.centerY.equalToSuperview()
        }
        headImgView.snp.makeConstraints { make in
            make.leading.equalTo(16)
            make.top.equalTo(10)
            make.width.height.equalTo(48)
        }
        badgeLabel.snp.makeConstraints { make in
            make.top.equalTo(headImgView.snp.top).offset(-8)
            make.trailing.equalTo(headImgView.snp.trailing).offset(8)
            make.width.height.equalTo(20)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(headImgView.snp.trailing).offset(12)
            make.trailing.equalTo(timeLabel.snp.leading).offset(-8)
            make.top.equalTo(headImgView.snp.top).offset(2)
        }
        contentLabel.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel)
            make.trailing.equalTo(-16)
            make.top.equalTo(nameLabel.snp.bottom).offset(8)
        }
        timeLabel.snp.makeConstraints { make in
            make.trailing.equalTo(-16)
            make.width.greaterThanOrEqualTo(0)
            make.centerY.equalTo(nameLabel)
        }
        
        
    }
   
}

extension UITableViewCell {
    /// 给UITableView的Section切圆角 在willDisplaycell方法里面调用
    @objc func lgl_tableView(tableView:UITableView, cellCornerRadius cornerRadius: CGFloat, forRowAt indexPath: IndexPath) {
        // 圆率
        let cornerRadii = CGSize(width: cornerRadius, height: cornerRadius)
        // 每一段的行数
        let numberOfRows = tableView.numberOfRows(inSection: indexPath.section)
        // 绘制曲线
        var bezierPath: UIBezierPath?
        if numberOfRows == 1 {
            bezierPath = lgl_bezierRoundedPath(.allCorners, cornerRadii)
        } else {
            switch indexPath.row {
                case 0: // 第一个切左上右上
                    bezierPath = lgl_bezierRoundedPath([.topLeft, .topRight], cornerRadii)
                case numberOfRows-1: // 最后一个切左下右下
                    bezierPath = lgl_bezierRoundedPath([.bottomLeft, .bottomRight], cornerRadii)
                default:
                    bezierPath = lgl_bezierPath()
            }
        }
        lgl_cellAddLayer(bezierPath!)
    }
    
    /// 切圆角
    private func lgl_bezierRoundedPath(_ corners:UIRectCorner, _ cornerRadii:CGSize) -> UIBezierPath {
        return UIBezierPath.init(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: cornerRadii)
    }
    /// 不切圆角
    private func lgl_bezierPath() -> UIBezierPath {
        return UIBezierPath.init(rect: self.bounds)
    }
    
    /// 添加到cell上
    private func lgl_cellAddLayer(_ bezierPath:UIBezierPath)  {
        self.backgroundColor = .clear
         // 新建一个图层
        let layer = CAShapeLayer()
        // 图层边框路径
        layer.path = bezierPath.cgPath
        
        // 图层填充色,也就是cell的底色
//        layer.fillColor = UIColor.red.cgColor
        
        layer.fillColor = UIColor.white.cgColor
//      layer.strokeColor = UIColor.red.cgColor
        
        self.layer.insertSublayer(layer, at: 0)
    }

}
