//
//  AIEditMainAvatarCell.swift
//  AIRun
//
//  Created by Bolo on 2025/2/8.
//

import UIKit

class AIEditMainAvatarCell: AIEditMainCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.createUI()
        self.createUILimit()
        self.addEvent()
    }
    
    override func loadEditCellModel(_ model: AIEditingMainModel) {
        super.loadEditCellModel(model)
        if let avatarModel = model.avatarAsset {
            addBtn.isHidden = true
            headerImg.isHidden = false
            if let image = avatarModel.photoAsset?.originalImage {
                headerImg.image = image
            }else {
                headerImg.loadNetImage(url: avatarModel.url, cropType: .equalProportion)
            }
        }else {
            addBtn.isHidden = false
            headerImg.isHidden = true
        }
        
        addBtn.snp.updateConstraints { make in
            make.height.equalTo(self.addBtn.isHidden ? 109 : 47)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var addBtn = UIButton().then {
        $0.setImage(UIImage.imgNamed(name: "btn_create_add_pictures"), for: .normal)
        $0.backgroundColor = UIColor.whiteColor(alpha: 0.05)
        $0.layer.cornerRadius = 8
    }
    
    private lazy var headerImg = UIImageView().then {
        $0.isHidden = true
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
}

extension AIEditMainAvatarCell {
    private func updateUI() {
        let btm: CGFloat = addBtn.isHidden ? -62 : 0
        addBtn.snp.updateConstraints { make in
            make.bottom.equalToSuperview().offset(btm)
        }
    }
    
    private func createUI() {
        contentView.addSubview(addBtn)
        contentView.addSubview(headerImg)
        headerImg.addSubview(maskImg)
        headerImg.addSubview(iconImg)
    }
    
    private func createUILimit() {
        
        addBtn.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.top.equalTo(ttLab.snp.bottom).offset(8)
            make.size.equalTo(CGSize(width: 109, height: 47))
            make.bottom.equalToSuperview()
        }
        headerImg.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.top.equalTo(ttLab.snp.bottom).offset(8)
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
    }
    
    private func addEvent() {
        addBtn.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.changeAvatar()
        }).disposed(by: bag)
    }
    
    @objc private func changeAvatar() {
        self.delegate?.onChangeAvatar(cell: self)
    }
}


// MARK: - 昵称
class AIEditMainNickCell: AIEditMainCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.createUI()
        self.createUILimit()
        self.addEvent()
    }
    
    override func loadEditCellModel(_ model: AIEditingMainModel) {
        super.loadEditCellModel(model)
        nickTF.content = model.nick
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var nickTF = BaseContainerTextfield().then {
        $0.placeholder = "Name your character"
        $0.isCleanMode = true
        $0.textfield.returnKeyType = .done
        $0.maxLimit = 30
    }
}

extension AIEditMainNickCell {
    private func createUI() {
        contentView.addSubview(nickTF)
    }
    
    private func createUILimit() {
        nickTF.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalTo(ttLab.snp.bottom).offset(8)
            make.height.equalTo(47)
            make.bottom.equalToSuperview()
        }

    }
    
    private func addEvent() {
        nickTF.editDidChanged = { [weak self] text in
            guard let `self` = self else { return }
            self.delegate?.onEditNickname(cell: self, text: text)
        }
    }
}
