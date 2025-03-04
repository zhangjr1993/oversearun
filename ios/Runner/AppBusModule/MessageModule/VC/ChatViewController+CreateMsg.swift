//
//  ChatViewController+CreateMsg.swift
//  AIRun
//
//  Created by Bolo on 2025/2/11.
//

import Foundation

// MARK: - 组装消息
extension ChatViewController {
    /// 发送消息
    func func__sendPriveteMsg(msgData: MsgBaseCellData, paramsDic: [String: Any], reSend: Bool) {
        let reachability = try? Reachability()
        if reachability?.connection == .unavailable {
            showErrorTipMsg(msg: "Network connection failed, please try again")
            return
        }
        sendCustomMessage(cellData: msgData)
        AppRequest(MessageModuleApi.IMSendMsg(params: paramsDic), modelType: SendMsgResultModel.self, showErrorTip: false) { dataModel, model in
            msgData.msgID = dataModel.msgId.stringValue
//            APPManager.default.loginUserModel?.user?.sendNum = dataModel.sendNum
            self.changeCustomMsg(cellData: msgData, status: .Success)
            self.showInputingEffect(isHide: false)
        }errorBlock: { [weak self] code, errStr  in
            guard let `self` = self else { return }
            self.didSendMsgError(msgData: msgData, code: code)
            self.showErrorTipMsg(msg: errStr)
        }
    }
}

extension ChatViewController {
    
    func transMsgToMsgCellData(msgList: [V2TIMMessage], newMsg: Bool) -> [MsgBaseCellData] {

        var tempCellDataArr: [MsgBaseCellData] = []
        for msg in msgList {
            if msg.userID != self.aiMID.stringValue {
                continue
            }
            if self.uiMsgs.count > 0, self.uiMsgs.first(where: {$0.msgID == msg.msgID}) != nil {
                self.isNoMoreMsg = true
                continue
            }
            
            let cellData = self.createUICellData(msg: msg)
            if cellData != nil {
                tempCellDataArr.append(cellData!)
            }
            
        }
        var tempArr: [MsgBaseCellData] = []
        
        for cellData in tempCellDataArr.reversed() {
            var sysTimeData: MsgTimeCellData?
            if let msgDate = cellData.innerMessage?.timestamp {
                sysTimeData = createSysTimeCellData(date: msgDate)
            }

            if sysTimeData != nil {
                self.msgForDate = cellData.innerMessage
                tempArr.append(sysTimeData!)
            }
            tempArr.append(cellData)
        }
        return tempArr
    }
    
    func createSysTimeCellData(date: Date) -> MsgTimeCellData? {
        if self.msgForDate == nil || fabs(date.timeIntervalSince(self.msgForDate!.timestamp)) > 18000 {
            let sysCellData = MsgTimeCellData.init(direction: .outGoing)
            sysCellData.contentStr = NSDate.messageTimeString(date: date)
            sysCellData.reuseId = MsgTimeTableCell.description()
            return sysCellData
        }
        return nil
    }
    
    func createUICellData(msg: V2TIMMessage) -> MsgBaseCellData? {
        
        let cellData: MsgBaseCellData?
        
        if let extraStr = String(data: msg.customElem.data, encoding: .utf8), var msgModel = ALMsgModel.deserialize(from: extraStr) {
            
            if let contentModel = ALMsgContentModel.deserialize(from: msgModel.msgContent) {
                msgModel.contentModel = contentModel
            }
            if msgModel.msgType == 1 {
                cellData = MsgTextCellData.init(direction: msg.isSelf ? .outGoing: .inComing)
                
            }else if msgModel.msgType == 2 {
                cellData = MsgTextImageCellData.init(direction: msg.isSelf ? .outGoing: .inComing)
                
            }else if msgModel.msgType == 6 {
                cellData = MsgJumpCellData.init(direction: msg.isSelf ? .outGoing: .inComing)
                
            }else {
                if msgModel.tips.isUnValidStr { // 老版本如果没有Tip消息
                    return nil
                }
                cellData = MsgTextCellData.init(direction: msg.isSelf ? .outGoing: .inComing)
            }
            cellData?.innerMessage = msg
            cellData?.msgModel = msgModel
            
            
            var msgStatus = 0

            if let customData = msg.localCustomData, let customStr = String(data: customData, encoding: .utf8), let jsonDic = JSON(parseJSON: customStr).dictionaryObject {
                msgStatus = jsonDic["msgStatus"] as? Int ?? 0
            }
            cellData?.msgStatus = ALMsgStatus(rawValue: msgStatus) ?? .Init
            cellData?.msgID = msg.msgID
            cellData?.direction = msg.isSelf ? .outGoing: .inComing
            if msg.status == .MSG_STATUS_SEND_FAIL {
                cellData?.msgStatus = .Fali
            }else if msg.status == .MSG_STATUS_SEND_SUCC {
                cellData?.msgStatus = .Success
            }else if msg.status == .MSG_STATUS_SENDING {
                cellData?.msgStatus = .Sending
            }
            return cellData
        }
        return nil
        
    }
    
    /**
     *  为了前端漫游消息展示，客户端发消息不插入IM，后端会直接发送IM消息，msgID等发送接口返回填充
     *  这里填充的msgId是后台返回的自定义消息，不是IM的，如果需要对cell进行其它操作，需要在获取源头的V2TIMMessage
     */
    func sendCustomMessage(cellData: MsgBaseCellData) {
        var insertIndexPaths: [IndexPath] = []
        let sysTimeData: MsgTimeCellData?
        if let imMsg = cellData.innerMessage {
            if cellData.msgStatus == .Init{  /// 新消息
                sysTimeData = createSysTimeCellData(date: imMsg.timestamp)
            }else { /// 重发
                sysTimeData = createSysTimeCellData(date: Date())
                if let row = uiMsgs.firstIndex(of: cellData) {
                    self.deleteIMMsg(index: row, imMsg: imMsg)
                }
                
            }

            cellData.msgStatus = .Sending
            
            // 先更新数据源
            if sysTimeData != nil {
                self.msgForDate = imMsg
                uiMsgs.append(sysTimeData!)
                insertIndexPaths.append(IndexPath(row: self.uiMsgs.count-1, section: 0))
            }
            
            uiMsgs.append(cellData)
            insertIndexPaths.append(IndexPath(row: self.uiMsgs.count-1, section: 0))
            
            // 统一更新UI
            if !insertIndexPaths.isEmpty {
                self.tableView.beginUpdates()
                self.tableView.insertRows(at: insertIndexPaths, with: .fade)
                self.tableView.endUpdates()
            }
        }
        self.scrollToBottom(force: true)
    }
    
    func changeCustomMsg(cellData: MsgBaseCellData, status: ALMsgStatus? = nil) {
         
        var customDic: [String: Any] = [:]
        if let customData = cellData.innerMessage?.localCustomData, let customStr = String(data: customData, encoding: .utf8), let jsonDic = JSON(parseJSON: customStr).dictionaryObject {
            customDic += jsonDic
        }
        if status !=  nil {
            customDic["msgStatus"] = status!.rawValue
        }
        if let customData = try? JSONSerialization.data(withJSONObject: customDic) {
            cellData.innerMessage?.localCustomData = customData
        }
        
        cellData.msgStatus = status ?? .Init

        if let row = uiMsgs.firstIndex(of: cellData), let cell = tableView.cellForRow(at: IndexPath(row: row, section: 0)) as? MsgBaseTableCell {
            UIView.performWithoutAnimation {
                self.tableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .none)
                cell.fillWithData(data: cellData, chatInfo: self.chatInfoModel)
            }
        }else {
            print("未取到Cell")
        }
    }
}

// MARK: - 未登录
extension ChatViewController {
    /// 未登录插入开场白
    func unloginInsertOpenMark() {
        if APPManager.default.isHasLogin(needJump: false) {
            return
        }
        
        var insertIndexPaths: [IndexPath] = []
        
        if let cellData = MsgCellDataManager.createOpenmarkMsgCell(mid: self.aiMID, text: self.chatInfoModel.greeting, imgUrl: self.chatInfoModel.greetingPic) {
            self.uiMsgs.append(cellData)
            insertIndexPaths.append(IndexPath(row: self.uiMsgs.count-1, section: 0))
        }
       
        self.tableView.beginUpdates()
        self.tableView.insertRows(at: insertIndexPaths, with: .top)
        self.tableView.endUpdates()
        
        self.scrollToBottom(force: true)
    }
}
