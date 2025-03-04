//
//  CodePopView.swift
//  AIRun
//
//  Created by AIRun on 2025/1/20.
//

import UIKit

class CodePopView: BasePopView {

    private let bag: DisposeBag = DisposeBag()
    private var emailStr: String = ""
    private var codeTime = 60
    private var loginflag = false

    var dismissBlock: ((_ isLogin: Bool) -> Void)?
    
    init(email: String) {
        super.init()
        self.emailStr = email
        createUI()
        createUILimit()
        addEvent()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func show(in view: UIView = UIApplication.shared.keyWindow!) {
        super.show(in: view)
        self.codeView.textfield.becomeFirstResponder()
        self.codeTimeDown()
    }

    lazy var titleLab: UILabel = {
        let lab = UILabel()
        lab.textColor = .white
        lab.font = .blackFont(size: 18)
        lab.text = "Verification Code"
        lab.textAlignment = .center
        return lab
    }()
    lazy var backBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage.imgNamed(name: "btn_back_White"), for: .normal)
        return btn
    }()
    lazy var tipLab: UILabel = {
        let lab = UILabel()
        lab.textColor = .white
        lab.font = .mediumFont(size: 16)
        lab.text = "Verification code has been sent to"
        lab.textAlignment = .center
        return lab
    }()
    
    lazy var emailLab: UILabel = {
        let lab = UILabel()
        lab.textColor = .appPinkColor()
        lab.font = .blackFont(size: 16)
        lab.text = self.emailStr
        lab.textAlignment = .center
        return lab
    }()
    lazy var closeBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage.imgNamed(name: "btn_login_close"), for: .normal)
        return btn
    }()
        
    lazy var codeView: CodeInputView = {
        let view = CodeInputView()
        view.layer.cornerRadius = 24
        return view
    }()
    
    lazy var resendBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.isEnabled = false
        btn.setTitle("Resend Code", for: .normal)
        btn.setTitle("Resend Code(60)", for: .disabled)
        btn.setTitleColor(.whiteColor(alpha: 0.38), for: .disabled)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .mediumFont(size: 13)
        return btn
    }()
}

extension CodePopView {
    private func codeTimeDown() {
        Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance).take(60).subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            self.codeTime -= 1
            if self.codeTime > 0 {
                self.resendBtn.isEnabled = false
                self.resendBtn.setTitle("Resend Code(\(self.codeTime))", for: .disabled)
            } else {
                self.resendBtn.isEnabled = true
                self.resendBtn.setTitle("Resend Code", for: .normal)
            }
        }).disposed(by: bag)
    }
}

// MARK: - 构建UI
extension CodePopView{
    /// 添加UI
    func createUI() {
        self.backgroundColor = UIColor(hexStr: "#242325")
        self.animationType = .sheet
        self.enableTouchHide = false
        self.addSubview(titleLab)
        self.addSubview(backBtn)
        self.addSubview(tipLab)
        self.addSubview(emailLab)
        self.addSubview(closeBtn)
        self.addSubview(codeView)
        self.addSubview(resendBtn)
        self.clipCorner([.topLeft, .topRight], radius: 8, rect: CGRect(x: 0, y: 0, width: UIScreen.screenWidth, height: 240 + UIScreen.safeAreaInsets.bottom))
        
    }
    /// 设置约束
    func createUILimit(){
        self.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: UIScreen.screenWidth, height: 240 + UIScreen.safeAreaInsets.bottom))
        }
        
        titleLab.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(24)
            make.centerX.equalToSuperview()
            make.height.equalTo(18)
        }
        
        backBtn.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalTo(titleLab)
            make.width.equalTo(56)
            make.height.equalTo(66)
        }
        
        closeBtn.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalTo(titleLab)
            make.width.equalTo(56)
            make.height.equalTo(66)
        }
        tipLab.snp.makeConstraints { make in
            make.top.equalTo(titleLab.snp.bottom).offset(16)
            make.centerX.equalTo(titleLab)
            make.height.equalTo(16)
        }
        emailLab.snp.makeConstraints { make in
            make.top.equalTo(tipLab.snp.bottom).offset(10)
            make.centerX.equalTo(titleLab)
            make.height.equalTo(16)
        }
        codeView.snp.makeConstraints { make in
            make.top.equalTo(emailLab.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(92)
        }
        resendBtn.snp.makeConstraints { make in
            make.top.equalTo(codeView.snp.bottom)
            make.trailing.equalToSuperview().inset(21)
            make.height.equalTo(30)
        }
    }
    /// 添加按钮...事件
    func addEvent() {
        
        closeBtn.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.hide()
            self.dismissBlock?(false)
        }).disposed(by: bag)
        
        resendBtn.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            AppLoginManager.default.getEmailCodeReq(email: self.emailStr, complete: { [weak self] sucess in
                guard let self = self else { return }
                if sucess {
                    self.codeTime = 60
                    self.codeTimeDown()
                }
            })
                        
        }).disposed(by: bag)
        
        backBtn.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.hide()
        }).disposed(by: bag)
        
        
        
        codeView.fieldTextChangedBlock = { [weak self] code in
            guard let `self` = self else { return }

            guard let codeStr = code, codeStr.count == 4 else {
                printLog(message:"验证码必须是4位")
                return
            }
            if self.loginflag { return }
           
            self.loginflag = true
            self.showLoading()

            AppRequest(LoginModuleApi.emailLogin(params: ["email": self.emailStr, "token": codeStr]), modelType: UserModel.self) { [weak self] dataModel, model in
                guard let `self` = self else { return }
                self.loginflag = false
                self.hideLoading()
                self.hide()
                self.dismissBlock?(true)
            } errorBlock: { [weak self] code, msg in
                guard let `self` = self else { return }
                self.loginflag = false
                self.hideLoading()
            }
        }
        
        NotificationCenter.default.rx.notification( UIResponder.keyboardWillHideNotification)
            .subscribe(onNext: { [weak self] (notification) in
                guard let self = self else { return }

                self.transform = CGAffineTransform(translationX: 0, y: -self.bounds.size.height)
                UIView.animate(withDuration: 0.25) {
                    self.transform = CGAffineTransform(translationX: 0, y: -self.bounds.size.height)
                }
            }).disposed(by: bag)

        NotificationCenter.default.rx.notification( UIResponder.keyboardWillShowNotification)
            .subscribe(onNext: { [weak self] (notification) in
                guard let self = self else { return }
                let info = notification.userInfo!
                var kbRect = (info[UIResponder.keyboardFrameEndUserInfoKey]! as! NSValue).cgRectValue
                kbRect = self.convert(kbRect, from: nil)
                let height = kbRect.size.height
                UIView.animate(withDuration: 0.25) {
                    self.transform = CGAffineTransform(translationX: 0, y: -self.bounds.size.height-height)
                }
            }).disposed(by: bag)
        
    }

}
