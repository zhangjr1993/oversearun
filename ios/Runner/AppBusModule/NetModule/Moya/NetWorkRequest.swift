//
//  NetWorkRequest.swift
//  SwiftApp
//
//  Created by AIRun on 20244/12.
//

import Foundation
import Moya

/// 超时时长
private var requestTimeOut: Double = 40

private let requestClosure = { (endpoint: Endpoint, done: MoyaProvider.RequestResultClosure) in
    do {
        var request = try endpoint.urlRequest()
        //设置请求时长
        request.timeoutInterval = requestTimeOut
        // 打印请求参数
        if let requestData = request.httpBody {
            printLog(message: "\(request.url!)"+"\n"+"\(request.httpMethod ?? "")"+"发送参数"+"\(String(data: request.httpBody!, encoding: String.Encoding.utf8) ?? "")")
        }else{
            printLog(message: "\(request.url!)"+"\(String(describing: request.httpMethod))")
        }
        done(.success(request))
    } catch {
        done(.failure(MoyaError.underlying(error, nil)))
    }
}

/// NetworkActivityPlugin插件用来监听网络请求

private let networkPlugin = NetworkActivityPlugin.init { (changeType, targetType) in

    print("networkPlugin \(changeType)")
    //targetType 是当前请求的基本信息
    switch(changeType){
    case .began:
        print("开始请求网络")
    case .ended:
        print("结束")
    }
}


typealias RequestModelCallback<T: SmartCodable> = ((T, ResponseModel) -> Void)

typealias RequestErrorCallback = ( (Int,String) -> Void)


typealias RequestSucessCallback = ( (Int,String) -> Void)


fileprivate let Provider = MoyaProvider<MultiTarget>(requestClosure: requestClosure, plugins: [networkPlugin], trackInflights: false)


func AppRequest<T: SmartCodable>(_ target: TargetType,
                                 modelType:T.Type,
                                 showErrorTip: Bool = true,
                                 completion: @escaping RequestModelCallback<T>,
                                 errorBlock: RequestErrorCallback? = nil ) {
    Provider.request(MultiTarget(target)) { result in
        switch result {
        case let .success(response):
            if let response = response.response {
                updateCookies(respose: response)
            }
            do {
                var data = response.data
                if UserDefaults.requestEncryption && !RequestManager.share.whiteUrlArr.contains(target.path) {
                    let jsonStr = String(data: data, encoding: .utf8)
                    let decryptJson = jsonStr?.aes256Decrypt(key: RequestManager.share.encryKeyStr)
                    if let temData = decryptJson?.data(using: .utf8) {
                        data = temData
                    }
                    
                }
                //这里转JSON用的swiftyJSON框架
                let jsonData = try JSON(data: data)
                let respModel = ResponseModel()
                /// 这里的 -999的code码 需要根据具体业务来设置
                respModel.code = jsonData["errno"].int ?? -999
                respModel.message = jsonData["msg"].stringValue
                respModel.data = jsonData["data"].dictionaryObject ?? [:]
                
                if respModel.code == 0 {
                    if let data = jsonData["data"].dictionaryObject, let bean = T.deserialize(from: data) {
                        completion(bean, respModel)
                    }else{
                        if errorBlock != nil {
                            errorBlock?( -999, "Model data parsing failed")
                        }
                        if showErrorTip {
                            NSObject.init().showErrorTipMsg(msg: "Model data parsing failed")
                        }
                    }
                }else if respModel.code == ResponseErrorCode.notLogin.rawValue || respModel.code == ResponseErrorCode.loginTimeout.rawValue { // 请先登录
                    APPManager.default.loginOutHandle()
                    if errorBlock != nil {
                        errorBlock?( respModel.code, respModel.message)
                    }
                }else{                 //判断后台返回的code码没问题就把数据闭包返回 ，我们后台是0000 以实际后台约定为准。
                    if errorBlock != nil {
                        errorBlock?( respModel.code, respModel.message)
                    }
                    if showErrorTip {
                        NSObject.init().showErrorTipMsg(msg: respModel.message)
                    }
                }
            } catch {
                if errorBlock != nil {
                    errorBlock?( -999, "Data parsing failed")
                }
                if showErrorTip {
                    NSObject.init().showErrorTipMsg(msg: "Data parsing failed\(response.statusCode)")
                }
                APPLogManager.default.requestLogging(response: response.response, errorMsg: "-999 Data parsing failed", responseModel: nil)
            }
            
        case let .failure(error):
            guard let error = error as? CustomStringConvertible else {
                //网络连接失败，提示用户
                if errorBlock != nil {
                    errorBlock?( -999, "Network request failed")
                }
                if showErrorTip {
                    NSObject.init().showErrorTipMsg(msg: "Network request failed")
                }
                APPLogManager.default.requestCatchErrorLog(target: target, errorMsg: "-999网络请求失败")
                break
            }
        }
    }
}

/// 文件下载
func DownLoadRequest(_ target: TargetType,
                     showErrorTip: Bool = false,
                     completion: RequestSucessCallback? = nil,
                     errorBlock: RequestErrorCallback? = nil ) {
    Provider.request(MultiTarget(target)) { result in
        switch result {
        case let .success(response):
            APPLogManager.default.writeLog(logStr: "语音下载成功：\(response.statusCode)")
            if completion != nil {
                completion?(0, "Download successfully")
            }

        case let .failure(error):

            guard let error = error as? CustomStringConvertible else {
                //网络连接失败，提示用户
                if errorBlock != nil {
                    errorBlock?( -999, "Network request failed")
                }
                break
            }
        }
    }
    
}
func updateCookies(respose: HTTPURLResponse){

    let httpCookies = HTTPCookie.cookies(withResponseHeaderFields: respose.allHeaderFields as? [String: String] ?? [:], for: respose.url!)
    if httpCookies.count > 0 {
        RequestManager.share.func__updateAPPCookies(cookies: httpCookies)
    }
}
