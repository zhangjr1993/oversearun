//
//  ChatInputView.swift
//  AIRun
//
//  Created by AIRun on 20247/19.
//

import UIKit
import AVFAudio


@objc protocol ChatInputViewDelegate: NSObjectProtocol {
    /// 发消息
    func sendTextMsg(msgStr: String)
    /// 重置对话
    func resetAIMsg()
    /// 键盘底部
    func bottomHeightChanged(height: CGFloat)
    /// 键盘高度
    func inputViewHeightChanged(height: CGFloat)
}


class ChatInputView: UIView {
    // MARK: - 属性声明
    private var bag: DisposeBag = DisposeBag()

    open weak var delegate: ChatInputViewDelegate?

    private var recordStartTime: Date?
    
    private var recorder: AVAudioRecorder?
    private var recordTimer: Timer?
    private var duration: Int = 0
    
    
    
    init() {
        super.init(frame: CGRect.zero)
        createSubviews()
        setupViewsConstraint()
        bindEvents()        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        
    }
    // MARK: - 懒加载初始化
    
    lazy var resetBtn: UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.setImage(UIImage.imgNamed(name: "btn_chat_refresh"), for: .normal)
        btn.setImage(UIImage.imgNamed(name: "btn_chat_refresh"), for: .selected)
        return btn
    }()
    
    
    lazy var chatTextView: BaseTextView = {
        let input = BaseTextView()
        input.font = .regularFont(size: 16)
        input.placeholder = "Enter to send text"
        input.placeholdFont = .regularFont(size: 16)
        input.placeholdColor = .appTitle2Color()
        input.returnKeyType = .send
        input.scrollsToTop = false
        input.delegate = self
        input.backgroundColor = UIColor.init(hexStr: "#323134")
        input.textColor = .appTitle1Color()
        input.textContainerInset = UIEdgeInsets(top: 9, left: 12, bottom: 9, right: 16+32+4)
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont.mediumFont(size: 16)]
        input.typingAttributes = attributes as [NSAttributedString.Key: Any]
        input.layer.cornerRadius = 20
        return input
    }()
    
    lazy var sendBtn = UIButton().then {
        $0.setImage(UIImage.imgNamed(name: "btn_chat_send"), for: .normal)
    }
    
}

extension ChatInputView {
    
    // 添加视图
    private func createSubviews() {
        self.addSubview(chatTextView)
        self.addSubview(resetBtn)
        self.addSubview(sendBtn)
    }
    // 添加约束
    private func setupViewsConstraint() {
        
        chatTextView.snp.makeConstraints { make in
            make.top.equalTo(4)
            make.leading.equalTo(46)
            make.trailing.equalTo(-12)
            make.height.equalTo(40)
        }
        resetBtn.snp.makeConstraints { make in
            make.leading.equalTo(12)
            make.centerY.equalTo(chatTextView)
            make.width.height.equalTo(26)
        }
        
        sendBtn.snp.makeConstraints { make in
            make.trailing.equalTo(-16)
            make.bottom.equalToSuperview()
            make.width.height.equalTo(32)
        }
       
    }
    // 添加事件
    private func bindEvents() {
        NotificationCenter.default.rx.notification( UIResponder.keyboardWillHideNotification)
            .subscribe(onNext: { [weak self] (notification) in
                guard let self = self else { return }
                self.delegate?.bottomHeightChanged(height: 0)
            }).disposed(by: bag)
        
        NotificationCenter.default.rx.notification( UIResponder.keyboardWillShowNotification)
            .subscribe(onNext: { [weak self] (notification) in
                guard let self = self else { return }
                let info = notification.userInfo!
                var kbRect = (info[UIResponder.keyboardFrameEndUserInfoKey]! as! NSValue).cgRectValue
                kbRect = self.convert(kbRect, from: nil)
                let height = kbRect.size.height - UIScreen.safeAreaInsets.bottom
                self.delegate?.bottomHeightChanged(height: height)
            }).disposed(by: bag)
        
        chatTextView.rx.observeWeakly(UITextView.self, "contentSize").subscribe(onNext: { [weak self] (change) in
                guard let self = self else {return}
                self.func__updateInputContentView()
           }).disposed(by: bag)
        
        chatTextView.rx.text.orEmpty.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            if $0.utf16.count > 255 {
                let selectedRange = self.chatTextView.markedTextRange
                if selectedRange == nil {
                    self.chatTextView.text = ($0 as NSString).substring(to: 255)
                }
            }
        }).disposed(by: bag)
        
        resetBtn.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            self.delegate?.resetAIMsg()
            self.chatTextView.resignFirstResponder()
        }).disposed(by: bag)
        
        sendBtn.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.delegate?.sendTextMsg(msgStr: self.chatTextView.text)
        }).disposed(by: bag)
    }
        
    func func__updateInputContentView() {
        let textSize = chatTextView.contentSize
        let textHeight = max(40, min(100, textSize.height))
        chatTextView.snp.updateConstraints { make in
            make.height.equalTo(textHeight)
        }
        self.delegate?.inputViewHeightChanged(height: textHeight+UIScreen.safeAreaInsets.bottom+8)
    }
}

extension ChatInputView: UITextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return true
    }
    func textViewDidChange(_ textView: UITextView) {
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            self.delegate?.sendTextMsg(msgStr: self.chatTextView.text)
            self.chatTextView.text = ""
            return false
        }
        return true
    }
}
