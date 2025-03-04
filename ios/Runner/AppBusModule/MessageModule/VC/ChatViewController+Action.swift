//
//  ChatViewController+Action.swift
//  AIRun
//
//  Created by Bolo on 2025/2/12.
//

import Foundation

extension ChatViewController {
    /// 拉取历史消息
    func loadHistoryMessage() {
        if isLoadingMsg || isNoMoreMsg || aiMID == 0 {
            return
        }
        isLoadingMsg = true
        let msgCount = 20
        if self.lastMsgGet == nil {
            self.showLoading()
        }
        V2TIMManager.sharedInstance().getC2CHistoryMessageList(self.aiMID.stringValue, count: Int32(msgCount), lastMsg: self.lastMsgGet) { [weak self] msgs in
            guard let self = self else {
                return
            }
            self.hideLoading()
            self.tableView.mj_header?.endRefreshing()
            if let tempMsgs = msgs, tempMsgs.count > 0 {
                self.lastMsgGet = tempMsgs[safe: tempMsgs.count - 1]
                let tempUIMsgs = self.transMsgToMsgCellData(msgList: msgs!, newMsg: false)
                if tempUIMsgs.count > 0 {
                    self.uiMsgs.insert(contentsOf: tempUIMsgs, at: 0)
                    self.tableView.reloadData()
                    self.tableView.layoutIfNeeded()
                }
                if self.isFirstLoadMsg == false {
                    let index = self.uiMsgs.count - tempUIMsgs.count
                    self.tableView.scrollToRow(at: IndexPath(row: index, section: 0), at: .none, animated: false)
                }else {
                    self.scrollToBottom(animated: false, force: true)
                }
                self.isNoMoreMsg = tempMsgs.count < msgCount

            }else {
                self.isNoMoreMsg = true
            }
          
            self.isLoadingMsg = false
            self.isFirstLoadMsg = false
            self.hideLoading()
            
        } fail: {  [weak self] code, desc in
            guard let self = self else {return}
            self.hideLoading()
            self.isLoadingMsg = false
            // 70107，IM账号不存在
            self.isNoMoreMsg = code == 70107
            APPLogManager.default.writeLog(logStr: "获取会话\(self.aiMID)消息详情失败：code = \(code), msg = \(desc)")
        }
    }
    
    // 草稿
    func saveConversationDraft() {
        if self.chatType != .privete {
            return
        }
        V2TIMManager.sharedInstance().setConversationDraft("c2c_\(self.aiMID)", draftText: self.chatInputView.chatTextView.text) {
        } fail: { code, errorStr in
            
        }
    }
    
    // 草稿
    func readConversationDraft() {
        if self.aiMID == 0 {
            return
        }
        
        if self.chatType != .privete {
            return
        }
        
        V2TIMManager.sharedInstance().getConversation("c2c_\(self.aiMID)") { [weak self] conv in
            guard let self = self else { return }
            if let draftText = conv?.draftText, draftText.isValidStr {
                DispatchQueue.main.asyncAfter(deadline: .now()+0.5, execute: {
                    self.chatInputView.chatTextView.text = draftText
                    self.chatInputView.chatTextView.becomeFirstResponder()
                })
            }else {
                DispatchQueue.main.asyncAfter(deadline: .now()+0.2, execute: {
                    self.view.endEditing(true)
                })
            }
        } fail: { code, errorStr in
            
        }
    }
    
    func readConversationMessage() {
        if self.isInVC, self.isActive {
            APPIMManager.share.markAiConversation(aiMid: self.aiMID)
        }
    }
}

extension ChatViewController {
    /// 删除IM消息
    func deleteIMMsgForMsgData(_ msgData: MsgBaseCellData) {
        if let row = self.uiMsgs.firstIndex(of: msgData), let imMsg = msgData.innerMessage {
            self.deleteIMMsg(index: row, imMsg: imMsg)
        }
    }
    
    /// 删除IM消息
    func deleteIMMsg(index: Int, imMsg: V2TIMMessage) {
        self.uiMsgs.remove(at: index)
        self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .fade)
        V2TIMManager.sharedInstance().deleteMessage(fromLocalStorage: imMsg) {
            printLog(message: "删除成功")
        } fail: { code, msg in
            printLog(message: "删除失败")
        }
    }
        
    
}

extension ChatViewController {
    /// 发送消息错误码
    func didSendMsgError(msgData: MsgBaseCellData, code: Int) {
        if code == ResponseErrorCode.aiDeleted.rawValue {
            self.changeCustomMsg(cellData: msgData, status: .Revoke)
//            self.showErrorTipMsg(msg: "AI has been deleted")
            APPIMManager.share.deleteAiConversation(aiMid: self.aiMID)
            self.naviPopback()
        }else if code == ResponseErrorCode.aiBanned.rawValue {
            self.changeCustomMsg(cellData: msgData, status: .Revoke)
//            self.showErrorTipMsg(msg: "AI has been banned")
            self.deleteIMMsgForMsgData(msgData)
        }else if code == ResponseErrorCode.shumeiBanned.rawValue {
            self.changeCustomMsg(cellData: msgData, status: .Revoke)
//            self.showErrorTipMsg(msg: "The content is illega, please modify it")
            self.deleteIMMsgForMsgData(msgData)
        }else if code == ResponseErrorCode.freeMsgLimited.rawValue {
            self.showErrorTipMsg(msg: "Free messages have been used up")
        }else {
            self.changeCustomMsg(cellData: msgData, status: .Fali)
        }
    }
}

extension ChatViewController {
    /// 常驻顶部信息区域
    func checkShowTopHeaderInfo() {
        guard chatType == .privete else {
            return
        }
        
        if self.isNoMoreMsg {
            let headerView = ChatTableHeaderInfoView()
            let frame = headerView.loadInfoData(model: self.chatInfoModel)
            headerView.frame = frame
            self.tableView.tableHeaderView = headerView
        }else {
            self.tableView.tableHeaderView = UIView()
        }
    }
    
    /// 输入中
    func showInputingEffect(isHide: Bool) {
        if isHide {
            let view = UIView().then { $0.backgroundColor = .clear }
            view.frame = CGRect(x: 0, y: 0, width: UIScreen.screenWidth, height: 20)
            self.tableView.tableFooterView = view
        } else {
            self.isTypewriter = true
            let footerView = ChatTableFooterView(frame: CGRect(x: 0, y: 0, width: UIScreen.screenWidth, height: 65+24))
            footerView.loadInfoData(model: self.chatInfoModel)
            self.tableView.tableFooterView = footerView
          
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5, execute: {
                let keyboardHeight = self.chatInputView.frame.height
                let footerHeight = footerView.frame.height
                let tableViewHeight = self.tableView.frame.height
                
                // 计算目标偏移量，确保footer完全可见且不被键盘遮挡
                let targetContentOffset = max(footerHeight, self.tableView.contentSize.height - (tableViewHeight - keyboardHeight) + footerHeight)
                
                self.tableView.setContentOffset(CGPoint(x: 0, y: targetContentOffset), animated: true)

            })
        }
    }
    
}
