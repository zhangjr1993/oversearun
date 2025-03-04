//
//  CreatorHomeInfoView.swift
//  AIRun
//
//  Created by Bolo on 2025/2/6.
//

import UIKit

class CreatorHomeInfoView: UIView {
    
    var blockUserHandle: (() -> Void)?
    var uid = 0
    var isBlock = false
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
    
    private lazy var ttLab = UILabel().then {
        $0.text = "Characters"
        $0.font = .blackFont(size: 18)
        $0.textColor = UIColor.white
    }
    
    private lazy var moreBtn = UIButton().then {
        $0.setImage(UIImage.imgNamed(name: "btn_aihome_more"), for: .normal)
    }
}

extension CreatorHomeInfoView {
    func loadDataModel(_ model: CreatorHomeMainModel) {
        self.isBlock = model.isBlock
        self.headImgView.loadNetImage(url: model.headPic, cropType: .equalProportion)
        self.nickLab.text = model.nickname
    }
}

extension CreatorHomeInfoView {
    private func createUI() {
        self.addSubview(headImgView)
        self.addSubview(nickLab)
        self.addSubview(moreBtn)
        self.addSubview(ttLab)
    }
    
    private func createUILimit() {
        headImgView.snp.makeConstraints { make in
            make.top.leading.equalTo(16)
            make.width.height.equalTo(40)
        }
        nickLab.snp.makeConstraints { make in
            make.centerY.equalTo(headImgView)
            make.leading.equalTo(headImgView.snp.trailing).offset(8)
            make.trailing.equalTo(-46)
        }
        moreBtn.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalTo(headImgView)
            make.width.height.equalTo(22)
        }
        ttLab.snp.makeConstraints { make in
            make.leading.equalTo(16)
            make.top.equalTo(headImgView.snp.bottom).offset(26)
        }
    }
    
    private func addEvent() {
        moreBtn.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.showMorePopView()
        }).disposed(by: bag)
    }
    
    private func showMorePopView() {
        let point = self.moreBtn.convert(CGPoint.zero, toViewOrWindow: UIApplication.key)

        let pop = AIHomeMorePopView(show: point, isBlock: isBlock)
        pop.show()
        pop.morePopHandle = { [weak self] index, black in
            guard let `self` = self else { return }
            if index == 1 {
                self.showReportPopView()
            }else {
                self.showBlockPopView(isBlack: black)
            }
        }
    }
    
    private func showReportPopView() {
        guard APPManager.default.isHasLogin() else { return }

        let pop = HomeReportPopView(type: .creator, rid: self.uid)
        pop.show()
    }
    
    private func showBlockPopView(isBlack: Bool) {
        guard APPManager.default.isHasLogin() else { return }
        
        if isBlack {
            self.clickBlockAction(isBlack: isBlack)
            return
        }
        
        var config = AlertConfig()
        config.content = "After blocking, you will not be able to see the AI ​​characters created by this user. Are you sure you want to block?"
        config.confirmTitle = isBlack ? "Unblock" : "Block"
        let pop = BaseAlertView(config: config) { [weak self] actionIndex in
            guard let `self` = self else { return }
            if actionIndex == 2 {
                self.clickBlockAction(isBlack: isBlack)
            }
        }
        pop.show()
    }
    
    private func clickBlockAction(isBlack: Bool) {
       
        APPManager.default.userBlockedReq(uid: self.uid, isBlock: !isBlack) { [weak self] result in
            guard let `self` = self else { return }
            if result {
                self.blockUserHandle?()
            }
        }
    }
}
