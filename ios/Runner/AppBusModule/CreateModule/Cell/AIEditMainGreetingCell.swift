//
//  AIEditMainGreetingCell.swift
//  AIRun
//
//  Created by Bolo on 2025/2/8.
//

import UIKit

class AIEditMainGreetingCell: AIEditMainCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.createUI()
        self.createUILimit()
        self.addEvent()
    }
    
    override func loadEditMailCell(type: AIEditSectionType, illegal: [Int]) {
        super.loadEditMailCell(type: type, illegal: illegal)
        textView.textView.placeholder = "e.g.(you were started by the sudden instrusion of a man into your home.) I am from the knight's guild, and i have been ordered to arrest you."
    }
    
    override func loadEditCellModel(_ model: AIEditingMainModel) {
        super.loadEditCellModel(model)
        textView.content = model.greetStr
        if let greetModel = model.greetAsset {
            addBtn.isHidden = true
            headerImg.isHidden = false
            if let image = greetModel.photoAsset?.originalImage {
                headerImg.image = image.cropMaxEdgeImage()
            }else {
                headerImg.loadNetImage(url: greetModel.url, cropType: .equalProportion)
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
    
    lazy var textView = BaseContainerTextView().then {
        $0.maxLimit = 3000
        $0.isCleanMode = true
    }
    
    private lazy var addBtn = LayoutButton().then {
        $0.midSpacing = 8
        $0.imageSize = CGSize(width: 23, height: 23)
        $0.titleLabel?.font = .regularFont(size: 15)
        $0.layer.cornerRadius = 8
        $0.setImage(UIImage.imgNamed(name: "btn_newai_upload_greet"), for: .normal)
        $0.setTitle("Add A Picture", for: .normal)
        $0.setTitleColor(UIColor.whiteColor(alpha: 0.6), for: .normal)
        $0.backgroundColor = UIColor.whiteColor(alpha: 0.05)
    }
    
    private lazy var headerImg = UIImageView().then {
        $0.isHidden = true
        $0.isUserInteractionEnabled = true
        $0.layer.cornerRadius = 8
        $0.layer.masksToBounds = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(changeGreetPic))
        $0.addGestureRecognizer(tap)
    }
    
    private lazy var deleteBtn = UIButton().then {
        $0.setImage(UIImage.imgNamed(name: "btn_create_greeting_delete"), for: .normal)
    }
    
    private lazy var maskImg = UIImageView().then {
        $0.image = UIImage.imgNamed(name: "bg_diy_shadow")
    }
    
}

extension AIEditMainGreetingCell {
    private func updateUI() {
        let btm: CGFloat = addBtn.isHidden ? -62 : 0
        addBtn.snp.updateConstraints { make in
            make.bottom.equalToSuperview().offset(btm)
        }
    }
}

extension AIEditMainGreetingCell {
    private func createUI() {
        contentView.addSubview(textView)
        contentView.addSubview(addBtn)
        contentView.addSubview(headerImg)
        headerImg.addSubview(maskImg)
        headerImg.addSubview(deleteBtn)
    }
    
    private func createUILimit() {
        textView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalTo(ttLab.snp.bottom).offset(8)
            make.height.equalTo(129)
        }
        addBtn.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.top.equalTo(textView.snp.bottom).offset(8)
            make.size.equalTo(CGSize(width: 152, height: 47))
            make.bottom.equalToSuperview()
        }
        headerImg.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.top.equalTo(addBtn.snp.top)
            make.size.equalTo(CGSize(width: 109, height: 109))
        }
        maskImg.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(30)
        }
        deleteBtn.snp.makeConstraints { make in
            make.trailing.bottom.equalToSuperview().inset(6)
            make.size.equalTo(CGSize(width: 21, height: 21))
        }
    }
    
    private func addEvent() {
        addBtn.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.changeGreetPic()
        }).disposed(by: bag)
        
        deleteBtn.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.delegate?.onChangeGreetingPic(cell: self, isDelete: true)
        }).disposed(by: bag)
        
        textView.editTextDidChanged = { [weak self] text in
            guard let `self` = self else { return }
            self.delegate?.onEditGreeting(cell: self, text: text)
        }
    }
    
    @objc private func changeGreetPic() {
        self.delegate?.onChangeGreetingPic(cell: self, isDelete: false)
    }
}
