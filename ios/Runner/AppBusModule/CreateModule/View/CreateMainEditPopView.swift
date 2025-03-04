//
//  CreateMainEditPopView.swift
//  AIRun
//
//  Created by Bolo on 2025/2/7.
//

import UIKit

class CreateMainEditPopView: BasePopView {

    var clickMainEditPopViewHandle: ((Int) -> Void)?
    private let bag: DisposeBag = DisposeBag()
    private var showPoint: CGPoint = .zero
    
    init(point: CGPoint) {
        super.init()
        self.showPoint = point
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
        let img = UIImage.createGradientImg(colors: UIColor.popupBgColors(), size: CGSize(width: 131, height: 158), type: .topToBottom)
        $0.image = img
    }
    
    private lazy var editBtn = LayoutButton().then {
        $0.midSpacing = 12
        $0.imageSize = CGSize(width: 18, height: 18)
        $0.titleLabel?.font = .regularFont(size: 15)
        $0.setTitle("Edit   ", for: .normal)
        $0.setImage(UIImage.imgNamed(name: "btn_create_more_edit"), for: .normal)
        $0.setTitleColor(UIColor.whiteColor(alpha: 0.87), for: .normal)
    }
    
    private lazy var chatBtn = LayoutButton().then {
        $0.midSpacing = 12
        $0.imageSize = CGSize(width: 18, height: 18)
        $0.titleLabel?.font = .regularFont(size: 15)
        $0.setTitle("Chat   ", for: .normal)
        $0.setImage(UIImage.imgNamed(name: "btn_create_more_chat"), for: .normal)
        $0.setTitleColor(UIColor.whiteColor(alpha: 0.87), for: .normal)
    }
    
    private lazy var deleteBtn = LayoutButton().then {
        $0.midSpacing = 12
        $0.imageSize = CGSize(width: 18, height: 18)
        $0.titleLabel?.font = .regularFont(size: 15)
        $0.setTitle("Delete", for: .normal)
        $0.setImage(UIImage.imgNamed(name: "btn_create_more_delete"), for: .normal)
        $0.setTitleColor(UIColor.whiteColor(alpha: 0.87), for: .normal)
    }
}

extension CreateMainEditPopView {
    private func createUI() {
        self.addSubview(hideBtn)
        self.addSubview(containerView)
        containerView.addSubview(editBtn)
        containerView.addSubview(chatBtn)
        containerView.addSubview(deleteBtn)
    }
    
    private func createUILimit() {
        self.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: UIScreen.screenWidth, height: UIScreen.screenHeight))
        }
        hideBtn.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        if self.showPoint.y + 8 + 158 > UIScreen.screenHeight {
            containerView.snp.makeConstraints { make in
                make.trailing.equalTo(-16)
                make.bottom.equalTo(-UIScreen.screenHeight + self.showPoint.y - 16)
                make.size.equalTo(CGSize(width: 131, height: 158))
            }
        }else {
            containerView.snp.makeConstraints { make in
                make.trailing.equalTo(-16)
                make.top.equalTo(self.showPoint.y + 8)
                make.size.equalTo(CGSize(width: 131, height: 158))
            }
        }
        
        editBtn.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.leading.equalToSuperview().offset(-4)
            make.top.equalTo(14)
            make.size.equalTo(CGSize(width: 131, height: 28+18))
        }
        chatBtn.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(editBtn.snp.bottom)
            make.size.equalTo(CGSize(width: 131, height: 28+18))
        }
        deleteBtn.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(chatBtn.snp.bottom)
            make.size.equalTo(CGSize(width: 131, height: 28+18))
        }
    }
    
    private func addEvent() {
        hideBtn.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.hide()
        }).disposed(by: bag)
        
        editBtn.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.clickMainEditPopViewHandle?(1)
            self.hide()
        }).disposed(by: bag)
        
        chatBtn.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.clickMainEditPopViewHandle?(2)
            self.hide()
        }).disposed(by: bag)
        
        deleteBtn.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.clickMainEditPopViewHandle?(3)
            self.hide()
        }).disposed(by: bag)
    }
}
