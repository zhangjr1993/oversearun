//
//  DeleteAccountPopView.swift
//  AIRun
//
//  Created by Bolo on 2025/3/3.
//

import UIKit

class DeleteAccountPopView: BasePopView {

    private let bag: DisposeBag = DisposeBag()
    
    override init() {
        super.init()
        self.createUI()
        self.createUILimit()
        self.addEvent()
    }
    
    @MainActor required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var containerView = UIView().then {
        $0.layer.cornerRadius = 16
        $0.layer.masksToBounds = true
    }
    
    private lazy var ttLab = UILabel().then {
        $0.text = "Before confirming account deletion, please note:"
        $0.font = .blackFont(size: 18)
        $0.textColor = .white
        $0.numberOfLines = 0
    }
    
    private lazy var ddLab = UILabel().then {
        $0.attributedText = "1.Ensure the account has no remaining assets or that you willingly forfeit them. Account assets include membership top-ups, etc. \n2.All information will be deleted, and the account cannot be recovered. After account deletion:".convertToRichText(font: .mediumFont(size: 15), color: .white, lineSpace: 3)
        $0.font = .mediumFont(size: 15)
        $0.textColor = .white
        $0.numberOfLines = 0
    }
    
    private lazy var lineLab = UILabel().then {
        $0.text = " • "
        $0.textColor = .white
        $0.font = .mediumFont(size: 15)
    }
    
    private lazy var userLab = UILabel().then {
        $0.attributedText = "User-related information, such as personal details and private messages, will be deleted and cannot be restored.".convertToRichText(font: .mediumFont(size: 15), color: .white, lineSpace: 3)
        $0.font = .mediumFont(size: 15)
        $0.textColor = .white
        $0.numberOfLines = 0
    }
    
    private lazy var line2Lab = UILabel().then {
        $0.text = " • "
        $0.textColor = .white
        $0.font = .mediumFont(size: 15)
    }
    
    private lazy var youLab = UILabel().then {
        $0.text = "You will be logged out of all devices."
        $0.font = .mediumFont(size: 15)
        $0.textColor = .white
        $0.numberOfLines = 0
    }
    
    private lazy var deleteBtn = UIButton().then {
        $0.layer.cornerRadius = 25
        $0.layer.masksToBounds = true
        $0.backgroundColor = .whiteColor(alpha: 0.05)
        $0.setTitle("Delete", for: .normal)
        $0.setTitleColor(UIColor.whiteColor(alpha: 0.38), for: .normal)
    }
    
    private lazy var cancelBtn = UIButton().then {
        let bgImg = UIImage.createGradientImg(colors: UIColor.appGradientColor(), size: CGSize(width: (UIScreen.screenWidth-108-15)/2, height: 50)).isRoundCorner(25)
        $0.setBackgroundImage(bgImg, for: .normal)
        $0.layer.cornerRadius = 25
        $0.layer.masksToBounds = true
        $0.backgroundColor = .whiteColor(alpha: 0.05)
        $0.setTitle("Cancel", for: .normal)
        $0.setTitleColor(UIColor.appBrownColor(), for: .normal)
    }
    
}

extension DeleteAccountPopView {
    private func createUI() {
        self.addSubview(containerView)
        containerView.addSubview(ttLab)
        containerView.addSubview(ddLab)
        containerView.addSubview(lineLab)
        containerView.addSubview(userLab)
        containerView.addSubview(line2Lab)
        containerView.addSubview(youLab)
        containerView.addSubview(deleteBtn)
        containerView.addSubview(cancelBtn)
    }
    
    private func createUILimit() {

        self.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: UIScreen.screenWidth-48, height: 374))
        }
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        ttLab.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalTo(24)
        }
        ddLab.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalTo(ttLab.snp.bottom).offset(12)
        }
        
        
        lineLab.snp.makeConstraints { make in
            make.leading.equalTo(16)
            make.top.equalTo(ddLab.snp.bottom)
        }
        userLab.snp.makeConstraints { make in
            make.trailing.equalTo(-16)
            make.top.equalTo(ddLab.snp.bottom)
            make.leading.equalTo(32)
        }
        
        line2Lab.snp.makeConstraints { make in
            make.leading.equalTo(16)
            make.top.equalTo(userLab.snp.bottom)
        }
        youLab.snp.makeConstraints { make in
            make.trailing.equalTo(-16)
            make.top.equalTo(userLab.snp.bottom)
            make.leading.equalTo(32)
        }

        deleteBtn.snp.makeConstraints { make in
            make.leading.equalTo(30)
            make.top.equalTo(youLab.snp.bottom).offset(24)
            make.trailing.equalTo(deleteBtn.snp.leading).offset(-15)
            make.width.equalTo((UIScreen.screenWidth-108-15)/2)
            make.height.equalTo(50)
        }
        cancelBtn.snp.makeConstraints { make in
            make.trailing.equalTo(-30)
            make.height.equalTo(50)
            make.width.equalTo((UIScreen.screenWidth-108-15)/2)
            make.top.equalTo(deleteBtn)
        }

        containerView.addGradientLayer(colors: UIColor.popupBgColors(), frame: CGRect(origin: .zero, size: CGSize(width: UIScreen.screenWidth-48, height: 374)), startPoint: .zero, endPoint: CGPoint(x: 0, y: 1))
    }
    
    private func addEvent() {
        deleteBtn.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            AppLoginManager.default.deleteAcountReq()
            self.hide()
        }).disposed(by: bag)
        
        cancelBtn.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.hide()
        }).disposed(by: bag)
    }
}
