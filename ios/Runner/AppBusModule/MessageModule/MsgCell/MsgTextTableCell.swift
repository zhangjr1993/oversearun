//
//  MsgTextTableCell.swift
//  AIRun
//
//  Created by AIRun on 20247/20.
//

import UIKit

class MsgTextTableCell: MsgBaseTableCell {
    

    var textCellData: MsgTextCellData?
    fileprivate var disposeBag = DisposeBag()
    private var typewriterManager: TypewriterAnimationManager?
    private var isAnimating = false
    private var finalAttributedText: NSAttributedString?
    private var finalText: String?
    private var animationWorkItem: DispatchWorkItem?

    
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
    }
    override func createSubviews() {
        super.createSubviews()
        self.containerView.addSubview(italicLabel)
        
        italicLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(12)
            make.top.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-10).priority(.low)
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
        typewriterManager?.stopAnimation()
        isAnimating = false
        
        super.fillWithData(data: data, chatInfo: chatInfo)
        self.textCellData = data as? MsgTextCellData
        bubbleImgView.isHidden = false
        bubbleImgView.image = self.textCellData?.bubbleImg
        
        italicLabel.textColor = self.textCellData?.direction == .inComing ? UIColor.appItalicColor() : UIColor.appBgColor()
        
        guard let text = data.msgModel?.contentModel?.text else {
            printLog(message: "未处理的情况")
            return
        }
        
        self.creteUILimit()
        
        if data.chatType == .privete {
                        
            let attributedText = MsgCellDataManager.createParenthesisAttributedString(from: text)
            if self.textCellData?.direction == .inComing, data.isNeedAnimate {
                startTypewriterAnimation(fullText: attributedText.string, attributedText: attributedText)
            } else {
                italicLabel.attributedText = attributedText
                italicLabel.snp.makeConstraints { make in
                    make.leading.trailing.equalToSuperview().inset(12)
                    make.width.lessThanOrEqualTo(maxWidth)
                    make.top.bottom.equalToSuperview().inset(10)
                }
                // 非动画状态下也更新一次容器大小
                updateContainerSize(with: text, force: true)
            }
        } else {
            let uid = self.textCellData?.msgModel?.fromUid ?? 0
            let imgName: String
            if uid == ALConversationType.userSecretaryId.rawValue {
                imgName = "icon_chat_xiaomi"
            }else {
                imgName = "icon_chat_system"
            }
            self.headPicView.image = UIImage.imgNamed(name: imgName)

            
            italicLabel.text = text
            italicLabel.snp.makeConstraints { make in
                make.leading.trailing.equalToSuperview().inset(12)
                make.width.lessThanOrEqualTo(maxWidth)
                make.top.bottom.equalToSuperview().inset(10)
            }
            // 非动画状态下也更新一次容器大小
            updateContainerSize(with: text, force: true)
        }
    }
    
    private func updateContainerSize(with text: String, force: Bool = false) {
        guard force || isAnimating else { return }
        
        let size = self.italicLabel.sizeThatFits(CGSize(width: self.maxWidth, height: CGFLOAT_MAX))
        let textSize = CGSize(width: size.width, height: size.height+1)
        
        // 使用 UIView.performWithoutAnimation 避免动画过程中的闪烁
        UIView.performWithoutAnimation { [weak self] in
            guard let self = self else { return }
            
            self.italicLabel.snp.remakeConstraints { make in
                make.leading.trailing.equalToSuperview().inset(12)
                make.width.equalTo(textSize.width)
                make.height.equalTo(textSize.height)
                make.top.equalToSuperview().offset(10)
                make.bottom.equalToSuperview().offset(-10).priority(.low)
            }
            
            let containerSize = CGSize(width: textSize.width+12+18, height: textSize.height+20)
            
            if self.textCellData?.direction == .inComing {
                self.containerView.snp.remakeConstraints { make in
                    make.leading.equalTo(self.nickLab.snp.leading)
                    make.top.equalTo(self.nickLab.snp.bottom).offset(6)
                    make.width.equalTo(containerSize.width)
                    make.height.equalTo(containerSize.height)
                    make.bottom.equalToSuperview().offset(-8).priority(.low)
                }
            } else {
                self.containerView.snp.remakeConstraints { make in
                    make.trailing.equalTo(self.headPicView.snp.leading).offset(-8)
                    make.top.equalTo(self.headPicView.snp.top)
                    make.width.equalTo(containerSize.width)
                    make.height.equalTo(containerSize.height)
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
  
}

class MsgTextCellData: MsgBaseCellData {
    
    override init(direction: ALMsgDirection) {
        super.init(direction: direction)
    }
   
}
