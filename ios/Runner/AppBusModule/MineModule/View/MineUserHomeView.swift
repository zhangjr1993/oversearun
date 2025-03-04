//
//  MineUserHomeView.swift
//  AIRun
//
//  Created by Bolo on 2025/2/6.
//

import UIKit

class MineUserHomeView: UIView {
    
    var userHomeViewHandle: ((_ action: Int) -> Void)?
    var reloadHeight: Int = 68 + 123 + Int(UIScreen.statusBarHeight) + 12 
    private let bag: DisposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.createUI()
        self.createUILimit()
        self.addEvent()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var headImgView = UIImageView().then {
        $0.layer.cornerRadius = 20
        $0.layer.masksToBounds = true
    }
    
    private lazy var nickLab = UILabel().then {
        $0.font = .boldSystemFont(ofSize: 16)
        $0.textColor = UIColor.white
    }
    
    private lazy var editBtn = UIButton().then {
        $0.setTitle("Edit Profile", for: .normal)
        $0.setTitleColor(UIColor.whiteColor(alpha: 0.87), for: .normal)
        $0.backgroundColor = UIColor.whiteColor(alpha: 0.1)
        $0.layer.cornerRadius = 16
        $0.layer.masksToBounds = true
        $0.titleLabel?.font = .mediumFont(size: 15)
    }
    
    private lazy var settingBtn = UIButton().then {
        $0.setImage(UIImage.imgNamed(name: "btn_me_setting"), for: .normal)
    }
    
    private lazy var freeContainerView = UIView().then {
        $0.backgroundColor = UIColor.init(hexStr: "#282828")
        $0.layer.cornerRadius = 8
    }
    
    private lazy var freeLab = UILabel().then {
        $0.font = .regularFont(size: 15)
        $0.textColor = UIColor.whiteColor(alpha: 0.6)
    }
    
    private lazy var getFreeBtn = UIButton().then {
        let img = UIImage.createButtonImage(type: .normal, size: CGSize(width: UIScreen.screenWidth-56, height: 73))
        let img2 = UIImage.createColorImg(color: UIColor.init(hexStr: "#282828"))
        $0.setBackgroundImage(img, for: .normal)
        $0.setBackgroundImage(img2, for: .selected)
        $0.layer.cornerRadius = 12
        $0.layer.masksToBounds = true
        $0.backgroundColor = .red
    }
    
    private lazy var freeTitleLab = UILabel().then {
        $0.text = "Get free messages >>"
        $0.font = .mediumFont(size: 16)
        $0.textAlignment = .center
        $0.textColor = UIColor.appBrownColor()
    }
    
    private lazy var vipTipLab = UILabel().then {
        $0.text = "Unlimited free messages during the VIP validity period."
        $0.numberOfLines = 0
        $0.isHidden = true
        $0.font = .mediumFont(size: 16)
        $0.textColor = UIColor.white
    }
    
    private lazy var freeDescLab = UILabel().then {
        $0.text = "Open VIP and enjoy many privileges"
        $0.font = .mediumFont(size: 15)
        $0.textAlignment = .center
        $0.textColor = UIColor.appBrownColor(0.6)
    }

}

extension MineUserHomeView {
    @discardableResult
    func reloadUserInfo() -> Int {
        let user = APPManager.default.loginUserModel?.user
        headImgView.loadNetImage(url: user?.headPic ?? "", cropType: .equalProportion)
        nickLab.text = user?.nickname ?? ""
        
        let vip = APPManager.default.loginUserModel?.vip
        getFreeBtn.isSelected = vip?.vipStatus == .vip
        vipTipLab.isHidden = vip?.vipStatus != .vip
        freeTitleLab.isHidden = vip?.vipStatus == .vip
        freeDescLab.isHidden = vip?.vipStatus == .vip

        let headerH: CGFloat
        if vip?.vipStatus == .vip {
            headerH = 80 + 99 + UIScreen.statusBarHeight
            freeLab.text = "Free Messages: unlimited"
        }else {
            headerH = 80 + 123 + UIScreen.statusBarHeight
            freeLab.text = "Free Messages: \(user?.freeMsgNum ?? 0)/25"
        }
        freeContainerView.snp.updateConstraints { make in
            make.height.equalTo(vip?.vipStatus == .vip ? 99 : 123)
        }
        
        reloadHeight = Int(headerH)
        return Int(headerH)
    }
}

extension MineUserHomeView {
    private func createUI() {
        addSubview(headImgView)
        addSubview(nickLab)
        addSubview(editBtn)
        addSubview(settingBtn)
        
        addSubview(freeContainerView)
        freeContainerView.addSubview(freeLab)
        freeContainerView.addSubview(getFreeBtn)
        getFreeBtn.addSubview(vipTipLab)
        getFreeBtn.addSubview(freeTitleLab)
        getFreeBtn.addSubview(freeDescLab)
    }
    
    private func createUILimit() {
        headImgView.snp.makeConstraints { make in
            make.leading.equalTo(16)
            make.top.equalTo(UIScreen.statusBarHeight + 16)
            make.width.height.equalTo(40)
        }
        nickLab.snp.makeConstraints { make in
            make.centerY.equalTo(headImgView)
            make.leading.equalTo(headImgView.snp.trailing).offset(8)
            make.trailing.equalTo(editBtn.snp.leading).offset(-8)
        }
        editBtn.snp.makeConstraints { make in
            make.centerY.equalTo(headImgView)
            make.trailing.equalTo(settingBtn.snp.leading).offset(-8)
            make.size.equalTo(CGSize(width: 104, height: 32))
        }
        settingBtn.snp.makeConstraints { make in
            make.centerY.equalTo(headImgView)
            make.trailing.equalToSuperview().offset(-16)
            make.width.height.equalTo(32)
        }
        
        freeContainerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalTo(headImgView.snp.bottom).offset(16)
            make.height.equalTo(99)
        }
        freeLab.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(12)
            make.top.equalTo(12)
            make.height.equalTo(15)
        }
        
        getFreeBtn.snp.makeConstraints { make in
            make.top.equalTo(freeLab.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(12)
            make.bottom.equalTo(-11)
        }
        vipTipLab.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(2)
        }
        freeTitleLab.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(12)
            make.top.equalTo(16)
        }
        freeDescLab.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(12)
            make.top.equalTo(freeTitleLab.snp.bottom).offset(4)
        }
    }
    
    private func addEvent() {
        editBtn.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.userHomeViewHandle?(1)
        }).disposed(by: bag)
        
        settingBtn.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.userHomeViewHandle?(2)
        }).disposed(by: bag)
        
        getFreeBtn.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.userHomeViewHandle?(3)
        }).disposed(by: bag)
    }
}
