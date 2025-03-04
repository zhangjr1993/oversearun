//
//  AppMemberManager.swift
//  AIRun
//
//  Created by AIRun on 2025/1/23.
//

import UIKit
import StoreKit

/// 购买状态
enum MemberStatus: String {
    case unknow              = "Purchase failed, error unknown"
    case orderFail           = "Order create failure"
    case notArrowed          = "In-App Purchases are not allowed"
    case missionPid          = "No products available"
    case failed              = "Transaction failed"
    case restored            = "The product has been purchased"
    case deferred            = "Trade extension"
    case checkFailure        = "Server authentication failure"
    case checkSucceed        = "Server authentication successful"
}


typealias ResultBlock = (MemberStatus) -> Void


class AppMemberManager: NSObject {
    
    
    static let `default` = AppMemberManager()
    var resultBlock: ResultBlock?
    
    private var tradeNo: String?
    private var productInfoReq: SKProductsRequest?
    private var cacheList: [PurchaseRecord] = []
    private var retry_max = 3
    private let bag: DisposeBag = DisposeBag()

    private override init() {
        super.init()
        
        SKPaymentQueue.default().add(self as SKPaymentTransactionObserver)
        // 监听应用将要销毁
        NotificationCenter.default.rx.notification(UIApplication.willTerminateNotification)
            .subscribe(onNext: { [weak self] (notification) in
                guard let self = self else { return }
                SKPaymentQueue.default().remove(self as SKPaymentTransactionObserver)
            }).disposed(by: bag)
    }
    
    func checkUnfinishedTransactions() {
        initPurchaseData()
        for purchase in cacheList {
            checkPurchase(transactionIdentifier: purchase.transactionId)
        }
    }
    
    func initPurchaseData() {
        self.cacheList = getAllCachePurchase()
        self.tradeNo = nil
    }
}

// MARK: - 1. 发起购买请求
extension AppMemberManager {
    
    func startPurchaseRequest(productID: String) {
        APPLogManager.default.writeLog(logStr: "发起订单请求")
        AppRequest(MineModuleApi.memberOrder(params: ["productId": productID]), modelType: BaseSmartModel.self) { [weak self]  dataModel, model in
            guard let `self` = self else { return }
            if let tradeNo = model.data["tradeNo"] as? String {
                self.handletradeNo(tradeNo: tradeNo, productID: productID)
                APPLogManager.default.writeLog(logStr: "创建订单成功：\(tradeNo) 商品ID：\(productID)")
            }
        }errorBlock: { [weak self] code, msg in
            guard let `self` = self else { return }
            APPLogManager.default.writeLog(logStr: "创建订单失败")
            self.resultBlock?(.orderFail)
        }
    }
    func handletradeNo(tradeNo: String, productID: String) {
        guard SKPaymentQueue.canMakePayments() else {
            self.resultBlock?(.notArrowed)
            return
        }
        // 销毁当前请求
        self.cancelProductInfoReq()
        self.tradeNo = tradeNo
        let identSet: Set<String> = [productID]

        // 请求商品信息
        productInfoReq = SKProductsRequest(productIdentifiers: identSet)
        productInfoReq?.delegate = self
        productInfoReq?.start()
    }
    
    // 销毁当前请求
    fileprivate func cancelProductInfoReq() {
        guard productInfoReq != nil else { return }
        productInfoReq?.delegate = nil
        productInfoReq?.cancel()
        productInfoReq = nil
    }
}
// MARK: - 2. 查询商品信息
extension AppMemberManager: SKProductsRequestDelegate {
    // 查询apple内购商品成功回调
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if let product = response.products[safe: 0] {
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(payment)
            APPLogManager.default.writeLog(logStr: "查询商品成功：\(product.productIdentifier)")
        }else{
            self.resultBlock?(.missionPid)
        }
    }

    // 查询apple内购商品失败
    func request(_ request: SKRequest, didFailWithError error: Error) {
        self.resultBlock?(.missionPid)
        APPLogManager.default.writeLog(logStr: "查询商品失败")
    }
    
    // 查询apple内购商品完成
    func requestDidFinish(_ request: SKRequest) {
        
    }
}


// MARK: - 3. 交易队列回调

extension AppMemberManager: SKPaymentTransactionObserver{
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {

        for transaction in transactions {
            switch transaction.transactionState {

            case .purchasing: /// 交易中
                break
            case .purchased: /// 交易完成
                if let transactionIdentifier = transaction.transactionIdentifier {
                    self.checkPurchase(transactionIdentifier: transactionIdentifier)
                    APPLogManager.default.writeLog(logStr: "交易成功订单号 = \(self.tradeNo) Apple订单号 = \(transaction.transactionIdentifier) 商品ID = \(transaction.payment.productIdentifier)")

                }
                SKPaymentQueue.default().finishTransaction(transaction)
                tradeNo = nil
            case .failed:
                tradeNo = nil
                self.resultBlock?(.failed)
                APPLogManager.default.writeLog(logStr: "交易失败：failed")
                SKPaymentQueue.default().finishTransaction(transaction)
            case .restored:
                tradeNo = nil
                self.resultBlock?(.restored)
                APPLogManager.default.writeLog(logStr: "交易失败：restored")
                SKPaymentQueue.default().finishTransaction(transaction)
            case .deferred:
                APPLogManager.default.writeLog(logStr: "交易失败：deferred")
                self.resultBlock?(.deferred)
            @unknown default:
                APPLogManager.default.writeLog(logStr: "交易失败：unknown")
                SKPaymentQueue.default().finishTransaction(transaction)
                self.resultBlock?(.unknow)
            }
        }
    }
}

// MARK: - 4. 服务器验证
extension AppMemberManager {
    /// 服务端验证
    func checkPurchase(transactionIdentifier: String) {

        guard let receiptStr = getVerifyReceipt(transactionIdentifier) else {
            self.resultBlock?(.checkFailure)
            return
        }
        // 添加缓存记录
        if let tradeNo = self.tradeNo {
            if self.cacheList.filter({$0.transactionId == transactionIdentifier || $0.tradeNo == tradeNo}).count == 0 {  // 防止重复添加缓存数据
                let model = PurchaseRecord(transactionId: transactionIdentifier, tradeNo: tradeNo, verifyData: receiptStr)
                self.cacheList.append(model)
                savePurchaseCache()
            }
        }
        // 验证购买
        let purchaseArr = self.cacheList.filter({$0.transactionId == transactionIdentifier})
        if let purchase = purchaseArr[safe: 0] {
            if purchase.retryCount >= retry_max {
                self.resultBlock?(.checkFailure)
                return
            }
            purchase.retryCount += 1
            self.checkPurchaseRequest(purchase: purchase)
        }
    }

    func checkPurchaseRequest(purchase: PurchaseRecord) {
        
        APPLogManager.default.writeLog(logStr: "服务端开始验证订单号：订单号 = \(purchase.tradeNo) Apple订单号 = \(purchase.transactionId)")

        let params = [
            "transactionId": purchase.transactionId,
            "tradeNo": purchase.tradeNo,
            "verifyData": purchase.verifyData
        ]
        AppRequest(MineModuleApi.memberCheck(params: params), modelType: BaseSmartModel.self) { [weak self]  dataModel, model in
            guard let `self` = self else { return }
            self.removePurchaseRecord(transactionId: purchase.transactionId)
            self.resultBlock?(.checkSucceed)
            APPLogManager.default.writeLog(logStr: "服务端验证成功：订单号 = \(purchase.tradeNo) Apple订单号 = \(purchase.transactionId)")

        }errorBlock: { [weak self] code, msg in
            guard let `self` = self else { return }
            self.hideLoading()
            APPLogManager.default.writeLog(logStr: "服务端验证失败：订单号 = \(purchase.tradeNo) Apple订单号 = \(purchase.transactionId) code = \(code)")
            if code == 1614 { // 重复上报已处理的订单
                self.removePurchaseRecord(transactionId: purchase.transactionId)
            }else{
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
                    self.checkPurchase(transactionIdentifier: purchase.transactionId)
                }
            }
            self.resultBlock?(.orderFail)
        }
    }
    
    
    fileprivate func getVerifyReceipt(_ transactionId: String) -> String? {
        // 有未完成的订单，先取缓存
        let purchaseArr = self.cacheList.filter( {$0.transactionId == transactionId})
        if let purchase = purchaseArr[safe: 0], purchase.verifyData.isValidStr  {
            return purchase.verifyData
        }
        // 取本地
        guard let receiptUrl = Bundle.main.appStoreReceiptURL else { return nil }
        let data = NSData(contentsOf: receiptUrl)
        let receiptStr = data?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        return receiptStr
    }
    
    private func savePurchaseCache() {
        let cachePath = purchaseCachePath()
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: cacheList, requiringSecureCoding: true)
            try data.write(to: URL(fileURLWithPath: cachePath))
        } catch {
            print("Failed to save purchase cache: \(error)")
        }
    }
    private func removePurchaseRecord(transactionId: String) {
        cacheList.removeAll { $0.transactionId == transactionId }
        savePurchaseCache()
    }
    private func getAllCachePurchase() -> [PurchaseRecord] {
        let cachePath = purchaseCachePath()
        guard FileManager.default.fileExists(atPath: cachePath) else {
            return []
        }
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: cachePath))
            let records = try NSKeyedUnarchiver.unarchivedArrayOfObjects(ofClass: PurchaseRecord.self, from: data)
            return records ?? []
        } catch {
            print("Failed to load purchase cache: \(error)")
            try? FileManager.default.removeItem(atPath: cachePath)
            return []
        }
    }
    
    private func purchaseCachePath() -> String {
        let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? ""
        let purchaseDirectoryPath = (documentDirectoryPath as NSString).appendingPathComponent("Purchase")
        
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: purchaseDirectoryPath) == false {
           try? fileManager.createDirectory(atPath: purchaseDirectoryPath, withIntermediateDirectories: true)
        }
        
        let filePath = (purchaseDirectoryPath as NSString).appendingPathComponent("TransactionInfo_\(APPManager.default.loginUID)")
        return filePath
        
    }
    
    
}


@objcMembers class PurchaseRecord: NSObject, NSSecureCoding {
    
    static var supportsSecureCoding: Bool { return true }

    var transactionId: String
    var tradeNo: String
    var verifyData: String
    var retryCount: Int

    init(transactionId: String, tradeNo: String, verifyData: String) {
        self.transactionId = transactionId
        self.tradeNo = tradeNo
        self.verifyData = verifyData
        self.retryCount = 0
        super.init()
    }
    
    required init?(coder: NSCoder) {
        guard let transactionId = coder.decodeObject(of: NSString.self, forKey: "transactionId") as? String,
              let tradeNo = coder.decodeObject(of: NSString.self, forKey: "tradeNo") as? String,
              let verifyData = coder.decodeObject(of: NSString.self, forKey: "verifyData") as? String else{
            return nil
        }
        self.transactionId = transactionId
        self.tradeNo = tradeNo
        self.verifyData = verifyData
        self.retryCount = 0
        super.init()
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(transactionId as String, forKey: "transactionId")
        coder.encode(tradeNo as String, forKey: "tradeNo")
        coder.encode(verifyData as String, forKey: "verifyData")
        coder.encode(retryCount, forKey: "retryCount")
    }
}
