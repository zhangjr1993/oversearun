//
//  HomeFilterSexPopView.swift
//  AIRun
//
//  Created by Bolo on 2025/1/20.
//

import UIKit

class HomeFilterSexPopView: BasePopView {
    
    private let bag: DisposeBag = DisposeBag()
    var filterSexResultHandle: ((_ sexType: UserSexType) -> Void)?
   
    override init() {
        super.init()
        self.createUI()
        self.createUILimit()
        self.addEvent()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var hideBtn = UIButton().then {
        $0.backgroundColor = .clear
    }
    
    private lazy var containerView = UIImageView().then {
        $0.isUserInteractionEnabled = true
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 16
        let img = UIImage.createGradientImg(colors: UIColor.popupBgColors(), size: CGSize(width: 80, height: 164), type: .topToBottom)
        $0.image = img
    }
    
    private lazy var allBtn = UIButton().then {
        $0.tag = 0
        var config = UIButton.Configuration.plain()
        config.contentInsets = .init(top: 0, leading: -8, bottom: 0, trailing: 8)
        config.baseBackgroundColor = .clear
        $0.configuration = config
        let img = UIImage.createColorImg(color: .clear)
        let selImg = UIImage.createColorImg(color: UIColor.whiteColor(alpha: 0.05))
        $0.setBackgroundImage(img, for: .normal)
        $0.setBackgroundImage(selImg, for: .selected)
        $0.titleLabel?.font = .regularFont(size: 15)
        $0.setTitle("Gentle All", for: .normal)
        $0.setTitleColor(UIColor.whiteColor(alpha: 0.6), for: .normal)
        $0.setTitleColor(UIColor.appPinkColor(), for: .selected)
    }
    
    private lazy var maleBtn = UIButton().then {
        $0.tag = 1
        var config = UIButton.Configuration.plain()
        config.contentInsets = .init(top: 0, leading: -26, bottom: 0, trailing: 26)
        config.baseBackgroundColor = .clear
        $0.configuration = config
        let img = UIImage.createColorImg(color: .clear)
        let selImg = UIImage.createColorImg(color: UIColor.whiteColor(alpha: 0.05))
        $0.setBackgroundImage(img, for: .normal)
        $0.setBackgroundImage(selImg, for: .selected)
        $0.titleLabel?.font = .regularFont(size: 15)
        $0.setTitle("Male", for: .normal)
        $0.setTitleColor(UIColor.whiteColor(alpha: 0.6), for: .normal)
        $0.setTitleColor(UIColor.appPinkColor(), for: .selected)
    }
    
    private lazy var femaleBtn = UIButton().then {
        $0.tag = 2
        var config = UIButton.Configuration.plain()
        config.contentInsets = .init(top: 0, leading: -16, bottom: 0, trailing: 16)
        config.baseBackgroundColor = .clear
        $0.configuration = config
        let img = UIImage.createColorImg(color: .clear)
        let selImg = UIImage.createColorImg(color: UIColor.whiteColor(alpha: 0.05))
        $0.setBackgroundImage(img, for: .normal)
        $0.setBackgroundImage(selImg, for: .selected)
        $0.titleLabel?.font = .regularFont(size: 15)
        $0.setTitle("Female", for: .normal)
        $0.setTitleColor(UIColor.whiteColor(alpha: 0.6), for: .normal)
        $0.setTitleColor(UIColor.appPinkColor(), for: .selected)
    }
    
    private lazy var noneBtn = UIButton().then {
        $0.tag = 3
        var config = UIButton.Configuration.plain()
        config.contentInsets = .init(top: 0, leading: -2, bottom: 0, trailing: 2)
        config.baseBackgroundColor = .clear
        $0.configuration = config
        let img = UIImage.createColorImg(color: .clear)
        let selImg = UIImage.createColorImg(color: UIColor.whiteColor(alpha: 0.05))
        $0.setBackgroundImage(img, for: .normal)
        $0.setBackgroundImage(selImg, for: .selected)
        $0.titleLabel?.font = .regularFont(size: 15)
        $0.setTitle("Non-binary", for: .normal)
        $0.setTitleColor(UIColor.whiteColor(alpha: 0.6), for: .normal)
        $0.setTitleColor(UIColor.appPinkColor(), for: .selected)
    }
}

extension HomeFilterSexPopView {
    func updateSelectedSex(_ sex: UserSexType) {
        let btns = [allBtn, maleBtn, femaleBtn, noneBtn]
        btns.forEach { btn in
            btn.isSelected = btn.tag == sex.rawValue
        }
    }
}

extension HomeFilterSexPopView {
    private func createUI() {
        self.addSubview(hideBtn)
        self.addSubview(containerView)
        containerView.addSubview(allBtn)
        containerView.addSubview(maleBtn)
        containerView.addSubview(femaleBtn)
        containerView.addSubview(noneBtn)
    }
    
    private func createUILimit() {
        self.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: UIScreen.screenWidth, height: UIScreen.screenHeight))
        }
        hideBtn.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        containerView.snp.makeConstraints { make in
            make.leading.equalTo(16)
            make.top.equalTo(UIScreen.statusBarHeight+42)
            make.size.equalTo(CGSize(width: 108, height: 164))
        }
        allBtn.snp.makeConstraints { make in
            make.top.equalTo(4)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(39)
        }
        maleBtn.snp.makeConstraints { make in
            make.top.equalTo(43)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(39)
        }
        femaleBtn.snp.makeConstraints { make in
            make.top.equalTo(maleBtn.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(39)
        }
        noneBtn.snp.makeConstraints { make in
            make.top.equalTo(femaleBtn.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(39)
        }
    }
    
    private func addEvent() {
        hideBtn.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.hide()
        }).disposed(by: bag)
        
        allBtn.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.filterSexResultHandle?(.unowned)
            self.hide()
        }).disposed(by: bag)
        
        maleBtn.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.filterSexResultHandle?(.boy)
            self.hide()
        }).disposed(by: bag)
        
        femaleBtn.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.filterSexResultHandle?(.girl)
            self.hide()
        }).disposed(by: bag)
        
        noneBtn.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.filterSexResultHandle?(.quadratic)
            self.hide()
        }).disposed(by: bag)
    }
}
