//
//  MineUserEditPopView.swift
//  AIRun
//
//  Created by Bolo on 2025/2/7.
//

import UIKit

class MineUserEditPopView: BasePopView {
    
    private let bag: DisposeBag = DisposeBag()
    private var genderTag = 0
    private var imgData: Data?
    /// 修改过
    private var isModify = false
    
    override init() {
        super.init()
        self.createUI()
        self.configData()
        self.createUILimit()
        self.addEvent()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var ttLab = UILabel().then {
        $0.text = "Edit Profile"
        $0.font = .blackFont(size: 18)
        $0.textColor = .white
    }
    
    private lazy var nickLab = UILabel().then {
        $0.text = "User Name"
        $0.font = .regularFont(size: 16)
        $0.textColor = .white
    }
    
    private var nickWarningLab = UILabel().then {
        $0.isHidden = true
        $0.font = .regularFont(size: 14)
        $0.textAlignment = .right
        $0.textColor = UIColor.appPinkColor()
    }
    
    private lazy var genderLab = UILabel().then {
        $0.text = "Gender"
        $0.font = .regularFont(size: 16)
        $0.textColor = .white
    }
    
    private lazy var avatarLab = UILabel().then {
        $0.text = "Avatar"
        $0.font = .regularFont(size: 16)
        $0.textColor = .white
    }
    
    private lazy var closeBtn = UIButton().then {
        $0.setImage(UIImage.imgNamed(name: "btn_windows_close"), for: .normal)
    }
    
    private lazy var nickTFView = BaseContainerTextfield().then {
        $0.placeholder = "Write down your name"
        $0.isCleanMode = true
        $0.textfield.returnKeyType = .done
        $0.maxLimit = 30
        $0.backgroundColor = UIColor.whiteColor(alpha: 0.05)
    }

    private lazy var maleBtn = LayoutButton().then {
        $0.midSpacing = 5
        $0.tag = 1
        $0.titleLabel?.font = .regularFont(size: 15)
        let img = UIImage.createButtonImage(type: .lightGray, size: CGSize(width: 73, height: 39), isCorner: 8)
        let img2 = UIImage.createButtonImage(type: .normal, size: CGSize(width: 73, height: 39), isCorner: 8)
        $0.setImage(UIImage.imgNamed(name: "btn_create_unchecked"), for: .normal)
        $0.setImage(UIImage.imgNamed(name: "btn_create_checked"), for: .selected)
        $0.setBackgroundImage(img, for: .normal)
        $0.setBackgroundImage(img2, for: .selected)
        $0.setTitleColor(UIColor.whiteColor(alpha: 0.87), for: .normal)
        $0.setTitleColor(UIColor.appBrownColor(), for: .selected)
        $0.setTitle("Male", for: .normal)
        $0.setTitle("Male", for: .selected)
    }
    
    private lazy var femaleBtn = LayoutButton().then {
        $0.midSpacing = 5
        $0.tag = 2
        $0.titleLabel?.font = .regularFont(size: 15)
        let img = UIImage.createButtonImage(type: .lightGray, size: CGSize(width: 90, height: 39), isCorner: 8)
        let img2 = UIImage.createButtonImage(type: .normal, size: CGSize(width: 90, height: 39), isCorner: 8)
        $0.setImage(UIImage.imgNamed(name: "btn_create_unchecked"), for: .normal)
        $0.setImage(UIImage.imgNamed(name: "btn_create_checked"), for: .selected)
        $0.setBackgroundImage(img, for: .normal)
        $0.setBackgroundImage(img2, for: .selected)
        $0.setTitleColor(UIColor.whiteColor(alpha: 0.87), for: .normal)
        $0.setTitleColor(UIColor.appBrownColor(), for: .selected)
        $0.setTitle("Female", for: .normal)
        $0.setTitle("Female", for: .selected)
    }
    
    private lazy var nonBtn = LayoutButton().then {
        $0.midSpacing = 5
        $0.tag = 3
        $0.titleLabel?.font = .regularFont(size: 15)
        let img = UIImage.createButtonImage(type: .lightGray, size: CGSize(width: 119, height: 39), isCorner: 8)
        let img2 = UIImage.createButtonImage(type: .normal, size: CGSize(width: 119, height: 39), isCorner: 8)
        $0.setImage(UIImage.imgNamed(name: "btn_create_unchecked"), for: .normal)
        $0.setImage(UIImage.imgNamed(name: "btn_create_checked"), for: .selected)
        $0.setBackgroundImage(img, for: .normal)
        $0.setBackgroundImage(img2, for: .selected)
        $0.setTitleColor(UIColor.whiteColor(alpha: 0.87), for: .normal)
        $0.setTitleColor(UIColor.appBrownColor(), for: .selected)
        $0.setTitle("Non-binary", for: .normal)
        $0.setTitle("Non-binary", for: .selected)
    }
    
    private lazy var addBtn = UIButton().then {
        $0.setImage(UIImage.imgNamed(name: "btn_create_add_pictures"), for: .normal)
        $0.backgroundColor = UIColor.whiteColor(alpha: 0.05)
        $0.layer.cornerRadius = 8
    }
    
    private lazy var headerImg = UIImageView().then {
        $0.isUserInteractionEnabled = true
        $0.layer.cornerRadius = 8
        $0.layer.masksToBounds = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(changeAvatar))
        $0.addGestureRecognizer(tap)
    }
    
    private lazy var iconImg = UIImageView().then {
        $0.image = UIImage.imgNamed(name: "btn_create_avatar_edit")
    }
    
    private lazy var maskImg = UIImageView().then {
        $0.image = UIImage.imgNamed(name: "bg_diy_shadow")
    }
    
    private lazy var saveBtn = UIButton().then {
        let img = UIImage.createButtonImage(type: .lightGray, size: CGSize(width: UIScreen.screenWidth-96, height: 48), isCorner: 24)
        let img2 = UIImage.createButtonImage(type: .normal, size: CGSize(width: UIScreen.screenWidth-96, height: 48), isCorner: 24)
        $0.setBackgroundImage(img2, for: .normal)
        $0.setBackgroundImage(img, for: .disabled)
        $0.setTitle("Save", for: .normal)
        $0.setTitle("Save", for: .disabled)
        $0.setTitleColor(UIColor.appBrownColor(), for: .normal)
        $0.setTitleColor(UIColor.whiteColor(alpha: 0.6), for: .disabled)
        $0.isEnabled = false
        $0.clickDurationTime = 1.5
    }

}

extension MineUserEditPopView {
    private func createUI() {
        self.enableTouchHide = false
        self.layer.cornerRadius = 16
        self.layer.masksToBounds = true
        self.addGradientLayer(colors: UIColor.popupBgColors(), frame: CGRect(origin: .zero, size: CGSize(width: UIScreen.screenWidth-48, height: 465)), startPoint: .zero, endPoint: .init(x: 0, y: 1))
        
        self.addSubview(ttLab)
        self.addSubview(closeBtn)
        
        self.addSubview(nickLab)
        self.addSubview(nickWarningLab)
        self.addSubview(nickTFView)
        
        self.addSubview(genderLab)
        self.addSubview(maleBtn)
        self.addSubview(femaleBtn)
        self.addSubview(nonBtn)
        
        self.addSubview(avatarLab)
        self.addSubview(addBtn)
        self.addSubview(headerImg)
        headerImg.addSubview(maskImg)
        headerImg.addSubview(iconImg)
        
        self.addSubview(saveBtn)
    }
    
    private func configData() {
        let user = APPManager.default.loginUserModel?.user
        nickTFView.content = user?.nickname ?? ""
        genderTag = user?.sex.rawValue ?? 0
        self.clickGender(tag: genderTag)

        if (user?.headPic ?? "").isValidStr {
            addBtn.isHidden = true
            headerImg.isHidden = false
            headerImg.loadNetImage(url: user?.headPic ?? "", cropType: .equalProportion)
        }else {
            addBtn.isHidden = false
            headerImg.isHidden = true
        }
    }
    
    private func updateContentHeight() {
        self.snp.updateConstraints { make in
            make.size.height.equalTo(CGSize(width: UIScreen.screenWidth-48, height: 461))
        }
    }
    
    private func createUILimit() {
        let height = (APPManager.default.loginUserModel?.user?.headPic ?? "").isValidStr ? 465.0 : 400.0
        self.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: UIScreen.screenWidth-48, height: height))
        }
        ttLab.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(24)
        }
        closeBtn.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalTo(ttLab)
            make.width.height.equalTo(24)
        }
        
        nickLab.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalTo(ttLab.snp.bottom).offset(24)
        }
        nickWarningLab.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalTo(nickLab)
        }
        nickTFView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalTo(nickLab.snp.bottom).offset(8)
            make.height.equalTo(47)
        }
        
        genderLab.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalTo(nickTFView.snp.bottom).offset(16)
        }
        maleBtn.snp.makeConstraints { make in
            make.leading.equalTo(nickLab.snp.leading)
            make.top.equalTo(genderLab.snp.bottom).offset(8)
            make.size.equalTo(CGSize(width: UIScreen.adaptWidth(73), height: 39))
        }
        femaleBtn.snp.makeConstraints { make in
            make.leading.equalTo(maleBtn.snp.trailing).offset(UIScreen.adaptWidth(6))
            make.centerY.equalTo(maleBtn)
            make.size.equalTo(CGSize(width: UIScreen.adaptWidth(90), height: 39))
        }
        nonBtn.snp.makeConstraints { make in
            make.trailing.equalTo(nickLab.snp.trailing)
            make.centerY.equalTo(maleBtn)
            make.size.equalTo(CGSize(width: UIScreen.adaptWidth(119), height: 39))
        }
        
        avatarLab.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalTo(maleBtn.snp.bottom).offset(16)
        }
        addBtn.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.top.equalTo(avatarLab.snp.bottom).offset(8)
            make.size.equalTo(CGSize(width: 109, height: 47))
        }
        headerImg.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.top.equalTo(avatarLab.snp.bottom).offset(8)
            make.size.equalTo(CGSize(width: 109, height: 109))
        }
        maskImg.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(30)
        }
        iconImg.snp.makeConstraints { make in
            make.trailing.bottom.equalToSuperview().inset(6)
            make.size.equalTo(CGSize(width: 21, height: 21))
        }
        
        saveBtn.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview().inset(24)
            make.height.equalTo(48)
        }
    }
    
    private func addEvent() {
        maleBtn.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.clickGender(tag: 1)
        }).disposed(by: bag)
        femaleBtn.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.clickGender(tag: 2)
        }).disposed(by: bag)
        nonBtn.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.clickGender(tag: 3)
        }).disposed(by: bag)
        
        addBtn.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.changeAvatar()
        }).disposed(by: bag)
        
        closeBtn.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.hide()
        }).disposed(by: bag)
        
        saveBtn.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.saveRequest()
        }).disposed(by: bag)
        
        nickTFView.editDidChanged = { [weak self] text in
            guard let `self` = self else { return }
            self.isModify = true
            self.nickWarningLab.isHidden = true
            self.updateSaveBtn()
        }

    }
    
    @objc private func changeAvatar() {
        let config = AppHXPhotoConfig.avatarConfig()
        let picker = PhotoPickerController(config: config)
        picker.pickerDelegate = self
        APPPushManager.default.getCurrentActivityVC()?.present(picker, animated: true)
    }
    
    private func clickGender(tag: Int) {
        if genderTag != tag {
            self.isModify = true
        }
        
        let btns = [maleBtn, femaleBtn, nonBtn]
        btns.forEach { btn in
            btn.isSelected = tag == btn.tag
        }
        self.updateSaveBtn()
    }
    
    private func updateSaveBtn() {
        let btns = [maleBtn, femaleBtn, nonBtn]
        let btn = btns.first(where: { $0.isSelected == true })
        
        self.saveBtn.isEnabled = isModify && self.nickTFView.content.isValidStr && btn != nil && self.headerImg.isHidden == false
    }
    
    /// 保存
    private func saveRequest() {
        let btns = [maleBtn, femaleBtn, nonBtn]
        let btn = btns.first(where: { $0.isSelected == true })
        let nick = self.nickTFView.content
        let sex = btn?.tag ?? 0
                
        AppRequest(MineModuleApi.userModify(file: self.imgData, nick: nick, sex: sex.stringValue), modelType: UserEditReviewModel.self) { [weak self] result, model in
            guard let `self` = self else { return }

            if result.illegalType.count == 0 {
                self.showSuccessTipMsg(msg: "Saved successfully")
                NotificationCenter.default.post(name: .needRefreshMyInfo, object: true)
                self.hide()
            }else {
                self.reloadIllegalUI(list: result.illegalType)
            }
        }
    }
    
    private func reloadIllegalUI(list: [Int]) {
        self.nickWarningLab.isHidden = !list.contains(1)
        if list.contains(2) {
            self.imgData = nil
            self.headerImg.isHidden = true
        }
        
        self.nickWarningLab.isHidden = false
        self.addBtn.isHidden = false
        self.isModify = false
        self.saveBtn.isEnabled = false
    }
}

extension MineUserEditPopView: PhotoPickerControllerDelegate {
    func pickerController(_ pickerController: PhotoPickerController, didFinishSelection result: PickerResult) {
        pickerController.dismiss(true) {
            
            guard let asset = result.photoAssets.first, let photo = asset.originalImage else {
                return
            }
            
            AppHXPhotoConfig.compressdImage(image: photo, fileSize: 9) { [weak self] data in
                guard let `self` = self else { return }
                
                DispatchQueue.main.async {
                    self.addBtn.isHidden = true
                    self.headerImg.isHidden = false
                    self.headerImg.image = photo
                    self.imgData = photo.pngData()
                    self.updateContentHeight()
                    self.isModify = true
                    self.updateSaveBtn()
                }
            }
        }
    }
}
