//
//  WebViewController.swift
//  AIRun
//
//  Created by AIRun on 20247/11.
//


import UIKit
@preconcurrency import WebKit

// MARK: - 属性声明 & 生命周期方法

class WebViewController: BasePresentViewController {
    
    private let disposeBag = DisposeBag()

    private var h5UrlStr: String = ""
    private var webConfig = WebViewConfig()

    private var rightUrlStr: String = ""

    init(urlString: String, config: WebViewConfig = WebViewConfig()) {
        super.init()
        self.h5UrlStr = urlString
        self.webConfig = config
        printLog(message: urlString)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        removeBridgeMethod()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.createSubviews()
        self.setupViewsConstraint()
        self.bindEvents()
        self.addBridgeMethod()
        self.addcustomUserAgent()
        self.checkWebCookies()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        hideNaviBar = self.webConfig.isTransparent || self.webConfig.isFull
        super.viewWillAppear(animated)
        self.webView.evaluateJavaScript("javascript:window.onPageShow&&onPageShow()")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.webView.evaluateJavaScript("javascript:window.onPageHide&&onPageHide()")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
   
    
    // MARK: - Lazy Load
    lazy var webView: WKWebView = {
        let webConfig = WKWebViewConfiguration.init()
        let preferences = WKPreferences.init()
        preferences.javaScriptEnabled = true
        webConfig.preferences = preferences
        webConfig.allowsInlineMediaPlayback = true
        webConfig.mediaTypesRequiringUserActionForPlayback = WKAudiovisualMediaTypes.all
        let userControl = WKUserContentController.init()
        webConfig.userContentController = userControl
        let w = WKWebView.init(frame: .zero, configuration: webConfig)
        w.uiDelegate = self
        w.navigationDelegate = self
        w.allowsLinkPreview = false
        w.allowsBackForwardNavigationGestures = false
        w.scrollView.contentInsetAdjustmentBehavior = .never
        w.isOpaque = false
        return w
    }()
    
    lazy var closeBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.isHidden = true
        btn.setImage(UIImage.imgNamed(name: "btn_chat_notify_closed"), for: .normal)
        btn.addTarget(self, action: #selector(closeWebAction), for: .touchUpInside)
        return btn
    }()
    
    @objc private func closeWebAction() {
        self.dismiss(animated: true)
    }
}

// MARK: - Request & 数据处理
extension WebViewController{
    private func beginStartRequest(){
        
        if let url = URL(string: self.h5UrlStr){
            var urlRequest = URLRequest(url: url)
            let uid = APPManager.default.loginUID
            let ssid = APPManager.default.loginPHPSESSID
            var tempArr: [String] = []
            if ssid.isValidStr {
                tempArr.append("PHPSESSID=\(ssid)")
            }
            if uid.isValidStr {
                tempArr.append("uid=\(uid)")
            }
            if tempArr.count > 0 {
                let cookieStr = tempArr.joined(separator: ";")
                urlRequest.addValue(cookieStr, forHTTPHeaderField: "Cookie")
                urlRequest.httpShouldHandleCookies = false
            }
            webView.load(urlRequest)
        }
    }
}
 
// MARK: - Public Event
extension WebViewController{
    
}
// MARK: - Privete Event
extension WebViewController{
    private func addcustomUserAgent() {
        self.webView.evaluateJavaScript("navigator.userAgent") { [weak self] (result, err) in
            guard let self = self else { return }
            var userAgent = result as? String ?? ""
            // 前端只是判断app_里面的参数无关紧要，不要异步获取，不然前端页面会错乱
            if !userAgent.contains("app_"){
                let str = " app_iphone app_version/\(AppConfig.runningNetVersion) app_deviceId/0000-0000) app_packageId/\(AppConfig.runningPkgID) app_bundleId/\(AppConfig.runningBundleID)"
                userAgent.append(str)
                self.webView.customUserAgent = userAgent
                printLog(message: "userAgent ========== \(userAgent)")
            }
        }
    }
    
    
    private func checkWebCookies(){
        
        let  h5Url: String = APPManager.default.config.H5UrlDomain        
        guard let h5Domain = URL.init(string: h5Url)?.host else { return }
        print("h5Domain = \(h5Domain)")
        
        let userID = "0"
        let cookieStore = self.webView.configuration.websiteDataStore.httpCookieStore

        cookieStore.getAllCookies { [weak self] cookies in
            guard let self = self else { return }
            printLog(message: cookies)
            var hasUidCookie = false
            var hasSessionCookie = false
            for cookie in cookies {
                if h5Domain.contains(cookie.domain) {
                    if cookie.name == "PHPSESSID" {
                        hasSessionCookie = true
                        continue
                    }
                    if cookie.name == "uid" && cookie.value == userID {
                        hasUidCookie = true
                        continue
                    }
                    if hasSessionCookie && hasUidCookie {
                        break
                    }
                }
            }
            /// 服务器有返回
            if hasUidCookie && hasSessionCookie {
                self.beginStartRequest()
            } else {
                self.insertWebCookies(hasUid: hasUidCookie, hasSession: hasSessionCookie)
            }
        }
    }
    
    private func insertWebCookies(hasUid: Bool, hasSession: Bool){
        DispatchQueue.main.async {
            
            let  h5Url: String = APPManager.default.config.H5UrlDomain
            guard let h5Domain = URL.init(string: h5Url)?.host else { return }
            let cookieStore = self.webView.configuration.websiteDataStore.httpCookieStore
            
            guard let appUrl = URL.init(string: RequestManager.share.baseUrlStr) else { return }

            guard let appCookies = HTTPCookieStorage.shared.cookies(for: appUrl) else { return }

            print("appCookies = \(appCookies)")

            var addCookies: [HTTPCookie] = []
            

            for cookie in appCookies {
                if cookie.name.uppercased() == "UID" && !hasUid {
                    var temPro: Dictionary<HTTPCookiePropertyKey, Any> = cookie.properties ?? [:]
                    temPro[HTTPCookiePropertyKey.name] = "uid"
                    temPro[HTTPCookiePropertyKey.domain] = h5Domain
                    if let temCookie = HTTPCookie.init(properties: temPro) {
                        addCookies.append(temCookie)
                    }
                }
                if cookie.name.uppercased() == "PHPSESSID" && !hasSession {
                    var temPro: Dictionary<HTTPCookiePropertyKey, Any> = cookie.properties ?? [:]
                    temPro[HTTPCookiePropertyKey.name] = "PHPSESSID"
                    temPro[HTTPCookiePropertyKey.domain] = h5Domain
                    if let temCookie = HTTPCookie.init(properties: temPro) {
                        addCookies.append(temCookie)
                    }
                }
            }
            for cookie in addCookies {
                cookieStore.setCookie(cookie)
            }
            self.beginStartRequest()
        }
    }

    
}

// MARK: H5交互
extension WebViewController: WKScriptMessageHandler{
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        DispatchQueue.main.async {
            self.handleScriptMessage(msg: message)
        }
    }
    
    func handleScriptMessage(msg: WKScriptMessage) {

        if let bodyStr = msg.body as? String {
            
            
            let model = APPH5Manager.share.handleH5Info(scheme: bodyStr)
            if model.method != .startNativePage {
                switch model.path {

                case .setRightMenu:
                    if model.queryModel != nil {
                        self.addRightItemBtn(queryModel: model.queryModel!)
                    }
                    break
                case .hideRightMenu:
                    self.navigationItem.rightBarButtonItem = nil
                    break
                case .closeWebview:
                    self.naviPopback()
                    break
                    
                case .recharge:
                    if model.queryModel != nil {
                        self.toAIProduct(queryModel: model.queryModel!)
                    }
                    break
                case .refreshInfo:
                    NotificationCenter.default.post(name: .userInfoNeedUpdated, object: nil)
                    break
               
                default: break
                    
                }
            }
        }
        
    }
    func addBridgeMethod() {
        let ucController = webView.configuration.userContentController
        ucController.add(WeakScriptMessageDelegate.init(self), name: "commonEvent")
    }
    func removeBridgeMethod() {
        let ucController = webView.configuration.userContentController
        ucController.removeAllScriptMessageHandlers()
    }
    
    func addRightItemBtn(queryModel: H5QueryModel){
        if queryModel.action.isValidStr {
            self.rightUrlStr = queryModel.action
        }
        let btn = UIButton(type: .custom)
        if queryModel.text.isValidStr {
            btn.setTitle(queryModel.text, for: .normal)
            btn.setTitleColor(.appTitle1Color(), for: .normal)
            btn.titleLabel?.font = UIFont.regularFont(size: 15)
        }
        if queryModel.icon.isValidStr {
            btn.setUrlImage(urlStr: queryModel.url)
        }
        btn.addTarget(self, action: #selector(rightBtnAction), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: btn)
    }
    @objc func rightBtnAction() {
        if self.rightUrlStr.hasPrefix("http") {
            APPPushManager.default.pushToWebView(webStr: self.rightUrlStr)
        }else{
            APPH5Manager.share.handleH5Info(scheme: self.rightUrlStr)
        }
    }
    
    func toAIProduct(queryModel: H5QueryModel){
        
        self.showLoading()
        AppMemberManager.default.resultBlock = { [weak self] status in
            guard let `self` = self else { return }
            self.hideLoading()
            if status == .orderFail || status == .checkFailure { // 接口层会弹错误提示
                return
            }
            if status == .checkSucceed {
                NotificationCenter.default.post(name: .userInfoNeedUpdated, object: nil)
                self.webView.evaluateJavaScript("vipBuyCallback(true)") { data, error in
                }
            }else{
                self.showErrorTipMsg(msg: status.rawValue)
            }
        }
        AppMemberManager.default.startPurchaseRequest(productID: queryModel.productId)
    }
    
    private func hideLoadingViewAndCloseBtn(didFinish: Bool) {
        
        if webConfig.showClose {
            self.closeBtn.isHidden = didFinish
        }
        if didFinish && (webConfig.isHalf || webConfig.isTransparent) {
            self.view.backgroundColor = UIColor.clear
            self.webView.backgroundColor = UIColor.clear
        }
    }
    
   
    
    
}

// MARK: 代理WKNavigationDelegate、WKUIDelegate

extension WebViewController: WKNavigationDelegate, WKUIDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        self.hideLoadingViewAndCloseBtn(didFinish: true)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        self.hideLoadingViewAndCloseBtn(didFinish: false)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.hideLoadingViewAndCloseBtn(didFinish: false)
    }
      
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        DispatchQueue.global().async {
            if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
                if challenge.previousFailureCount == 0 {
                    let credential = URLCredential.init(trust: challenge.protectionSpace.serverTrust!)
                    completionHandler(.useCredential, credential)
                } else {
                    completionHandler(.cancelAuthenticationChallenge, nil)
                }
            } else {
                completionHandler(.cancelAuthenticationChallenge, nil)
            }
        }
    }

    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alertController = UIAlertController.init(title: "Alert", message: message, preferredStyle: .alert)
        let action =  UIAlertAction.init(title: "OK", style: .default) { _ in
            completionHandler()
        }
        alertController.addAction(action)
        present(alertController, animated: true)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alertController = UIAlertController.init(title: "Alert", message: message, preferredStyle: .alert)
        let action =  UIAlertAction.init(title: "OK", style: .default) { _ in
            completionHandler(true)
        }
        let cancleAction =  UIAlertAction.init(title: "Cancle", style: .cancel) { _ in
            completionHandler(false)
        }
        alertController.addAction(cancleAction)
        alertController.addAction(action)

        present(alertController, animated: true)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        let alertController = UIAlertController.init(title: prompt, message: "", preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.text = defaultText
        }
        let action =  UIAlertAction.init(title: "Done", style: .default) { _ in
            completionHandler(alertController.textFields![0].text)
        }
        alertController.addAction(action)

        present(alertController, animated: true)
    }
}
// MARK: - Layout
extension WebViewController{
    // 添加视图
    private func createSubviews() {
        self.view.addSubview(self.webView)
        self.view.backgroundColor = (self.webConfig.isHalf || self.webConfig.isTransparent) ? UIColor.black.withAlphaComponent(0.2): UIColor.appBgColor()
        self.webView.backgroundColor = (self.webConfig.isHalf || self.webConfig.isTransparent) ? UIColor.black.withAlphaComponent(0.2): UIColor.appBgColor()
        
        // present 过来需要
        if self.presentingViewController != nil {
            self.navigationItem.leftBarButtonItem = self.naviPopbackItem()
        }
        
        self.view.addSubview(closeBtn)
        closeBtn.isHidden = !self.webConfig.showClose
        closeBtn.snp.makeConstraints { make in
            make.width.height.equalTo(50)
            make.trailing.equalTo(-16)
            make.top.equalTo(UIScreen.navigationStatusBarHeight)
        }

    }
    // 添加约束
    private func setupViewsConstraint() {
        webView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    // 添加事件
    private func bindEvents() {
        webView.rx.observeWeakly(String.self, "title")
                    .subscribe(onNext: { [weak self] (value) in
                        guard let self = self else { return }
                        self.title = value
                    })
                .disposed(by: disposeBag)
        
        webView.rx.observeWeakly(String.self, "canGoBack")
            .subscribe(onNext: { _ in
                
                    })
                .disposed(by: disposeBag)
    }
    override func naviPopback() {
        if self.presentingViewController != nil {
            self.dismiss(animated: true)
        }else {
            self.navigationController?.popViewController(animated: true)
        }
    }
}
