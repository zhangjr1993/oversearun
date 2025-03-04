//
//  AIEditMainExplanPopView.swift
//  AIRun
//
//  Created by Bolo on 2025/2/8.
//

import UIKit

class AIEditMainExplanPopView: BasePopView {

    private let bag: DisposeBag = DisposeBag()
    private var showPoint: CGPoint = .zero
    
    init(point: CGPoint, type: AIEditSectionType) {
        super.init()
        self.showPoint = point
        self.bgColor = .clear
        self.createUI()
        self.createUILimit()
        self.addEvent()
        self.setContentText(type)
    }
    
    @MainActor required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var hideBtn = UIButton().then {
        $0.backgroundColor = .clear
    }
    
    private lazy var containerView = UIImageView().then {
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 16
        let img = UIImage.createGradientImg(colors: UIColor.popupBgColors(), size: CGSize(width: 131, height: 158), type: .topToBottom)
        $0.image = img
    }
    
    private lazy var contentLab = UILabel().then {
        $0.numberOfLines = 0
        $0.textColor = .white
        $0.font = .mediumFont(size: 15)
    }
}

extension AIEditMainExplanPopView {
    private func createUI() {
        self.addSubview(hideBtn)
        self.addSubview(containerView)
        containerView.addSubview(contentLab)
    }
    
    private func createUILimit() {
        self.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: UIScreen.screenWidth, height: UIScreen.screenHeight))
        }
        hideBtn.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        containerView.snp.makeConstraints { make in
            make.trailing.equalTo(-16)
            make.top.equalTo(self.showPoint.y + 8)
        }
        
        contentLab.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(12)
            make.width.equalTo(273)
            make.top.bottom.equalToSuperview().inset(10)
        }
    }
    
    private func addEvent() {
        hideBtn.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.hide()
        }).disposed(by: bag)
    }
    
    private func setContentText(_ type: AIEditSectionType) {
        let text: String
        
        if type == .visibility {
            text =  """
                    Who is allowed to talk to them?
                    If you are not the creator of this bot, please kindly set it as Private. We will need to set your bot to private or transfer it to the original creator
                    if they request it.
                    """
        }else if type == .rating {
            text =  """
                    Different ratings correspond to different tags displayed below. Also note: If you choose the Filtered rating, no Unfiltered related sensitive words can appear, otherwise it will be banned for violating community standards. If you want to view Unfiltered content, remember to turn off the
                    Unfiltered switch in home page
                    """
        }else if type == .intro {
            text =  """
                    How would your character describe themselves?
                    This description will
                    appear on your character detail page and home page, but
                    it won' t be included in prompts or affect your character.
                    If you want your character to be public, it' s best to write it down.
                    """
        }else if type == .greet {
            text =  """
                    What would you say to start a conversation?
                    The content of greetings will only be included in short-term memory.
                    Greeting being too long or too short may lead to suboptimal responses or poor memory.
                    """
        }else if type == .pic {
            text =  """
                    The pictures will be sent to users by AI during the conversation, and the
                    Pictures
                    timing of sending will be automatically determined by AI.
                    """
        }else {
            text =  """
                    How would your character describe themselves?
                    The content of personality will be stored in long-term memory.
                    The current circumstances and context of the conversation and the characters.
                    """
        }
        
        contentLab.attributedText = text.convertToRichText(font: .mediumFont(size: 15), color: .white)
        
        let size = contentLab.sizeThatFits(CGSize(width: UIScreen.adaptWidth(273), height: CGFLOAT_MAX))
        contentLab.snp.remakeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(12)
            make.width.equalTo(UIScreen.adaptWidth(273))
            make.height.equalTo(size.height)
            make.top.bottom.equalToSuperview().inset(10)
        }
        
        if showPoint.y + 8 + size.height + 20 > UIScreen.screenHeight {
            self.containerView.snp.remakeConstraints { make in
                make.trailing.equalTo(-16)
                make.bottom.equalTo(-UIScreen.screenHeight + self.showPoint.y - 16)
            }
        }
    }
}
