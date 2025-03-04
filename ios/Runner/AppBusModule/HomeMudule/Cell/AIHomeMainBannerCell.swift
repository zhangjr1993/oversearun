//
//  AIHomeMainBannerCell.swift
//  AIRun
//
//  Created by Bolo on 2025/1/23.
//

import UIKit

class AIHomeMainBannerCell: UITableViewCell {
    
    var blockAIHandle: (() -> Void)?
    var clickBannerHandle: (() -> Void)?
    private var bag: DisposeBag = DisposeBag()
    private var dataModel = AIHomeMainModel()
    private var bannerArray: [String] = []
   
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.createUI()
        self.createUILimit()
        self.addEvent()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var banner = JXBanner().then {
        $0.delegate = self
        $0.dataSource = self
        $0.backgroundColor = .clear
    }
    
    private lazy var filterImgView = UIImageView().then {
        $0.image = UIImage.imgNamed(name: "icon_home_unfiltered")
    }
    
    private lazy var nickLab = UILabel().then {
        $0.font = .blackFont(size: 26)
        $0.textColor = .white
    }
    
    private lazy var attenBtn = UIButton().then {
        $0.setImage(UIImage.imgNamed(name: "btn_home_like"), for: .normal)
        $0.setImage(UIImage.imgNamed(name: "btn_home_liked"), for: .selected)
        $0.clickDurationTime = 1.5
    }
    
    private lazy var moreBtn = UIButton().then {
        $0.setImage(UIImage.imgNamed(name: "btn_aihome_more"), for: .normal)
    }
    
    private lazy var chatImgView = UIImageView().then {
        $0.image = UIImage.imgNamed(name: "icon_aihome_chat")
    }
    
    private lazy var chatNumLab = UILabel().then {
        $0.font = .regularFont(size: 15)
        $0.textColor = UIColor.whiteColor(alpha: 0.87)
    }
    
    private lazy var attenImgView = UIImageView().then {
        $0.image = UIImage.imgNamed(name: "icon_aihome_follow")
    }
    
    private lazy var attenNumLab = UILabel().then {
        $0.font = .regularFont(size: 15)
        $0.textColor = UIColor.whiteColor(alpha: 0.87)
    }
    
    private lazy var maskImgView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.image = UIImage.imgNamed(name: "bg_shadow_aihome")
    }
    
    /// UI要求的叠两张图片
    private lazy var mask2ImgView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.image = UIImage.imgNamed(name: "bg_shadow_aihome")
    }

}


extension AIHomeMainBannerCell {
    func configer(model: AIHomeMainModel) {
        self.dataModel = model
        
        nickLab.text = model.nickname
        attenBtn.isSelected = model.isAttention
        chatNumLab.text = model.msgNum
        attenNumLab.text = model.attentionNum
        filterImgView.isHidden = model.isFilter == 1
        
        if model.headPic.isValidStr {
            bannerArray.append(model.headPic)
        }
        if model.gallery.count > 0 {
            bannerArray.append(contentsOf: model.gallery)
        }
        banner.reloadView()
    }
}

extension AIHomeMainBannerCell {
    
    private func showBlockPopView(isBlack: Bool) {
        guard APPManager.default.isHasLogin() else { return }

        var config = AlertConfig()
        config.content = "After blocking, you will not be able to see this AI character. Are you sure to block it?"
        config.confirmTitle = isBlack ? "Unblock" : "Block"
        let pop = BaseAlertView(config: config) { [weak self] actionIndex in
            guard let `self` = self else { return }
            if actionIndex == 2 {
                self.clickBlockAction(isBlack: isBlack)
            }
        }
        pop.show()
    }
    
    private func showReportPopView() {
        guard APPManager.default.isHasLogin() else { return }
        
        let pop = HomeReportPopView(type: .ai, rid: self.dataModel.mid)
        pop.show()
    }
    
    private func showMorePopView() {
        let point = self.moreBtn.convert(CGPoint.zero, toViewOrWindow: UIApplication.key)

        let pop = AIHomeMorePopView(show: point, isBlock: self.dataModel.isBlock)
        pop.show()
        pop.morePopHandle = { [weak self] index, isBlock in
            guard let `self` = self else { return }
            if index == 1 {
                self.showReportPopView()
            }else {
                self.showBlockPopView(isBlack: isBlock)
            }
        }
    }
    
}

extension AIHomeMainBannerCell {
    private func createUI() {
        self.selectionStyle = .none
        self.backgroundColor = .clear

        contentView.addSubview(banner)
        contentView.addSubview(maskImgView)
        contentView.addSubview(mask2ImgView)
        contentView.addSubview(filterImgView)
        contentView.addSubview(nickLab)
        contentView.addSubview(attenBtn)
        contentView.addSubview(moreBtn)
        contentView.addSubview(chatImgView)
        contentView.addSubview(chatNumLab)
        contentView.addSubview(attenImgView)
        contentView.addSubview(attenNumLab)
    }
    
    private func createUILimit() {
        banner.snp.makeConstraints { make in
            make.leading.top.equalToSuperview()
            make.size.equalTo(CGSize(width: UIScreen.screenWidth, height: UIScreen.screenWidth))
        }
        maskImgView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(UIScreen.adaptWidth(69))
            make.top.equalTo(banner.snp.bottom).offset(UIScreen.adaptWidth(-65))
            make.bottom.equalToSuperview()
        }
        mask2ImgView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(UIScreen.adaptWidth(69))
            make.top.equalTo(banner.snp.bottom).offset(UIScreen.adaptWidth(-65))
        }
        
        filterImgView.snp.makeConstraints { make in
            make.leading.equalTo(16)
            make.bottom.equalTo(maskImgView.snp.top).offset(2)
            make.size.equalTo(CGSize(width: 67, height: 21))
        }
        nickLab.snp.makeConstraints { make in
            make.leading.equalTo(filterImgView.snp.leading)
            make.trailing.equalTo(attenBtn.snp.leading).offset(-8)
            make.top.equalTo(filterImgView.snp.bottom).offset(4)
        }
        attenBtn.snp.makeConstraints { make in
            make.centerY.equalTo(nickLab.snp.centerY)
            make.trailing.equalTo(moreBtn.snp.leading).offset(-26)
            make.width.height.equalTo(UIScreen.adaptWidth(22))
        }
        moreBtn.snp.makeConstraints { make in
            make.centerY.equalTo(nickLab.snp.centerY)
            make.trailing.equalTo(-16)
            make.width.height.equalTo(UIScreen.adaptWidth(22))
        }
        
        chatImgView.snp.makeConstraints { make in
            make.leading.equalTo(16)
            make.top.equalTo(nickLab.snp.bottom).offset(13)
            make.width.height.equalTo(UIScreen.adaptWidth(18))
        }
        chatNumLab.snp.makeConstraints { make in
            make.leading.equalTo(chatImgView.snp.trailing).offset(5)
            make.centerY.equalTo(chatImgView)
        }
        
        attenImgView.snp.makeConstraints { make in
            make.leading.equalTo(chatNumLab.snp.trailing).offset(16)
            make.centerY.equalTo(chatImgView)
            make.width.height.equalTo(UIScreen.adaptWidth(18))
        }
        attenNumLab.snp.makeConstraints { make in
            make.centerY.equalTo(chatImgView)
            make.leading.equalTo(attenImgView.snp.trailing).offset(5)
        }
    }
    
    private func addEvent() {
        attenBtn.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.clickAttenAction()
        }).disposed(by: bag)
        
        moreBtn.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.showMorePopView()
        }).disposed(by: bag)
    }
    
    private func clickAttenAction() {
        APPManager.default.aiAttentionReq(mid: self.dataModel.mid, isAtten: !self.attenBtn.isSelected, tabId: 10001) { [weak self] result in
            guard let `self` = self else { return }
            if result {
                self.attenBtn.isSelected = !self.attenBtn.isSelected
            }
        }
    }
    
    private func clickBlockAction(isBlack: Bool) {
        APPManager.default.aiBlockedReq(mid: self.dataModel.mid, isBlock: !isBlack) { [weak self] result in
            guard let `self` = self else { return }
            self.blockAIHandle?()
        }
    }
    
}

extension AIHomeMainBannerCell: JXBannerDelegate, JXBannerDataSource {
    func jxBanner(_ banner: JXBannerType, params: JXBannerParams) -> JXBannerParams {
        return params
            .isAutoPlay(true)
            .timeInterval(5)
            .isShowPageControl(false).cycleWay(.forward)
    }
    
    func jxBanner(numberOfItems banner: JXBannerType) -> Int {
        return self.bannerArray.count
    }
    
    func jxBanner(_ banner: JXBannerType) -> (JXBannerCellRegister) {
        return JXBannerCellRegister(type: JXBannerBaseCell.self, reuseIdentifier: "JXBannerBaseCell")
    }
    
    func jxBanner(_ banner: JXBannerType, cellForItemAt index: Int, cell: UICollectionViewCell) -> UICollectionViewCell {
        let tempCell = cell as! JXBannerBaseCell
        tempCell.imageView.contentMode = .scaleAspectFill
        let urlStr = self.bannerArray[index]
        tempCell.imageView.loadNetImage(url: urlStr, cropType: .equalProportion)
        return tempCell
    }
    
    func jxBanner(_ banner: JXBannerType, didSelectItemAt index: Int) {
        self.clickBannerHandle?()
    }
    
}
