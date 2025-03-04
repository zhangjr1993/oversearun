//
//  CreateMainListCell.swift
//  AIRun
//
//  Created by Bolo on 2025/2/7.
//

import UIKit

class CreateMainListCell: UITableViewCell {

    var clickCellMoreHandle: ((Int, CGPoint) -> Void)?
    private let bag: DisposeBag = DisposeBag()
    private var mid = 0
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.createUI()
        self.createUILimit()
        self.addEvent()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var containerView = UIView().then {
        $0.layer.cornerRadius = 8
        $0.backgroundColor = UIColor.init(hexStr: "#282828")
    }
    
    private lazy var headImgView = UIImageView().then {
        $0.layer.cornerRadius = 30
        $0.layer.masksToBounds = true
    }
    
    private lazy var sexImgView = UIImageView().then {
        _ in
    }
    
    private lazy var reviewImgView = UIImageView().then {
        $0.isHidden = true
        $0.image = UIImage.imgNamed(name: "icon_create_reviewing")
    }
    
    lazy var moreBtn = UIButton().then {
        $0.setImage(UIImage.imgNamed(name: "btn_create_more"), for: .normal)
    }
    
    private lazy var nickLab = UILabel().then {
        $0.font = .regularFont(size: 16)
        $0.textColor = UIColor.white
    }
    
    private lazy var profileLab = UILabel().then {
        $0.numberOfLines = 2
        $0.font = .regularFont(size: 15)
        $0.textColor = UIColor.whiteColor(alpha: 0.6)
    }
    
    private lazy var tagsView = HomeCommonTagsView().then {
        $0.clipsToBounds = true
        $0.backgroundColor = .clear
    }
}

extension CreateMainListCell {
    func loadCellData(_ model: CreateMainListModel) {
        self.mid = model.mid
        nickLab.text = model.nickname
        headImgView.loadNetImage(url: model.headPic, cropType: .equalProportion)
        sexImgView.image = sexImgName(sex: model.sex)
        reviewImgView.isHidden = !model.isAudit
        tagsView.configure(tags: model.tags, type: .diyList)
        profileLab.attributedText = model.profile.convertToRichText(font: .regularFont(size: 15), color: .whiteColor(alpha: 0.6))
    }
      
    private func sexImgName(sex: UserSexType) -> UIImage {
        switch sex {
        case .boy:
            return UIImage.imgNamed(name: "icon_create_male")
        case .girl:
            return UIImage.imgNamed(name: "icon_create_female")
        case .quadratic:
            return UIImage.imgNamed(name: "icon_create_non")
        default:
            return UIImage()
        }
    }
}

extension CreateMainListCell {
    private func createUI() {
        self.selectionStyle = .none
        self.backgroundColor = .clear
        
        contentView.addSubview(containerView)
        containerView.addSubview(headImgView)
        containerView.addSubview(reviewImgView)
        containerView.addSubview(nickLab)
        containerView.addSubview(sexImgView)
        containerView.addSubview(tagsView)
        containerView.addSubview(moreBtn)
        containerView.addSubview(profileLab)
    }
    
    private func createUILimit() {
        containerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalToSuperview()
            make.bottom.equalTo(-12)
        }
        headImgView.snp.makeConstraints { make in
            make.leading.top.equalToSuperview().inset(12)
            make.width.height.equalTo(60)
        }
        reviewImgView.snp.makeConstraints { make in
            make.centerX.equalTo(headImgView.snp.centerX)
            make.top.equalTo(headImgView.snp.top).offset(49)
            make.size.equalTo(CGSize(width: 64, height: 18))
        }
        
        nickLab.snp.makeConstraints { make in
            make.leading.equalTo(headImgView.snp.trailing).offset(10)
            make.width.lessThanOrEqualTo(UIScreen.screenWidth-172)
            make.top.equalTo(headImgView)
        }
        sexImgView.snp.makeConstraints { make in
            make.leading.equalTo(nickLab.snp.trailing).offset(4)
            make.centerY.equalTo(nickLab)
            make.width.height.equalTo(16)
        }
        moreBtn.snp.makeConstraints { make in
            make.trailing.top.equalToSuperview().inset(12)
            make.width.height.equalTo(20)
        }
        
        tagsView.snp.makeConstraints { make in
            make.leading.equalTo(nickLab.snp.leading)
            make.trailing.equalToSuperview().offset(-36)
            make.top.equalTo(nickLab.snp.bottom).offset(8)
            make.height.equalTo(36)
        }
        profileLab.snp.makeConstraints { make in
            make.leading.equalTo(headImgView)
            make.trailing.equalTo(moreBtn)
            make.top.equalTo(headImgView.snp.bottom).offset(8)
            make.bottom.equalTo(-12)
        }
    }
    
    private func addEvent() {
        moreBtn.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            let point = self.moreBtn.convert(CGPoint.zero, toViewOrWindow: UIApplication.key)
            self.clickCellMoreHandle?(self.mid, point)
        }).disposed(by: bag)
    }
}
