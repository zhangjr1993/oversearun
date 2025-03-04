//
//  CreateUploadTipPopView.swift
//  AIRun
//
//  Created by Bolo on 2025/2/7.
//

import UIKit

class CreateUploadTipPopView: BasePopView {

    var uploadFileHandle: (() -> Void)?
    private let bag: DisposeBag = DisposeBag()
    
    override init() {
        super.init()
        self.createUI()
        self.createUILimit()
        self.addEvent()
    }
    
    @MainActor required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var containerView = UIView().then {
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 16
    }
    
    private lazy var ttLab = UILabel().then {
        $0.text = "Upload"
        $0.font = .blackFont(size: 18)
        $0.textColor = .white
    }
    
    private lazy var closeBtn = UIButton().then {
        $0.setImage(UIImage.imgNamed(name: "btn_windows_close"), for: .normal)
    }
    
    private lazy var addBackBtn = UIButton().then {
        $0.layer.cornerRadius = 8
        $0.backgroundColor = .whiteColor(alpha: 0.05)
    }
    
    private lazy var addBtn = UIButton().then {
        $0.setImage(UIImage.imgNamed(name: "btn_newai_upload_pic"), for: .normal)
        $0.layer.cornerRadius = 30
        $0.backgroundColor = UIColor.whiteColor(alpha: 0.1)
    }
  
    private lazy var addLab = UILabel().then {
        $0.text = "Choose a json or character card image file to upload"
        $0.numberOfLines = 0
        $0.textAlignment = .center
        $0.font = .regularFont(size: 16)
        $0.textColor = .whiteColor(alpha: 0.6)
    }
    
    private lazy var tipLab = UILabel().then {
        $0.text = "Characters from various platforms like Characterai, Pygmalion, Zoltanal, Text Generation, Tavemai, Chub an others are supported for import."
        $0.numberOfLines = 0
        $0.textAlignment = .center
        $0.font = .regularFont(size: 13)
        $0.textColor = .whiteColor(alpha: 0.38)
    }
    
}

extension CreateUploadTipPopView {
    private func createUI() {
        self.addSubview(containerView)
        containerView.addSubview(ttLab)
        containerView.addSubview(closeBtn)
        
        containerView.addSubview(addBackBtn)
        addBackBtn.addSubview(addBtn)
        addBackBtn.addSubview(addLab)
        
        containerView.addSubview(tipLab)
    }
    
    private func createUILimit() {
        self.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: UIScreen.screenWidth-48, height: 306))
        }
        
        containerView.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.width.equalTo(UIScreen.screenWidth-48)
            make.height.greaterThanOrEqualTo(0)
        }
        ttLab.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(32)
        }
        closeBtn.snp.makeConstraints { make in
            make.trailing.equalTo(-16)
            make.centerY.equalTo(ttLab)
            make.width.height.equalTo(24)
        }
        
        addBackBtn.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalTo(ttLab.snp.bottom).offset(16)
            make.height.equalTo(136)
        }
        addBtn.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(16)
            make.width.height.equalTo(60)
        }
        addLab.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(22)
            make.top.equalTo(addBtn.snp.bottom).offset(12)
        }
        
        tipLab.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalTo(addBackBtn.snp.bottom).offset(16)
            make.bottom.equalTo(-24)
        }
        
        containerView.addGradientLayer(colors: UIColor.popupBgColors(), frame: CGRect(origin: .zero, size: CGSize(width: UIScreen.screenWidth-48, height: 306)), startPoint: .zero, endPoint: CGPoint(x: 0, y: 1))
    }
    
    private func addEvent() {
        closeBtn.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.hide()
        }).disposed(by: bag)
        
        addBackBtn.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.uploadFileHandle?()
            self.hide()
        }).disposed(by: bag)
        
        addBtn.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.uploadFileHandle?()
            self.hide()
        }).disposed(by: bag)
    }
}
