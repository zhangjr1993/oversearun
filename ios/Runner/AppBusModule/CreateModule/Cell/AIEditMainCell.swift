//
//  AIEditMainCell.swift
//  AIRun
//
//  Created by Bolo on 2025/2/8.
//

import UIKit

protocol AIEditMainCellDelegate: NSObjectProtocol {
    /// 更换头像
    func onChangeAvatar(cell: AIEditMainCell?)
    /// 编辑昵称
    func onEditNickname(cell: AIEditMainCell?, text: String?)
    /// 选择性别
    func onChangeSex(cell: AIEditMainCell?, sex: UserSexType)
    /// 选择公开私有
    func onChangeOwnership(cell: AIEditMainCell?, isShow: Int)
    /// 评级过滤
    func onChangeFilter(cell: AIEditMainCell?, isFilter: Int)
    /// tags
    func onChangeSelectedTags(cell: AIEditMainCell?)
    /// intro
    func onEditIntro(cell: AIEditMainCell?, text: String?)
    /// 打招呼
    func onEditGreeting(cell: AIEditMainCell?, text: String?)
    /// 打招呼图片
    func onChangeGreetingPic(cell: AIEditMainCell?, isDelete: Bool)
    /// 9图
    func onChangeGalleryPic(cell: AIEditMainCell?, last: [AIEditingGalleryModel], isDelete: Bool)
    /// 性格背景
    func onEditPersonality(cell: AIEditMainCell?, text: String?)
}

extension AIEditMainCellDelegate {
    func onChangeAvatar(cell: AIEditMainCell?, avatar: UIImage?) {}
    func onEditNickname(cell: AIEditMainCell?, text: String?) {}
    func onChangeSex(cell: AIEditMainCell?, sex: UserSexType) {}
    func onChangeOwnership(cell: AIEditMainCell?, isShow: Int) {}
    func onChangeFilter(cell: AIEditMainCell?, isFilter: Int) {}
    func onChangeSelectedTags(cell: AIEditMainCell?) {}
    func onEditIntro(cell: AIEditMainCell?, text: String?) {}
    func onEditGreeting(cell: AIEditMainCell?, text: String?) {}
    func onChangeGreetingPic(cell: AIEditMainCell?, isDelete: Bool) {}
    func onChangeGalleryPic(cell: AIEditMainCell?, last: [AIEditingGalleryModel], isDelete: Bool) {}
    func onEditPersonality(cell: AIEditMainCell?, text: String?) {}
}

class AIEditMainCell: UITableViewCell {
    
    let bag: DisposeBag = DisposeBag()
    
    weak var delegate: AIEditMainCellDelegate?
    
    var type: AIEditSectionType = .avatar
    
    var editingModel = AIEditingMainModel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.createUI()
        self.createUILimit()
        self.addEvent()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    lazy var ttLab = UILabel().then {
        $0.font = .regularFont(size: 16)
        $0.textColor = .white
    }
    
    lazy var limitLab = UILabel().then {
        $0.isHidden = true
        $0.font = .regularFont(size: 16)
        $0.textColor = UIColor.init(hexStr: "#747474")
    }
    
    lazy var remindBtn = UIButton().then {
        $0.isHidden = true
        $0.setImage(UIImage.imgNamed(name: "btn_create_explanation"), for: .normal)
    }
    
    ///
    lazy var warningLab = UILabel().then {
        $0.isHidden = true
        $0.font = .regularFont(size: 14)
        $0.textAlignment = .right
    }
    
    /// 初始化
    func loadEditMailCell(type: AIEditSectionType, illegal: [Int]) {
        self.type = type
        self.ttLab.text = type.rawValue
        
        if (illegal.contains(2) && type == .name) || (illegal.contains(3) && type == .intro) || (illegal.contains(4) && type == .greet) {
            warningLab.text = "The content is illegal"
            warningLab.textColor = UIColor.appPinkColor()
            warningLab.isHidden = false
        }else if type == .rating {
            warningLab.text = "Cannot be modified after creation"
            warningLab.textColor = UIColor.appYellowColor()
            warningLab.isHidden = false
        }else {
            warningLab.isHidden = true
        }
        
        
        let remind: [AIEditSectionType] = [.visibility, .rating, .intro, .greet, .pic, .personal]
        remindBtn.isHidden = !remind.contains(type)
        
        let limit: [AIEditSectionType] = [.tags, .pic]
        limitLab.isHidden = !limit.contains(type)
        limitLab.text = limitLab.isHidden ? "" : type == .tags ? "(0/10)" : "(0/9)"
        
        if limitLab.isHidden {
            remindBtn.snp.remakeConstraints { make in
                make.leading.equalTo(ttLab.snp.trailing).offset(4)
                make.width.height.equalTo(16)
                make.centerY.equalTo(ttLab)
            }
        }else {
            remindBtn.snp.remakeConstraints { make in
                make.leading.equalTo(limitLab.snp.trailing).offset(4)
                make.width.height.equalTo(16)
                make.centerY.equalTo(ttLab)
            }
        }
    }
    
    /// 编辑中
    func loadEditCellModel(_ model: AIEditingMainModel) {
        self.editingModel = model
    }
}

extension AIEditMainCell {
    
}

extension AIEditMainCell {
    private func createUI() {
        self.selectionStyle = .none
        self.backgroundColor = .clear
        contentView.addSubview(ttLab)
        contentView.addSubview(limitLab)
        contentView.addSubview(remindBtn)
        contentView.addSubview(warningLab)
    }
    
    private func createUILimit() {
        ttLab.snp.makeConstraints { make in
            make.leading.top.equalTo(16)
        }
        limitLab.snp.makeConstraints { make in
            make.leading.equalTo(ttLab.snp.trailing).offset(4)
            make.centerY.equalTo(ttLab)
        }
        
        remindBtn.snp.makeConstraints { make in
            make.leading.equalTo(ttLab.snp.trailing).offset(4)
            make.width.height.equalTo(16)
            make.centerY.equalTo(ttLab)
        }
        
        warningLab.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.leading.equalTo(remindBtn.snp.trailing).offset(16).priority(.low)
            make.centerY.equalTo(ttLab)
        }
    }
   
    private func addEvent() {
        remindBtn.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            let point = self.remindBtn.convert(CGPoint.zero, toViewOrWindow: UIApplication.key)
            self.showExplainPopView(point: point)
        }).disposed(by: bag)
    }
    
    private func showExplainPopView(point: CGPoint) {
        let pop = AIEditMainExplanPopView(point: point, type: self.type)
        pop.show()
    }
}
