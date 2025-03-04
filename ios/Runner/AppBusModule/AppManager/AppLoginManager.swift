//
//  AppLoginManager.swift
//  AIRun
//
//  Created by AIRun on 20247/12.
//

import UIKit
import AuthenticationServices

class AppLoginManager: NSObject {
    
    static let `default` = AppLoginManager()
    private let bag: DisposeBag = DisposeBag()
    weak var vc: LoginController?
    private var webAuthSession: ASWebAuthenticationSession?

    
    var loginComplete: (( _ params: [String: Any]?, _ loginType : LoginType) -> Void)?
    
    private override init() {
        super.init()
        bindEvents()
    }
    override func copy() -> Any { return self }
    override func mutableCopy() -> Any { return self }
}

/// getmyInfo
extension AppLoginManager {
    
    private func bindEvents() {
        // 需要刷新UI
        NotificationCenter.default.rx.notification(.userInfoNeedUpdated)
            .subscribe(onNext: { [weak self] (notification) in
                guard let self = self else { return }
                self.getmyInfoReq(complete: nil)
            }).disposed(by: bag)
    }
    
    /// 用于各个登录保存数据
    func getmyInfoReq(complete: (() -> Void)?) {
        AppRequest(MineModuleApi.getMyInfo, modelType: UserModel.self) { dataModel, model in
            APPManager.default.loginUserModel = dataModel
            complete?()
        } errorBlock: { code, msg in
            complete?()
        }
    }
    
    func getEmailCodeReq(email: String ,complete: ((_ sucess: Bool) -> Void)?) {
        AppRequest(LoginModuleApi.getEmailCode(params: ["email": email]), modelType: UserModel.self) { dataModel, model in
            APPManager.default.loginUserModel = dataModel
            complete?(true)
        } errorBlock: { code, msg in
            complete?(false)
        }
    }
    
    func loginOutReq() {
        AppRequest(LoginModuleApi.loginOut, modelType: BaseSmartModel.self) { dataModel, model in
            APPManager.default.loginOutHandle()
        }
    }
    func deleteAcountReq() {
        AppRequest(LoginModuleApi.deleteAccount, modelType: BaseSmartModel.self) { dataModel, model in
            APPManager.default.loginOutHandle()
        }
    }
}

// MARK: - Apple
extension AppLoginManager {

    func appleLoginHandle() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let appleIDRequest = appleIDProvider.createRequest()
        appleIDRequest.requestedScopes = [.fullName, .email]
        let authorController = ASAuthorizationController(authorizationRequests: [appleIDRequest])
        authorController.delegate = self
        authorController.presentationContextProvider = self
        authorController.performRequests()
    }
        
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return UIApplication.shared.keyWindow!
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            let user = appleIDCredential.user
            var identityTokenStr: String?
            var authorizationCodeStr: String?
            if let identityToken = appleIDCredential.identityToken {
                identityTokenStr = String(data: identityToken, encoding: .utf8)
            }
            if let authorizationCode = appleIDCredential.authorizationCode {
                authorizationCodeStr = String(data: authorizationCode, encoding: .utf8)
            }
            let familyName = appleIDCredential.fullName?.familyName
            let givenName = appleIDCredential.fullName?.givenName
            
            var params: [String: String] = [:]
            if user.count > 0, let tokenStr = identityTokenStr, let codeStr = authorizationCodeStr, tokenStr.count > 0, codeStr.count > 0 {
                params = ["identifier": user,
                          "token": tokenStr,
                          "authCode": codeStr]
            }
            
            if !params.isEmpty {
                self.loginComplete?(params, .apple)
            } else {
                self.showErrorTipMsg(msg: "Authorization failed")
            }
        default:
            self.showErrorTipMsg(msg: "Authorization failed")
            break
        }
    }
        
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        var errorMsg = ""
        if let err = error as? ASAuthorizationError {
            switch err.code {
            case .canceled:
                errorMsg = "Cancel authorization"
            case .failed:
                errorMsg = "Authorization failed"
            case .unknown:
                errorMsg = "Authorization failed"
            case .invalidResponse:
                errorMsg = "Invalid authorization response"
            case .notHandled:
                errorMsg = "Failure to process authorization"
            case .notInteractive:
                errorMsg = "Authorization failed"
            @unknown default:
                errorMsg = "Authorization failed"
            }
        } else {
            errorMsg = error.localizedDescription
        }
        self.showErrorTipMsg(msg: errorMsg)
    }
}


// MARK: - Google

extension AppLoginManager {
    
    func googleLoginHandle() {
        GIDSignIn.sharedInstance.signIn(
            withPresenting: vc!
        ) { [weak self] signInResult, error in
            guard let self = self else { return }
            
            if let error = error {
                self.googleLoginHandleError(error: error)
                return
            }
            guard let user = signInResult?.user else { return }
            self.googleLoginHandleSucess(user: user)
        }
    }
    func googleLoginHandleError(error: Error) {
        self.showErrorTipMsg(msg: "Authorization failed")

    }
    func googleLoginHandleSucess(user: GIDGoogleUser) {
        // 获取ID 访问令牌
        if let idToken = user.idToken?.tokenString, idToken.isValidStr{
            self.loginComplete?(["idToken" : idToken], .google)
        }else{
            self.showErrorTipMsg(msg: "Authorization failed")
        }
    }
}

extension AppLoginManager: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding, ASWebAuthenticationPresentationContextProviding  {
        
    func discordLoginHandle() {
        
        guard let authURL = getAuthorizationURL() else {
            self.showErrorTipMsg(msg: "Authorization failed")
            return
        }
        webAuthSession = ASWebAuthenticationSession(url: authURL, callbackURLScheme: AppConfig.runningScheme) { [weak self] callbackURL, error in
            guard let self = self else { return }
            if let error = error{
                printLog(message: "Auth error: \(error.localizedDescription)")
                self.discordLoginHandleError(error: error)
                return
            }
            guard let callbackURL = callbackURL, let code = self.extractCode(from: callbackURL) else {
                self.discordLoginHandleError(error: nil)
                return
            }
            
            self.discordLoginHandleSucess(code: code)
            
            
        }
        webAuthSession?.presentationContextProvider = self
        webAuthSession?.prefersEphemeralWebBrowserSession = true
        webAuthSession?.start()
    }
    

    // 生成授权URL
    func getAuthorizationURL() -> URL? {
        var components = URLComponents(string: ThirdConfig.other_discordAuthorizeURL)
        

        components?.queryItems = [
               URLQueryItem(name: "response_type", value: "code"),
               URLQueryItem(name: "client_id", value: ThirdConfig.other_discordClientID),
               URLQueryItem(name: "scope", value: "identify+email"),
               URLQueryItem(name: "redirect_uri", value: ThirdConfig.other_discordRedirectUri)
        ]
        return components?.url
    }
    // 从回调URL中提取授权码
    private func extractCode(from url: URL) -> String? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
            let code = components.queryItems?.first(where: { $0.name == "code"})?.value
        else {
            return nil
        }
        return code
    }
    
    func discordLoginHandleSucess(code: String) {
        self.loginComplete?(["code" : code], .discord)

    }
    func discordLoginHandleError(error: Error?) {
        self.showErrorTipMsg(msg: "Authorization failed")
    }
    
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        if let windowScene = UIApplication.shared.connectedScenes
                    .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
           let window = windowScene.windows.first {
            return window
        }
        // 兼容旧版本
        if let window = UIApplication.shared.windows.first {
            return window
        }
        // 如果都获取不到，使用 keyWindow
        return UIApplication.shared.keyWindow ?? UIWindow()
    }
}

