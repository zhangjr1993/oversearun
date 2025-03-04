//
//  APPIMManager.swift
//  AIRun
//
//  Created by AIRun on 20247/17.
//

import Foundation


enum ALMsgDirection {
    case inComing
    case outGoing
}
enum ALMsgStatus: Int {
    case Init = 0
    case Sending
    case Success
    case Fali
    case Revoke
}


@objc protocol IMManagerDelegate: NSObjectProtocol{
        
    /// 会话列表更新
    @objc optional func onRefreshConversationList()
    
    /// 未读数更新
    @objc optional func onUnreadMsgCountChanged(count: Int)

    /// 收到新消息
    @objc optional func onRecvNewMessage(msg: V2TIMMessage)

    /// 加载完成
    @objc optional func onLoadConvListFinish(noMoreData: Bool)
    
}


class APPIMManager: NSObject {
    @objc static let share = APPIMManager()
    /// 未读数记录
    @objc dynamic var unreadMsgNum = 0
    
    var convSafeArray: ThreadSafeArray<V2TIMConversation> = ThreadSafeArray()
        
    private let multiDelegate: NSHashTable<AnyObject> = NSHashTable.weakObjects()
    
    private var requestSet: Set<Int> = []
    
    private let maxQueryCount = 20
    
    var nextSeq: UInt64 = 0

    private(set) var isIMLogin = false


    private override init() {
        super.init()
        
    }
    override func copy() -> Any { return self }
    override func mutableCopy() -> Any { return self }
        
}

extension APPIMManager {
    func initIMSDK() {
        let config = V2TIMSDKConfig.init()
        config.logLevel = .LOG_DEBUG
        V2TIMManager.sharedInstance().initSDK(ThirdConfig.other_IMAppID, config: config)
        V2TIMManager.sharedInstance().addAdvancedMsgListener(listener: self)
        V2TIMManager.sharedInstance().addConversationListener(listener: self)
        V2TIMManager.sharedInstance().add(self)
    }
    
    func loginInTXIM() {
        guard let userID = APPManager.default.loginUserModel?.user?.uid.stringValue else{ return }
        guard let userSig = APPManager.default.loginUserModel?.userSig else { return }
        V2TIMManager.sharedInstance().login(userID, userSig: userSig) {
            printLog(message: "IM 登录成功")
            APPManager.default.isReachability = true
            self.isIMLogin = true
            self.getTotalUnreadMsgCount()
            self.getHistoryConversation()
        } fail: { code, errStr in
            APPManager.default.isReachability = false
            APPLogManager.default.writeLog(logStr: "IM-\(userID)登录失败 code = \(code) errStr = \(errStr)")
            print("IM 登录失败 code = \(code) errStr = \(errStr)")
        }
    }
    
    func loginOutTXIM() {
        V2TIMManager.sharedInstance().logout {
            printLog(message: "IM 退出成功")
        } fail: { code, errStr in
            APPLogManager.default.writeLog(logStr: "IM-退出失败 code = \(code) errStr = \(errStr)")
            print("IM 退出失败 code = \(code) errStr = \(errStr)")
        }
        self.isIMLogin = true
        resetup()
    }
    
    func getTotalUnreadMsgCount(){
        V2TIMManager.sharedInstance().getTotalUnreadMessageCount { num in
            self.invokeIMDelegate { $0.onUnreadMsgCountChanged?(count: Int(num))}
        } fail: { code, str in
            
        }
    }
    
    func resetup(){
        self.nextSeq = 0
        self.convSafeArray = ThreadSafeArray()
        self.requestSet = []
        self.removeAllIMDelegate()
    }
}

// MARK: - Delegate
extension APPIMManager {
    func addIMDelegate(_ delegate: IMManagerDelegate) {
        multiDelegate.add(delegate)
    }
    
    func removeIMDelegate(_ delegate: IMManagerDelegate) {
        invokeIMDelegate {
            if $0 === delegate as AnyObject {
                multiDelegate.remove($0)
            }
        }
    }
    
    func removeAllIMDelegate() {
        multiDelegate.removeAllObjects()
    }
    
    func invokeIMDelegate(_ invocation: (IMManagerDelegate) -> Void) {
        for delegate in multiDelegate.allObjects.reversed() {
            invocation(delegate as! IMManagerDelegate)
        }
    }
}

// MARK: - 消息V2TIMAdvancedMsgListener
extension APPIMManager: V2TIMAdvancedMsgListener {
    
    /// 收到新消息
    func onRecvNewMessage(_ msg: V2TIMMessage!) {
        
        if msg.sender == APPManager.default.loginUserModel?.user?.uid.stringValue {
            return
        }
        
        if let extraStr = String(data: msg.customElem.data, encoding: .utf8), let msgModel = ALMsgModel.deserialize(from: extraStr) {
            
            
            invokeIMDelegate { $0.onRecvNewMessage?(msg: msg) }
            if msg.sender.intValue == ALConversationType.userSecretaryId.rawValue ||
                msg.sender.intValue == ALConversationType.userSystemId.rawValue {
                return
            }
            
        }
    }
    
    // 会话被删除的通知
    func onConversationDeleted(_ conversationIDList: [String]!) {
        
    }
}

// MARK: - 会话V2TIMConversationListener
extension APPIMManager: V2TIMConversationListener {
    
    /// 有新的会话
    func onNewConversation(_ conversationList: [V2TIMConversation]!) {
        self.handleConversationList(listArr: conversationList)
    }
    /// 会话变更
    func onConversationChanged(_ conversationList: [V2TIMConversation]!) {
        self.handleConversationList(listArr: conversationList)
    }
    /// 未读数更新
    func onTotalUnreadMessageCountChanged(_ totalUnreadCount: UInt64) {
        invokeIMDelegate { $0.onUnreadMsgCountChanged?(count: Int(totalUnreadCount))}
    }
    
}

// MARK: - 登录态V2TIMSDKListener
extension APPIMManager: V2TIMSDKListener {
    /// SDK 正在连接到服务器
    func onConnecting() {
        print("IM 正在连接到服务器")
    }
    /// SDK 已经成功连接到服务器
    func onConnectSuccess() {
        print("IM 已经成功连接到服务器")
    }
    /// 当前用户被踢下线
    func onKickedOffline() {

        var config = AlertConfig()
        config.title = "Offline notification"
        config.content = "Your account has been logged in on another device, and you have been forcibly logged out!"
        config.cancelTitle = "Log out"
        config.confirmTitle = "Log in"
        
        let alert = BaseAlertView(config: config) { actionIndex in
            if actionIndex == 1 { // 退出
                APPManager.default.loginOutHandle()
            }else {
                APPManager.default.loginSuccessHandle()
            }
        }
        alert.enableTouchHide = false
        alert.show()
    }
}

extension APPIMManager {
    private func sortPagingList(msgList: [V2TIMConversation]) -> [V2TIMConversation] {
        let tempList = msgList.sorted(by: { model1, model2 in
            if let last1 = model1.lastMessage, let last2 = model2.lastMessage, let time1 = last1.timestamp, let time2 = last2.timestamp {
                return time1.timeIntervalSince1970 > time2.timeIntervalSince1970
            }else {
                return model1.orderKey > model2.orderKey
            }
        })
        return tempList
    }
        
    private func handleConversationList(listArr: [V2TIMConversation]) {
        
        self.newChatSessionCacheDataQuery(listArr: listArr)
        
        var conversationMap: Dictionary<String, V2TIMConversation> = [:]
        
        self.convSafeArray.forEach { model in
            conversationMap[model.conversationID] = model
        }
        for conversation in listArr {
           
            if conversationMap.keys.contains(conversation.conversationID){
                if let model = conversationMap[conversation.conversationID], let index = self.convSafeArray.index(where: { model1 in
                    model1.conversationID == conversation.conversationID
                }) {
                    self.convSafeArray[index] = conversation
                }
            }else {
                self.convSafeArray.append(conversation)
            }
        }
        sortConversationList(safeArray: self.convSafeArray)
    }
    
    private func sortConversationList(safeArray: ThreadSafeArray<V2TIMConversation>) {
        self.convSafeArray = convSafeArray.sorted(by: { model1, model2 in
            if let last1 = model1.lastMessage, let last2 = model2.lastMessage , let time1 = last1.timestamp, let time2 = last2.timestamp {
                return time1.timeIntervalSince1970 > time2.timeIntervalSince1970
            }else {
                return model1.orderKey > model2.orderKey
            }
        })
        invokeIMDelegate { $0.onRefreshConversationList?()}
    }
}

extension APPIMManager {
    // 拉取
    func getHistoryConversation() {
        if isIMLogin {
            let filter = V2TIMConversationListFilter()
            filter.conversationGroup = ""
            V2TIMManager.sharedInstance().getConversationList(by: filter, nextSeq: self.nextSeq, count: 20) { list, nextSeq, isFinish in
                if nextSeq > 0 {
                    self.nextSeq = nextSeq
                }
                
                self.handleConversationList(listArr: list ?? [])
                self.invokeIMDelegate { $0.onLoadConvListFinish?(noMoreData: list?.count ?? 0 == 0 )}
            } fail: { code, des in
                self.invokeIMDelegate { $0.onLoadConvListFinish?(noMoreData: false)}
            }
        }else {
            invokeIMDelegate { $0.onLoadConvListFinish?(noMoreData: false)}
        }
    }
    
    /// 聊天列表下拉刷新
    func refreshChatListCacheDataQuery(safeArray: ThreadSafeArray<V2TIMConversation>) {

        var tempSet: Set<Int> = []
        
        let filterList = safeArray.filter(isIncluded: {
            return self.queryCacheCondition(mid: $0.userID.intValue)
        }).compactMap({ $0.userID.intValue })
        
        tempSet = Set(filterList)
        self.requestSet = self.requestSet.union(tempSet)
        
        requestAiQueryData(midArr: Array(tempSet))
    }
    
    /// 新会话缓存检查/聊天列表加载更多
    func newChatSessionCacheDataQuery(listArr: [V2TIMConversation]) {
        
        var tempSet: Set<Int> = []
        
        let filterList = listArr.filter { model in
            return self.queryCacheCondition(mid: model.userID.intValue)
        }.compactMap({ $0.userID.intValue })
        
        tempSet = Set(filterList)
        self.requestSet = self.requestSet.union(tempSet)
        
        requestAiQueryData(midArr: Array(tempSet))
    }
    
    /// 批量查询
    func requestAiQueryData(midArr: [Int]) {
        if midArr.count  == 0 {
            return
        }
       
        let finalArray = stride(from: 0, to: midArr.endIndex, by: maxQueryCount).map {
            Array(midArr[$0..<min($0 + maxQueryCount, midArr.count)])
        }
        let group = DispatchGroup()
        let queue = DispatchQueue(label: "ai.query.info")

        for item in finalArray {
            group.enter()
            queue.async {
                let params: [String: Any] = ["mids": item.map({ String($0)}).joined(separator: ",")]
                AppRequest(MessageModuleApi.aiQuery(params: params), modelType: TransferChatQueryInfoModel.self) { dataModel, model in
                    AppDBManager.default.batchUpdateAIData(list: dataModel.list)
                    group.leave()
                }errorBlock: {code, str in
                    group.leave()
                }
            }
        }
        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            self.invokeIMDelegate { $0.onRefreshConversationList?()}
            self.requestSet.remove(10000)
            for mid in midArr {
                self.requestSet.remove(mid)
            }
        }
    }
    
    private func queryCacheCondition(mid: Int) -> Bool {

        var ids = ALConversationType.allCases.map({ $0.rawValue })
        ids.removeLast()
        
        let condition = !ids.contains(mid) &&
        !self.requestSet.contains(mid)
        && AppDBManager.default.getAIBasicInfoData(mid: mid) == nil
        
        return condition
    }
}

