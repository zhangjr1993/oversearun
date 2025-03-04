//
//  LoginController.swift
//  AIRun
//
//  Created by AIRun on 2025/1/16.
//

import UIKit

enum LoginType {
    case google
    case apple
    case discord
    case email
}

class LoginController: BaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createUI()
        createUILimit()
        addEvent()
        setPrivacyAttrStr()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.isEnabled = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.isEnabled = false
    }
    lazy var topView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    lazy var bgView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hexStr: "#242325")
        view.clipCorner([.topLeft, .topRight], radius: 16, rect: CGRect(x: 0, y: 0, width: UIScreen.screenWidth, height: UIScreen.safeAreaInsets.bottom + 428))
        return view
    }()
    
    lazy var titleLab: UILabel = {
        let lab = UILabel()
        lab.textColor = .white
        lab.font = .blackFont(size: 18)
        lab.text = "Log in/Sign up"
        lab.textAlignment = .center
        return lab
    }()
    lazy var closeBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage.imgNamed(name: "btn_login_close"), for: .normal)
        return btn
    }()
    lazy var googleBtn: LayoutButton = {
        let btn = LayoutButton(type: .custom)
        btn.midSpacing = 12
        btn.setImage(UIImage.imgNamed(name: "icon_login_google"), for: .normal)
        btn.setTitle("Continue with Google", for: .normal)
        btn.setTitleColor(.appBgColor(), for: .normal)
        btn.titleLabel?.font = .mediumFont(size: 16)
        btn.backgroundColor = .white
        btn.layer.cornerRadius = 24
        return btn
    }()
    lazy var appleBtn: LayoutButton = {
        let btn = LayoutButton(type: .custom)
        btn.midSpacing = 12
        btn.setImage(UIImage.imgNamed(name: "icon_loging_apple"), for: .normal)
        btn.setTitle("Continue with Apple   ", for: .normal)
        btn.setTitleColor(.appBgColor(), for: .normal)
        btn.titleLabel?.font = .mediumFont(size: 16)
        btn.backgroundColor = .white
        btn.layer.cornerRadius = 24
        btn.titleLabel?.textColor = .appTitle1Color()
        return btn
    }()
    lazy var discordBtn: LayoutButton = {
        let btn = LayoutButton(type: .custom)
        btn.midSpacing = 12
        btn.setImage(UIImage.imgNamed(name: "icon_loging_discord"), for: .normal)
        btn.setTitle("Continue with Discord", for: .normal)
        btn.setTitleColor(.appBgColor(), for: .normal)
        btn.titleLabel?.font = .mediumFont(size: 16)
        btn.backgroundColor = .white
        btn.layer.cornerRadius = 24
        return btn
    }()
    lazy var sureBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.frame = CGRect(x: 0, y: 0, width: 56, height: 48)
        btn.setImage(UIImage.imgNamed(name: "btn_login_more_dis"), for: .disabled)
        btn.setImage(UIImage.imgNamed(name: "btn_login_more_nor"), for: .normal)
        btn.isEnabled = false
        return btn
    }()
    lazy var orLab: UILabel = {
        let lab = UILabel()
        lab.textColor = .white
        lab.font = .blackFont(size: 16)
        lab.text = "or"
        lab.textAlignment = .center
        return lab
    }()
    lazy var textField: UITextField = {
        let field = UITextField()
        field.placeholder = "Email address"
        field.placeholderColor = .whiteColor(alpha: 0.2)
        field.backgroundColor = .appGaryColor()
        field.textColor = .whiteColor(alpha: 0.87)
        field.font = .regularFont(size: 15)
        field.layer.cornerRadius = 24
        field.returnKeyType = .done
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 24, height: 48))
        field.leftViewMode = .always
        field.delegate = self
        let rightView = UIView(frame: CGRect(x: 0, y: 0, width: 56, height: 48))
        rightView.addSubview(sureBtn)
        field.rightView = rightView
        field.rightViewMode = .always
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.init(hexStr: "#494949").cgColor
        field.keyboardType = .emailAddress

        return field
    }()
    
    lazy var privacyBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.isSelected = false
        btn.setImage(UIImage.imgNamed(name: "btn_login_ok_nor"), for: .normal)
        btn.setImage(UIImage.imgNamed(name: "btn_login_ok_pre"), for: .selected)
        return btn
    }()
    
    lazy var privacyLab: YYLabel = {
        let lab = YYLabel()
        lab.font = .mediumFont(size: 13)
        lab.preferredMaxLayoutWidth = UIScreen.screenWidth - 92
        lab.numberOfLines = 0
        return lab
    }()
    
    lazy var ageBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.isSelected = false
        btn.setImage(UIImage.imgNamed(name: "btn_login_ok_nor"), for: .normal)
        btn.setImage(UIImage.imgNamed(name: "btn_login_ok_pre"), for: .selected)
        return btn
    }()
    lazy var ageLab: UILabel = {
        let lab = UILabel()
        lab.textColor = .whiteColor(alpha: 0.6)
        lab.font = .mediumFont(size: 13)
        lab.text = "I'm over 18."
        return lab
    }()
}

// MARK: - 业务逻辑
extension LoginController {
    
    private func handleLogin(type: LoginType) {
        // 检查复选框状态
        
        guard checkAgreements() else {
            shakeCheckboxes()
            return
        }
        self.textField.resignFirstResponder()
        // 执行对应的登录流程
        switch type {
        case .google:
            AppLoginManager.default.vc = self
            AppLoginManager.default.googleLoginHandle()
        case .apple:
            AppLoginManager.default.appleLoginHandle()
        case .discord:
            AppLoginManager.default.discordLoginHandle()
        case .email:
            getEmailCode()
        }
    }
    
    private func checkAgreements() -> Bool {
        return privacyBtn.isSelected && ageBtn.isSelected
    }
    private func shakeCheckboxes() {
        if privacyBtn.isSelected == false  {
            shakeAnimation(for: privacyLab)
            return
        }
        if ageBtn.isSelected == false  {
            shakeAnimation(for: ageLab)
            return
        }
    }
    // 抽取动画为独立方法
    private func shakeAnimation(for view: UIView) {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = 0.6
        animation.values = [-10.0, 10.0, -8.0, 8.0, -5.0, 5.0, 0.0]
        view.layer.add(animation, forKey: "shake")
    }
    
    func showCodeView() {
        let popView = CodePopView(email: self.textField.text ?? "")
        popView.dismissBlock = { [weak self] isLogin in
            guard let self = self else { return }
            if isLogin {
                APPManager.default.loginSuccessHandle()
            }
            self.dismiss(animated: true)
        }
        popView.show()
    }
}
// MARK: - request

extension LoginController {
    
    func getEmailCode() {
        
        guard let email = textField.text?.trimmed(), email.isValidStr else {
            return
        }        
        textField.resignFirstResponder()
        self.showLoading()
        AppLoginManager.default.getEmailCodeReq(email: email, complete: { [weak self] sucess in
            guard let self = self else { return }
            self.hideLoading()
            if sucess {
                self.showCodeView()
            }
        })
        
    }
    
    func requestAppleLogin(params: [String: Any]) {
        self.showLoading()
        AppRequest(LoginModuleApi.appleLogin(params: params), modelType:BaseSmartModel.self) { [weak self] dataModel, model in
            guard let self = self else { return }
            self.handleRequestSucess()
        }errorBlock: {[weak self]  code, msg in
            guard let self = self else { return }
            self.hideLoading()
        }
    }
    
    func requestGoogleLogin(params: [String: Any]) {
        self.showLoading()
        AppRequest(LoginModuleApi.googleLogin(params: params), modelType:BaseSmartModel.self) { [weak self] dataModel, model in
            guard let self = self else { return }
            self.handleRequestSucess()
        }errorBlock: { code, msg in
            self.hideLoading()
        }
    }
    func requestDiscordLogin(params: [String: Any]) {
        self.showLoading()
        AppRequest(LoginModuleApi.discordLogin(params: params), modelType:BaseSmartModel.self) { [weak self] dataModel, model in
            guard let self = self else { return }
            self.handleRequestSucess()
        }errorBlock: { code, msg in
            self.hideLoading()
        }
    }
    func handleRequestSucess(){
        self.hideLoading()
        APPManager.default.loginSuccessHandle()
        self.dismiss(animated: true)
    }
}
// MARK: - UITextFieldDelegate
extension LoginController: UITextFieldDelegate, UIGestureRecognizerDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleLogin(type: .email)
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let touchView = touch.view, touchView == self.bgView {
            return false
        }
        return true
    }
}

// MARK: - 构建UI
extension LoginController{
    /// 添加UI
    func createUI() {
        self.view.backgroundColor = .appBgColor().withAlphaComponent(0.6)
        
        view.addSubview(topView)
        view.addSubview(bgView)
        bgView.addSubview(titleLab)
        bgView.addSubview(closeBtn)
        bgView.addSubview(googleBtn)
        bgView.addSubview(appleBtn)
        bgView.addSubview(discordBtn)
        bgView.addSubview(orLab)
        bgView.addSubview(textField)
        bgView.addSubview(privacyBtn)
        bgView.addSubview(privacyLab)
        bgView.addSubview(ageLab)
        bgView.addSubview(ageBtn)
#if DEBUG
        textField.text = "bolo@guojiang.t"
#endif
    }
    /// 设置约束
    func createUILimit(){
                
        topView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.bottom.equalTo(bgView.snp.top)
        }
        
        bgView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(UIScreen.safeAreaInsets.bottom + 428)
        }
        
        titleLab.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalTo(66)
        }
        closeBtn.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalTo(titleLab)
            make.width.equalTo(56)
            make.height.equalTo(66)
        }
        googleBtn.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(48)
            make.top.equalTo(titleLab.snp.bottom)
            make.height.equalTo(48)
        }
        appleBtn.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(48)
            make.top.equalTo(googleBtn.snp.bottom).offset(16)
            make.height.equalTo(48)
        }
        discordBtn.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(48)
            make.top.equalTo(appleBtn.snp.bottom).offset(16)
            make.height.equalTo(48)
        }
        orLab.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(48)
            make.top.equalTo(discordBtn.snp.bottom).offset(6)
            make.height.equalTo(34)
        }
        textField.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(48)
            make.top.equalTo(orLab.snp.bottom)
            make.height.equalTo(48)
        }
        
        
        privacyLab.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(56)
            make.trailing.equalToSuperview().inset(35)
            make.top.equalTo(textField.snp.bottom).offset(24)
        }
        privacyBtn.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(26)
            make.top.equalTo(privacyLab.snp.top).offset(-7)
            make.width.height.equalTo(30)
        }

        ageLab.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(56)
            make.trailing.equalToSuperview().inset(35)
            make.top.equalTo(privacyLab.snp.bottom).offset(6)
            make.height.equalTo(18)
        }
        ageBtn.snp.makeConstraints { make in
            make.trailing.equalTo(ageLab.snp.leading)
            make.width.height.equalTo(30)
            make.centerY.equalTo(ageLab)
        }
    }
    /// 添加按钮...事件
    func addEvent() {
        
        let tap = UITapGestureRecognizer()
        tap.delegate = self
        topView.addGestureRecognizer(tap)
        topView.isUserInteractionEnabled = true
        tap.rx.event.subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            self.dismiss(animated: true)
        }).disposed(by: bag)
       
        textField.rx.controlEvent(.editingChanged).subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            if let inputString = self.textField.text {
                self.sureBtn.isEnabled = inputString.isValidStr
            }
        }).disposed(by: bag)
        
        closeBtn.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.dismiss(animated: true)
        }).disposed(by: bag)
        
        googleBtn.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.handleLogin(type: .google)
        }).disposed(by: bag)
        
        appleBtn.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.handleLogin(type: .apple)
        }).disposed(by: bag)
        
        discordBtn.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.handleLogin(type: .discord)

        }).disposed(by: bag)
        
        sureBtn.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.handleLogin(type: .email)
        }).disposed(by: bag)
        
        privacyBtn.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            privacyBtn.isSelected = !privacyBtn.isSelected
        }).disposed(by: bag)
        
        ageBtn.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            ageBtn.isSelected = !ageBtn.isSelected
        }).disposed(by: bag)
        
        
        AppLoginManager.default.loginComplete = { [weak self] params, type in
            guard let `self` = self else { return }
            if let params {
                switch type {
                case .apple:
                    requestAppleLogin(params: params)
                case .google:
                    requestGoogleLogin(params: params)
                case . discord:
                    requestDiscordLogin(params: params)
                default: break
                    
                }

            }
        }
        
    }
    private func setPrivacyAttrStr() {
        let text = "I have read and agree Terms of Service and Privacy Policy."
        let dict: [NSAttributedString.Key: Any] = [.font: UIFont.mediumFont(size: 13), .foregroundColor: UIColor.whiteColor(alpha: 0.6)]
        
        let attributed = NSMutableAttributedString(string: text, attributes: dict)
        attributed.lineSpacing = 2
        
        let decoration1 = YYTextDecoration.init(style: .single)
        attributed.setTextUnderline(decoration1, range: (attributed.string as NSString).range(of: "Terms of Service"))
        attributed.setTextHighlight((attributed.string as NSString).range(of: "Terms of Service"), color: .appYellowColor(), backgroundColor: .clear) { containerView, text, range, rect in
            APPPushManager.default.pushToWebView(webType: .userAgreement)
        }
        
        let decoration2 = YYTextDecoration.init(style: .single)
        attributed.setTextUnderline(decoration2, range: (attributed.string as NSString).range(of: "Privacy Policy."))
        attributed.setTextHighlight((attributed.string as NSString).range(of: "Privacy Policy"), color: .appYellowColor(), backgroundColor: .clear) { containerView, text, range, rect in
            APPPushManager.default.pushToWebView(webType: .privacyAgreement)
        }
        
        self.privacyLab.attributedText = attributed
    }

}
