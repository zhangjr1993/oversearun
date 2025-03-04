//
//  MsgBaseTableCell.swift
//  AIRun
//
//  Created by AIRun on 20247/20.
//

import UIKit

protocol MessageCellDelegate: NSObjectProtocol {

    // 长按消息回调
    func onLongPressMessage(cell: MsgBaseTableCell?)
    // 重发回调
    func onRetryMessage(cell: MsgBaseTableCell?)
    // 选择消息回调
    func onSelectMessage(cell: MsgBaseTableCell?)
    // AI回复动效
    func onTypewriterAnimationMessage(cell: MsgBaseTableCell?, isAnimate: Bool)
    // 图文消息图片加载完后回调刷新
    func onRefreshImageMessage(cell: MsgBaseTableCell?)
}

class MsgBaseTableCell: UITableViewCell {

    var baseCellData: MsgBaseCellData!
    
    let maxWidth: CGFloat = UIScreen.screenWidth - 58 - 49 - 24
    
    var bag: DisposeBag = DisposeBag()
    weak var delegate: MessageCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    deinit {
        
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.backgroundColor = UIColor.clear
        self.backgroundColor = UIColor.clear
        self.selectionStyle = .none
        createSubviews()
        bindEvents()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    lazy var headPicView: UIImageView = {
        let imgV = UIImageView()
        imgV.layer.cornerRadius = 17
        imgV.layer.masksToBounds = true
        return imgV
    }()
    
    lazy var nickLab: UILabel = {
        let lab = UILabel()
        lab.textColor = .white
        lab.font = .regularFont(size: 15)
        return lab
    }()

    lazy var indicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .medium)
        return view
    }()

    lazy var reTryBtn: UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.setTitle("Resend", for: .normal)
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.titleLabel?.font = .mediumFont(size: 12)
        btn.layer.cornerRadius = 4
        btn.backgroundColor = UIColor.appRedColor()
        btn.layer.masksToBounds = true
        return btn
    }()
    
    lazy var bubbleImgView: UIImageView = {
        let imgView = UIImageView()
        imgView.contentMode = .scaleToFill
        imgView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return imgView
    }()
    

    func createSubviews() {
        contentView.addSubview(headPicView)
        contentView.addSubview(nickLab)
        contentView.addSubview(containerView)
        contentView.addSubview(indicator)
        contentView.addSubview(reTryBtn)
        containerView.addSubview(bubbleImgView)
        
        bubbleImgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func creteUILimit() {
        self.nickLab.isHidden = self.baseCellData.direction == .outGoing
        if self.baseCellData.direction == .inComing {
            
            self.headPicView.snp.remakeConstraints { make in
                make.leading.equalTo(16)
                make.top.equalTo(8)
                make.width.height.equalTo(34)
            }
            self.nickLab.snp.makeConstraints { make in
                make.leading.equalTo(headPicView.snp.trailing).offset(8)
                make.width.lessThanOrEqualTo(maxWidth)
                make.top.equalTo(headPicView.snp.top)
                make.height.equalTo(16)
            }
            self.containerView.snp.remakeConstraints { make in
                make.leading.equalTo(nickLab.snp.leading)
                make.top.equalTo(nickLab.snp.bottom).offset(6)
                make.bottom.equalToSuperview().offset(-8)
            }
            self.indicator.snp.remakeConstraints { make in
                make.leading.equalTo(self.containerView.snp.trailing).offset(8)
                make.centerY.equalTo(self.containerView)
            }
            self.reTryBtn.snp.remakeConstraints { make in
                make.leading.equalTo(self.containerView.snp.trailing).offset(8)
                make.size.equalTo(CGSize(width: 54, height: 20))
                make.centerY.equalTo(self.containerView)
            }
        }else {
            
            self.headPicView.snp.remakeConstraints { make in
                make.trailing.equalTo(-16)
                make.top.equalTo(8)
                make.width.height.equalTo(34)
            }
            self.containerView.snp.remakeConstraints { make in
                make.trailing.equalTo(headPicView.snp.leading).offset(-8)
                make.top.equalTo(headPicView.snp.top)
                make.bottom.equalToSuperview().offset(-8)
            }
            self.indicator.snp.remakeConstraints { make in
                make.trailing.equalTo(self.containerView.snp.leading).offset(-8)
                make.centerY.equalTo(self.containerView)
            }
            self.reTryBtn.snp.remakeConstraints { make in
                make.trailing.equalTo(self.containerView.snp.leading).offset(-8)
                make.size.equalTo(CGSize(width: 54, height: 20))
                make.centerY.equalTo(self.containerView)
            }
        }
    }
    
    func bindEvents() {
        
        let tap = UITapGestureRecognizer()
        tap.numberOfTapsRequired = 1
        tap.numberOfTouchesRequired = 1
        tap.delegate = self
        self.containerView.addGestureRecognizer(tap)
        tap.rx.event.subscribe(onNext: { [weak self] _ in
            guard let self else { return }
            self.delegate?.onSelectMessage(cell: self)
        }).disposed(by: bag)
        
        let longTap = UILongPressGestureRecognizer()
        self.containerView.addGestureRecognizer(longTap)
        longTap.rx.event.subscribe(onNext: { [weak self] _ in
            guard let self else { return }
            self.delegate?.onLongPressMessage(cell: self)
        }).disposed(by: bag)
        
        reTryBtn.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] _ in
            guard let self else { return }
            self.delegate?.onRetryMessage(cell: self)
        }).disposed(by: bag)
    }
        
    func fillWithData(data: MsgBaseCellData, chatInfo: ChatInfoDataModel) {
        self.baseCellData = data
        self.bubbleImgView.isHidden = true
        if (self.baseCellData?.msgStatus == .Sending) {
            indicator.startAnimating()
        } else {
            indicator.stopAnimating()
        }
        if (self.baseCellData?.msgStatus == .Fali) {
            reTryBtn.isHidden = false
        } else {
            reTryBtn.isHidden = true
        }
        
        nickLab.text = self.baseCellData.direction == .inComing ? chatInfo.nickname : (APPManager.default.loginUserModel?.user?.nickname ?? "")
        let url = self.baseCellData.direction == .inComing ? chatInfo.headPic : (APPManager.default.loginUserModel?.user?.headPic ?? "")
        headPicView.loadNetImage(url: url)
    }
   
}

extension MsgBaseTableCell {
    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let touchView = touch.view as? YYLabel {
            let attrStr = touchView.attributedText
            let index = touchView.textLayout?.textRange(at: touch.location(in: touchView))?.start.offset ?? 0
            if let hl = attrStr?.attribute(YYTextHighlightAttributeName, at: UInt(index)) {
                return false
            }
        }
        return true
    }
}
class MsgBaseCellData: NSObject {
    
    var reuseId: String = ""
    var msgID: String = ""
    
    var isNeedAnimate = false
    
    var direction: ALMsgDirection
    var msgStatus: ALMsgStatus = .Init

    var chatType: ALConversationType?

    var insertsTop = 8
    var insertsLeft = 58
    var insertsRight = 49
    var insertsBtm = 8
    
    
        
    var innerMessage: V2TIMMessage?

    var msgModel: ALMsgModel?
    
    var bubbleImg: UIImage?

    
    init(direction: ALMsgDirection) {
        self.direction = direction
        self.msgStatus = .Init
        if direction == .inComing {
            let imag = UIImage.imgNamed(name: "img_chat_other")
            let sizex = imag.size
            bubbleImg = imag.resizableImage(withCapInsets: UIEdgeInsets(top: sizex.height*0.5, left: sizex.width*0.5, bottom: sizex.height*0.5, right: sizex.width*0.5), resizingMode: .stretch)
        } else {
            let imag = UIImage.imgNamed(name: "img_chat_me")
            let sizex = imag.size
            bubbleImg = imag.resizableImage(withCapInsets: UIEdgeInsets(top: sizex.height*0.5, left: sizex.width*0.5, bottom: sizex.height*0.5, right: sizex.width*0.5), resizingMode: .stretch)
        }
    }
}


