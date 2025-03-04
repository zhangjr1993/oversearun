//
//  BaseAlertView.swift
//  AIRun
//
//  Created by AIRun on 20247/11.
//

import UIKit


struct AlertConfig {
    var title: String?                              // 标题
    var content: String?                            // 内容
    var cancelTitle: String = "Cancel"              // 取消按钮文字
    var confirmTitle: String = "Continue"           // 确认按钮文字
    var titleAligment: NSTextAlignment = .center    // 标题对齐方式
    var contentAligment: NSTextAlignment = .center  // 内容对齐方式
    var sideSpace: CGFloat = 40                     // BG左右间距
    var sideTitleSpace: CGFloat = 24                // Title左右间距
    var sideBtnSpace: CGFloat = 15                  // Btn左右按钮间距
    var doubleBtn: Bool = true                      // 双按钮
    var btnSpace: CGFloat = 15                      // 按钮间距
}

// 两个按钮固定一种样式
class BaseAlertView: BasePopView {
    
    let bag: DisposeBag = DisposeBag()

    /// cancelBtn左边1， confirmBtn 2，固定
    public typealias AlertActionBlock = (_ actionIndex: Int) -> Void

    private var clickActionBack: AlertActionBlock?
    private var config: AlertConfig = AlertConfig()
    
    public init(config: AlertConfig, actionBlock: AlertActionBlock?) {
        super.init()
        self.config = config
        self.animationType = .alert
        self.clickActionBack = actionBlock
        self.setupUI()
        self.buttonClickBind()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()
    
    public lazy var titleLab: UILabel = {
        let lab = UILabel()
        lab.textColor = .white
        lab.font = .blackFont(size: 18)
        lab.textAlignment = self.config.titleAligment
        lab.numberOfLines = 0
        return lab
    }()
    
    public lazy var contentLab: UILabel = {
        let lab = UILabel()
        lab.textColor = .white
        lab.font = .mediumFont(size: 16)
        lab.numberOfLines = 0
        return lab
    }()
    
    lazy var cancelBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.backgroundColor = .appCancelColor()
        btn.titleLabel?.font = .mediumFont(size: 16)
        btn.setTitleColor(UIColor.whiteColor(alpha: 0.38), for: .normal)
        btn.setTitle(self.config.cancelTitle, for: .normal)
        btn.layer.cornerRadius = 25
        return btn
    }()
    
    lazy var confirmBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.backgroundColor = .appCancelColor()
        btn.titleLabel?.font = .mediumFont(size: 16)
        btn.setTitleColor(UIColor.appBrownColor(), for: .normal)
        btn.setTitle(self.config.confirmTitle, for: .normal)
        btn.layer.cornerRadius = 25
        return btn
    }()
}

extension BaseAlertView {
    private func buttonClickBind() {
        if self.config.doubleBtn {
            cancelBtn.rx.controlEvent(.touchUpInside).subscribe(onNext: {
                self.clickActionBack?(1)
                self.hide()
            }).disposed(by: bag)
        }
        confirmBtn.rx.controlEvent(.touchUpInside).subscribe(onNext: {
            self.clickActionBack?(2)
            self.hide()
        }).disposed(by: bag)
    }
    
    @objc private func clickButton(sender: UIButton) {
        self.clickActionBack?(2)
    }
    
    private func setupUI() {
        
        addSubview(containerView)
        addSubview(titleLab)
        addSubview(contentLab)
        
        titleLab.text = self.config.title
        contentLab.attributedText = (self.config.content ?? "").convertToRichText(font: .mediumFont(size: 16), color: .white, lineSpace: 3)

        self.snp.makeConstraints { make in
            make.width.equalTo(UIScreen.screenWidth-self.config.sideSpace * 2)
            make.height.greaterThanOrEqualTo(0)
        }
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        var contentTopSpace = 20
        var titleTopSpace = 0
        if let titleStr = self.config.title {
            titleTopSpace = 24
            contentTopSpace = 15
        }
        titleLab.snp.makeConstraints { make in
            make.trailing.leading.equalToSuperview().inset(self.config.sideTitleSpace)
            make.top.equalTo(titleTopSpace)
        }
        contentLab.snp.makeConstraints { make in
            make.top.equalTo(titleLab.snp.bottom).offset(contentTopSpace)
            make.trailing.leading.equalToSuperview().inset(self.config.sideTitleSpace)
        }
        
        
        let itemWidth = self.config.doubleBtn ? (UIScreen.screenWidth-self.config.sideSpace*2 - self.config.sideBtnSpace*2 - self.config.btnSpace)/2 : (UIScreen.screenWidth-self.config.sideSpace*2 - self.config.sideBtnSpace*2)
        addSubview(confirmBtn)
        let bgImg = UIImage.createGradientImg(colors: UIColor.appGradientColor(), size: CGSize(width: itemWidth, height: 50)).isRoundCorner(25)
        confirmBtn.setBackgroundImage(bgImg, for: .normal)

        confirmBtn.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(self.config.sideBtnSpace)
            make.size.equalTo(CGSize(width: itemWidth, height: 50))
            make.top.equalTo(contentLab.snp.bottom).offset(16)
            make.bottom.equalTo(-16)
        }
        
        if self.config.doubleBtn {
            addSubview(cancelBtn)
            cancelBtn.snp.makeConstraints { make in
                make.leading.equalToSuperview().inset(self.config.sideBtnSpace)
                make.size.equalTo(CGSize(width: itemWidth, height: 50))
                make.centerY.equalTo(confirmBtn.snp.centerY)
            }
        }
        self.layoutIfNeeded()
        containerView.addGradientLayer(colors: UIColor.popupBgColors(), frame: CGRect(x: 0, y: 0, width: containerView.width, height: containerView.height), endPoint: CGPoint(x: 0, y: 1))
        
    }
}
