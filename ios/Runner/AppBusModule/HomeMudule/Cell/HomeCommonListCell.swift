//
//  HomeCommonListCell.swift
//  AIRun
//
//  Created by Bolo on 2025/1/21.
//

import UIKit

class HomeCommonListCell: UICollectionViewCell {
    
    private let bag: DisposeBag = DisposeBag()
    private var mid = 0
    private var gallery: [String] = []
    private var tab = 0
   
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.createUI()
        self.createUILimit()
        self.addEvent()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var containerView = UIView().then {
        $0.layer.cornerRadius = 8
        $0.backgroundColor = UIColor.init(hexStr: "#242325")
    }
    
    private lazy var bannerView = JXBanner().then {
        $0.delegate = self
        $0.dataSource = self
        $0.backgroundColor = .clear
        $0.isHidden = true
        $0.isUserInteractionEnabled = false
        $0.layer.cornerRadius = 8
        $0.layer.masksToBounds = true
    }
    
    private lazy var headImgView = UIImageView().then {
        $0.layer.cornerRadius = 8
        $0.layer.masksToBounds = true
    }
    
    private lazy var filterImgView = UIImageView().then {
        $0.image = UIImage.imgNamed(name: "icon_home_unfiltered")
    }

    private lazy var chatImgView = UIImageView().then {
        $0.image = UIImage.imgNamed(name: "icon_home_chat")
    }
    
    private lazy var maskImgView = UIImageView().then {
        $0.image = UIImage.imgNamed(name: "bg_diy_shadow")
    }
    
    private lazy var attenBtn = UIButton().then {
        $0.setImage(UIImage.imgNamed(name: "btn_home_like"), for: .normal)
        $0.setImage(UIImage.imgNamed(name: "btn_home_liked"), for: .selected)
        $0.clickDurationTime = 1.5
    }
    
    private lazy var chatNumLab = UILabel().then {
        $0.font = .regularFont(size: 14)
        $0.textColor = UIColor.whiteColor(alpha: 0.87)
    }
    
    private lazy var nickLab = UILabel().then {
        $0.font = .regularFont(size: 16)
        $0.textColor = UIColor.white
    }
    
    private lazy var profileLab = UILabel().then {
        $0.font = .regularFont(size: 13)
        $0.textColor = UIColor.whiteColor(alpha: 0.6)
    }
    
    private lazy var tagsView = HomeCommonTagsView().then {
        $0.clipsToBounds = true
        $0.backgroundColor = .clear
    }
    
}

extension HomeCommonListCell {
    func showDataModel(_ model: HomeCommonListModel, isFollow: Bool, tabId: Int) {
        self.mid = model.mid
        self.tab = tabId
        
        filterImgView.isHidden = model.isFilter == 1
        attenBtn.isSelected = model.isAttention
        attenBtn.isHidden = isFollow
        headImgView.loadNetImage(url: model.headPic, cropType: .equalProportion)
        bannerView.isHidden = model.gallery.count == 0
        if model.gallery.count > 0 {
            self.gallery.removeAll()
            self.gallery.append(model.headPic)
            self.gallery.append(contentsOf: model.gallery)

            bannerView.reloadView()
        }
        
        chatNumLab.text = model.msgNum
        nickLab.text = model.nickname
        profileLab.text = model.profile
        tagsView.configure(tags: model.tags, type: .homelist)
    }
}

extension HomeCommonListCell {
    private func createUI() {
        contentView.backgroundColor = UIColor.clear
        contentView.addSubview(containerView)
        containerView.addSubview(headImgView)
        containerView.addSubview(bannerView)
        containerView.addSubview(filterImgView)
        containerView.addSubview(attenBtn)
        containerView.addSubview(maskImgView)
        containerView.addSubview(chatImgView)
        containerView.addSubview(chatNumLab)
        containerView.addSubview(nickLab)
        containerView.addSubview(profileLab)
        containerView.addSubview(tagsView)
    }
    
    private func createUILimit() {
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        headImgView.snp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview()
            make.height.equalTo(UIScreen.homeListHeaderWidth)
        }
        bannerView.snp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview()
            make.height.equalTo(UIScreen.homeListHeaderWidth)
        }
        filterImgView.snp.makeConstraints { make in
            make.leading.top.equalTo(6)
            make.size.equalTo(CGSize(width: 67, height: 21))
        }
        attenBtn.snp.makeConstraints { make in
            make.trailing.equalTo(-6)
            make.top.equalTo(4)
            make.width.height.equalTo(24)
        }
        
        maskImgView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(headImgView.snp.bottom)
            make.height.equalTo(26)
        }
        chatImgView.snp.makeConstraints { make in
            make.trailing.equalTo(chatNumLab.snp.leading).offset(-2)
            make.width.height.equalTo(16)
            make.bottom.equalTo(headImgView.snp.bottom).offset(-5)
        }
        chatNumLab.snp.makeConstraints { make in
            make.trailing.equalTo(-6)
            make.bottom.equalTo(headImgView.snp.bottom).offset(-4)
        }
        
        nickLab.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(8)
            make.top.equalTo(headImgView.snp.bottom).offset(8)
            make.height.equalTo(16)
        }
        profileLab.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(8)
            make.top.equalTo(nickLab.snp.bottom).offset(6)
            make.height.equalTo(13)
        }
        tagsView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(8)
            make.top.equalTo(profileLab.snp.bottom).offset(8)
            make.bottom.equalTo(-8)
        }
        
        attenBtn.addBgShadow()
    }
    
    private func addEvent() {
        attenBtn.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.clickAttenAction()
        }).disposed(by: bag)
    }
    
    private func clickAttenAction() {
        APPManager.default.aiAttentionReq(mid: self.mid, isAtten: !self.attenBtn.isSelected, tabId: self.tab) { [weak self] result in
            guard let `self` = self else { return }
            if result {
                self.attenBtn.isSelected = !self.attenBtn.isSelected
            }
        }
    }
}

extension HomeCommonListCell: JXBannerDelegate, JXBannerDataSource {
    func jxBanner(_ banner: JXBannerType, params: JXBannerParams) -> JXBannerParams {
        return params
            .isAutoPlay(true)
            .timeInterval(3)
            .isShowPageControl(false).cycleWay(.forward)
    }
    
    func jxBanner(numberOfItems banner: JXBannerType) -> Int {
        return self.gallery.count
    }
    
    func jxBanner(_ banner: JXBannerType) -> (JXBannerCellRegister) {
        return JXBannerCellRegister(type: JXBannerBaseCell.self, reuseIdentifier: "JXBannerBaseCell")
    }
    
    func jxBanner(_ banner: JXBannerType, cellForItemAt index: Int, cell: UICollectionViewCell) -> UICollectionViewCell {
        let tempCell = cell as! JXBannerBaseCell
        tempCell.imageView.contentMode = .scaleAspectFill
        let urlStr = self.gallery[index]
        tempCell.imageView.loadNetImage(url: urlStr, cropType: .equalProportion)
        return tempCell
    }
    
    func jxBanner(_ banner: JXBannerType, didSelectItemAt index: Int) {

    }
    
}
