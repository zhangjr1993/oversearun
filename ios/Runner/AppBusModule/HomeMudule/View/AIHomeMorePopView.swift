//
//  AIHomeMorePopView.swift
//  AIRun
//
//  Created by Bolo on 2025/1/23.
//

import UIKit

/// 拉黑和举报
class AIHomeMorePopView: BasePopView {

    var morePopHandle: ((_ index: Int, _ isBlock: Bool) -> Void)?
    private let bag: DisposeBag = DisposeBag()
    private var showOffset: CGFloat = 0
    private var isBlock = false
    
    init(show point: CGPoint, isBlock: Bool) {
        super.init()
        self.showOffset = point.y + 31
        self.isBlock = isBlock
        self.bgColor = .clear
        self.createUI()
        self.createUILimit()
        self.addEvent()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var hideBtn = UIButton().then {
        $0.backgroundColor = .clear
    }
    
    private lazy var containerView = UIImageView().then {
        $0.isUserInteractionEnabled = true
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 16
        let img = UIImage.createGradientImg(colors: UIColor.popupBgColors(), size: CGSize(width: 131, height: 112), type: .topToBottom)
        $0.image = img
    }
    
    private lazy var reportBtn = LayoutButton().then {
        $0.backgroundColor = .clear
        $0.imageSize = CGSize(width: 18, height: 18)
        $0.midSpacing = 12
        $0.titleLabel?.font = .regularFont(size: 15)
        $0.setImage(UIImage.imgNamed(name: "icon_aihome_more_report"), for: .normal)
        $0.setTitle("Report", for: .normal)
        $0.setTitleColor(UIColor.whiteColor(alpha: 0.87), for: .normal)
    }
    
    private lazy var blockBtn = LayoutButton().then {
        $0.backgroundColor = .clear
        $0.imageSize = CGSize(width: 18, height: 18)
        $0.midSpacing = 12
        $0.titleLabel?.font = .regularFont(size: 15)
        $0.setImage(UIImage.imgNamed(name: "icon_aihome_more_unblock"), for: .normal)
        $0.setTitle(" Block", for: .normal)
        $0.setTitleColor(UIColor.whiteColor(alpha: 0.87), for: .normal)
    }
}

extension AIHomeMorePopView {
    private func createUI() {
        self.addSubview(hideBtn)
        self.addSubview(containerView)
        containerView.addSubview(reportBtn)
        containerView.addSubview(blockBtn)
        blockBtn.setTitle(isBlock ? "Unblock" : "Block", for: .normal)
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
            make.top.equalTo(self.showOffset)
            make.size.equalTo(CGSize(width: 131, height: 102))
        }
        reportBtn.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(10)
            make.height.equalTo(blockBtn.snp.height)
            make.bottom.equalTo(blockBtn.snp.top)
        }
        blockBtn.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            // 纵向对齐
            make.leading.equalToSuperview().offset(-6)
            make.bottom.equalTo(-10)
        }
    }
    
    private func addEvent() {
        hideBtn.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.hide()
        }).disposed(by: bag)
        
        reportBtn.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.morePopHandle?(1, false)
            self.hide()
        }).disposed(by: bag)
        
        blockBtn.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.morePopHandle?(2, self.isBlock)
            self.hide()
        }).disposed(by: bag)
    }
}
