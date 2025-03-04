//
//  MineBlockListCell.swift
//  AIRun
//
//  Created by Bolo on 2025/2/6.
//

import UIKit

class MineBlockListCell: UITableViewCell {

    var clickBlockActionHandle: ((Int) -> Void)?
    private var id = 0
    private let bag: DisposeBag = DisposeBag()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.createUI()
        self.createUILimit()
        self.addEvent()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var headerImgView = UIImageView().then {
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 24
    }
    
    private lazy var nickLab = UILabel().then {
        $0.textColor = .white
        $0.font = .boldSystemFont(ofSize: 16)
    }
    
    private lazy var blockBtn = UIButton().then {
        $0.setTitle("Unblock", for: .normal)
        $0.setTitleColor(UIColor.whiteColor(alpha: 0.6), for: .normal)
        $0.titleLabel?.font = .mediumFont(size: 15)
        $0.layer.cornerRadius = 8
        $0.layer.masksToBounds = true
        $0.backgroundColor = .whiteColor(alpha: 0.05)
    }
}

extension MineBlockListCell {
    func loadDataModel(_ model: MineBlockListModel) {
        self.id = model.id
        headerImgView.loadNetImage(url: model.headPic, cropType: .equalProportion)
        nickLab.text = model.nickname
    }
}

extension MineBlockListCell {
    private func createUI() {
        self.selectionStyle = .none
        self.backgroundColor = .clear
        contentView.addSubview(headerImgView)
        contentView.addSubview(nickLab)
        contentView.addSubview(blockBtn)
    }
    
    private func createUILimit() {
        headerImgView.snp.makeConstraints { make in
            make.leading.equalTo(16)
            make.top.bottom.equalToSuperview().inset(12)
            make.width.height.equalTo(48)
        }
        nickLab.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(headerImgView.snp.trailing).offset(12)
            make.trailing.equalTo(blockBtn.snp.leading).offset(-12)
        }
        blockBtn.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-16)
            make.size.equalTo(CGSize(width: 92, height: 34))
        }
    }
    
    private func addEvent() {
        blockBtn.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            /// 取消拉黑后移除单元格
            self.clickBlockActionHandle?(self.id)
        }).disposed(by: bag)
    }
}
