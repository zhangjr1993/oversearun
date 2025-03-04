//
//  AIEditMainButtonCell.swift
//  AIRun
//
//  Created by Bolo on 2025/2/8.
//

import UIKit

// gender & visibility & rating
class AIEditMainButtonCell: AIEditMainCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.createUI()
        self.createUILimit()
        self.addEvent()
    }
    
    override func loadEditCellModel(_ model: AIEditingMainModel) {
        super.loadEditCellModel(model)
        
        let indexTag: Int
        if self.type == .gender {
            indexTag = model.sex.rawValue
        }else if self.type == .visibility {
            indexTag = model.isShow
        }else {
            indexTag = model.isFilter
        }
        
        self.clickCellBtn(tag: indexTag)
    }
    
    override func loadEditMailCell(type: AIEditSectionType, illegal: [Int]) {
        super.loadEditMailCell(type: type, illegal: illegal)
        self.layoutEditCell(type: type)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var leftBtn = LayoutButton().then {
        $0.midSpacing = 4
        $0.tag = 1
        $0.titleLabel?.font = .regularFont(size: 15)
        let img = UIImage.createButtonImage(type: .lightGray, size: CGSize(width: 90, height: 39), isCorner: 8)
        let img2 = UIImage.createButtonImage(type: .normal, size: CGSize(width: 90, height: 39), isCorner: 8)
        $0.setImage(UIImage.imgNamed(name: "btn_create_unchecked"), for: .normal)
        $0.setImage(UIImage.imgNamed(name: "btn_create_checked"), for: .selected)
        $0.setBackgroundImage(img, for: .normal)
        $0.setBackgroundImage(img2, for: .selected)
        $0.setTitleColor(UIColor.whiteColor(alpha: 0.87), for: .normal)
        $0.setTitleColor(UIColor.appBrownColor(), for: .selected)
    }
    
    lazy var midBtn = LayoutButton().then {
        $0.midSpacing = 4
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
    }
    
    lazy var rightBtn = LayoutButton().then {
        $0.midSpacing = 4
        $0.tag = 3
        $0.titleLabel?.font = .regularFont(size: 15)
        let img = UIImage.createButtonImage(type: .lightGray, size: CGSize(width: 90, height: 39), isCorner: 8)
        let img2 = UIImage.createButtonImage(type: .normal, size: CGSize(width: 90, height: 39), isCorner: 8)
        $0.setImage(UIImage.imgNamed(name: "btn_create_unchecked"), for: .normal)
        $0.setImage(UIImage.imgNamed(name: "btn_create_checked"), for: .selected)
        $0.setBackgroundImage(img, for: .normal)
        $0.setBackgroundImage(img2, for: .selected)
        $0.setTitleColor(UIColor.whiteColor(alpha: 0.87), for: .normal)
        $0.setTitleColor(UIColor.appBrownColor(), for: .selected)
    }
}

extension AIEditMainButtonCell {
    
    private func clickCellBtn(tag: Int) {
        let btns = [leftBtn, midBtn, rightBtn]
        btns.forEach { btn in
            btn.isSelected = btn.tag == tag
        }
        
        if self.type == .gender {
            self.delegate?.onChangeSex(cell: self, sex: UserSexType.init(rawValue: tag) ?? .unowned)
        }else if self.type == .visibility {
            self.delegate?.onChangeOwnership(cell: self, isShow: tag)
        }else {
            self.delegate?.onChangeFilter(cell: self, isFilter: tag)
        }
        
    }
    
    private func layoutEditCell(type: AIEditSectionType) {
        let leftW: CGFloat
        let midW: CGFloat
        let rightW: CGFloat
        let subStr: [String]
        
        leftBtn.tag = 1
        midBtn.tag = 2
        rightBtn.tag = 3
        rightBtn.isHidden = true
        if type == .gender {
            subStr = ["Male", "Female", "Non-binary"]
            leftW = UIScreen.adaptWidth(85)
            midW = UIScreen.adaptWidth(102)
            rightW = UIScreen.adaptWidth(131)
            rightBtn.isHidden = false
        }else if type == .visibility {
            leftBtn.tag = 2
            midBtn.tag = 1
            subStr = ["Public", "Private", ""]
            leftW = UIScreen.adaptWidth(95)
            midW = UIScreen.adaptWidth(100)
            rightW = 0
        }else {
            subStr = ["Filtered", "Unfiltered", ""]
            leftW = UIScreen.adaptWidth(105)
            midW = UIScreen.adaptWidth(121)
            rightW = 0
        }
        
        leftBtn.setTitle(subStr[0], for: .normal)
        midBtn.setTitle(subStr[1], for: .normal)
        rightBtn.setTitle(subStr[2], for: .normal)
        
        leftBtn.snp.updateConstraints { make in
            make.width.equalTo(leftW)
        }
        midBtn.snp.updateConstraints { make in
            make.width.equalTo(midW)
        }
        rightBtn.snp.updateConstraints { make in
            make.width.equalTo(rightW)
        }
    }

}

extension AIEditMainButtonCell {
    private func createUI() {
        contentView.addSubview(leftBtn)
        contentView.addSubview(midBtn)
        contentView.addSubview(rightBtn)
    }
    
    private func createUILimit() {
        leftBtn.snp.makeConstraints { make in
            make.leading.equalTo(16)
            make.top.equalTo(ttLab.snp.bottom).offset(8)
            make.height.equalTo(47)
            make.width.equalTo(85)
            make.bottom.equalToSuperview()
        }
        midBtn.snp.makeConstraints { make in
            make.leading.equalTo(leftBtn.snp.trailing).offset(UIScreen.adaptWidth(6))
            make.centerY.equalTo(leftBtn)
            make.height.equalTo(47)
            make.width.equalTo(85)
        }
        rightBtn.snp.makeConstraints { make in
            make.leading.equalTo(midBtn.snp.trailing).offset(UIScreen.adaptWidth(6))
            make.centerY.equalTo(leftBtn)
            make.height.equalTo(47)
            make.width.equalTo(85)
        }
    }
    
    private func addEvent() {
        leftBtn.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.clickCellBtn(tag: self.leftBtn.tag)
        }).disposed(by: bag)
        
        midBtn.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.clickCellBtn(tag: self.midBtn.tag)
        }).disposed(by: bag)
        
        rightBtn.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.clickCellBtn(tag: self.rightBtn.tag)
        }).disposed(by: bag)
    }
}
