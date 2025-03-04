//
//  MsgTextImageTableCell.swift
//  AIRun
//
//  Created by Bolo on 2025/2/12.
//

import UIKit

// MARK: - 游客的本地插入和msgType==2
class MsgTextImageTableCell: MsgBaseTableCell {
    var textCellData: MsgTextImageCellData?
    
    fileprivate var disposeBag = DisposeBag()
    private let contentMaxWidth: CGFloat = UIScreen.screenWidth - 58 - 49 - 12-18
    private var typewriterManager: TypewriterAnimationManager?
    private var isAnimating = false
    private var finalAttributedText: NSAttributedString?
    private var finalText: String?
    private var animationWorkItem: DispatchWorkItem?
    private var currentImage: UIImage?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        typewriterManager = TypewriterAnimationManager()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
        typewriterManager?.stopAnimation()
        isAnimating = false
        finalAttributedText = nil
        finalText = nil
        animationWorkItem?.cancel()
        animationWorkItem = nil
        currentImage = nil
    }
    override func createSubviews() {
        super.createSubviews()
        self.containerView.addSubview(italicLabel)
        self.containerView.addSubview(picView)
        
        italicLabel.snp.makeConstraints { make in
            make.leading.equalTo(12)
            make.trailing.equalTo(-18)
            make.width.lessThanOrEqualTo(contentMaxWidth)
            make.top.equalTo(8)
        }
        picView.snp.makeConstraints { make in
            make.leading.equalTo(12)
            make.top.equalTo(italicLabel.snp.bottom).offset(8)
            make.width.height.equalTo(166)
            make.bottom.equalTo(-12)
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    override func fillWithData(data: MsgBaseCellData, chatInfo: ChatInfoDataModel) {
        // 停止之前的动画
        typewriterManager?.stopAnimation()
        isAnimating = false
        
        super.fillWithData(data: data, chatInfo: chatInfo)
        self.textCellData = data as? MsgTextImageCellData
        bubbleImgView.isHidden = false
        bubbleImgView.image = self.textCellData?.bubbleImg
        
        self.creteUILimit()
        
        if data.chatType != .privete {
            let uid = self.textCellData?.msgModel?.fromUid ?? 0
            let imgName: String
            if uid == ALConversationType.userSecretaryId.rawValue {
                imgName = "icon_chat_xiaomi"
            }else {
                imgName = "icon_chat_system"
            }
            self.headPicView.image = UIImage.imgNamed(name: imgName)
        }
        
        if let text = data.msgModel?.contentModel?.text {
            let attributedText = MsgCellDataManager.createParenthesisAttributedString(from: text)
            
            if self.textCellData?.direction == .inComing && data.isNeedAnimate {
                startTypewriterAnimation(fullText: attributedText.string, attributedText: attributedText)
            } else {
                italicLabel.attributedText = attributedText
            }
        }
        
        if let imgUrl = data.msgModel?.contentModel?.imgMsg?.imgUrl, imgUrl.isValidStr {
            picView.isHidden = false
            picView.loadNetImage(url: imgUrl) { [weak self] isSucceed, image in
                guard let `self` = self else { return }
                self.currentImage = image
                self.cropPicImage(image)
            }
        } else {
            self.loadFailedImage()
        }
    }
    
    private func loadFailedImage() {
        picView.isHidden = true
        currentImage = nil
        updateContainerSize(with: italicLabel.text ?? "", force: true)
        self.delegate?.onRefreshImageMessage(cell: self)
    }
    
    private func cropPicImage(_ img: UIImage?) {
        guard let img else {
            self.loadFailedImage()
            return
        }
        
        if let cropImg = img.cropMaxWidthImage(maxWidth: 166) {
            self.picView.image = cropImg
            self.currentImage = cropImg
            updateContainerSize(with: italicLabel.text ?? "", force: true)
            self.delegate?.onRefreshImageMessage(cell: self)
        }else {
            self.loadFailedImage()
        }
    }
    
    private func updateContainerSize(with text: String, force: Bool = false) {
        guard force || isAnimating else { return }
        
        let labelSize = self.italicLabel.sizeThatFits(CGSize(width: contentMaxWidth, height: CGFLOAT_MAX))
        
        UIView.performWithoutAnimation { [weak self] in
            guard let self = self else { return }
            
            let imageHeight = self.currentImage?.size.height ?? 0
            let imageWidth = self.currentImage?.size.width ?? 0
            
            self.italicLabel.snp.remakeConstraints { make in
                make.leading.equalTo(12)
                make.width.lessThanOrEqualTo(self.contentMaxWidth)
                make.top.equalTo(8)
                
                if imageWidth < labelSize.width {
                    make.trailing.lessThanOrEqualTo(-18)
                } else {
                    make.trailing.equalTo(self.picView.snp.trailing)
                }
            }
            
            if !self.picView.isHidden {
                self.picView.snp.remakeConstraints { make in
                    make.width.equalTo(imageWidth)
                    make.height.equalTo(imageHeight)
                    make.leading.equalTo(12)
                    if imageWidth > labelSize.width {
                        make.trailing.equalTo(-18)
                    }
                    make.top.equalTo(self.italicLabel.snp.bottom).offset(8)
                    make.bottom.equalTo(-12)
                }
            }
            
            let containerHeight = labelSize.height + (self.picView.isHidden ? 16 : (imageHeight + 28))
            let containerWidth = max(labelSize.width, imageWidth) + 30
            
            if self.textCellData?.direction == .inComing {
                self.containerView.snp.remakeConstraints { make in
                    make.leading.equalTo(self.nickLab.snp.leading)
                    make.top.equalTo(self.nickLab.snp.bottom).offset(6)
                    make.width.equalTo(containerWidth)
                    make.height.equalTo(containerHeight)
                    make.bottom.equalToSuperview().offset(-8).priority(.low)
                }
            } else {
                self.containerView.snp.remakeConstraints { make in
                    make.trailing.equalTo(self.headPicView.snp.leading).offset(-8)
                    make.top.equalTo(self.headPicView.snp.top)
                    make.width.equalTo(containerWidth)
                    make.height.equalTo(containerHeight)
                    make.bottom.equalToSuperview().offset(-8).priority(.low)
                }
            }
            
            self.layoutIfNeeded()
        }
        
        // 使用防抖机制处理滚动
        animationWorkItem?.cancel()
        animationWorkItem = DispatchWorkItem { [weak self] in
            guard let self = self,
                  let tableView = self.superview as? UITableView,
                  let indexPath = tableView.indexPath(for: self),
                  indexPath.row == tableView.numberOfRows(inSection: 0) - 1 else { return }
            
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.25) {
                    tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
                }
            }
        }
        
        if let workItem = animationWorkItem {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: workItem)
        }
    }
    
    private func startTypewriterAnimation(fullText: String, attributedText: NSAttributedString? = nil) {
        isAnimating = true
        finalText = fullText
        finalAttributedText = attributedText
        
        // 预先计算最终大小并设置
        if let attributedText = attributedText {
            self.italicLabel.attributedText = attributedText
        } else {
            self.italicLabel.text = fullText
        }
        updateContainerSize(with: fullText, force: true)
        
        // 重置为初始状态
        self.italicLabel.text = ""
        
        self.delegate?.onTypewriterAnimationMessage(cell: self, isAnimate: true)
        typewriterManager?.startAnimation(
            text: fullText,
            attributedText: attributedText,
            characterDelay: 0.02,
            update: { [weak self] partialText in
                guard let self = self, self.isAnimating else { return }
                
                DispatchQueue.main.async {
                    if let attributedText = attributedText {
                        let partialRange = NSRange(location: 0, length: (partialText as NSString).length)
                        let partialAttributedText = NSAttributedString(attributedString: attributedText.attributedSubstring(from: partialRange))
                        self.italicLabel.attributedText = partialAttributedText
                    } else {
                        self.italicLabel.text = partialText
                    }
                    self.updateContainerSize(with: partialText)
                }
            },
            completion: { [weak self] in
                guard let self = self else { return }
                self.isAnimating = false
                self.textCellData?.isNeedAnimate = false
                
                // 确保显示完整内容
                DispatchQueue.main.async {
                    if let attributedText = self.finalAttributedText {
                        self.italicLabel.attributedText = attributedText
                    } else if let text = self.finalText {
                        self.italicLabel.text = text
                    }
                    self.delegate?.onTypewriterAnimationMessage(cell: self, isAnimate: false)
                    self.updateContainerSize(with: self.finalText ?? "", force: true)
                }
            }
        )
    }
    
    lazy var italicLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .appTitle1Color()
        lab.font = .regularFont(size: 16)
        lab.numberOfLines = 0
        return lab
    }()
    
    lazy var picView = UIImageView().then {
        $0.layer.cornerRadius = 8
        $0.layer.masksToBounds = true
    }

}

class MsgTextImageCellData: MsgBaseCellData {
    
    override init(direction: ALMsgDirection) {
        super.init(direction: direction)
       
    }
    
    
}
