//
//  ChatViewController+Delegate.swift
//  AIRun
//
//  Created by Bolo on 2025/2/11.
//

import Foundation

/// MARK: - IMManagerDelegate
extension ChatViewController: IMManagerDelegate {
    
    func onRecvNewMessage(msg: V2TIMMessage) {
        if msg.userID != self.aiMID.stringValue { // 非自己的消息
            return
        }
        let tempUIMsgs = self.transMsgToMsgCellData(msgList: [msg], newMsg: true)
        if tempUIMsgs.count > 0 {
            self.showInputingEffect(isHide: true)
            self.tableView.beginUpdates()
            for tempUIMsg in tempUIMsgs {
                tempUIMsg.isNeedAnimate = tempUIMsg.direction == .inComing
                self.uiMsgs.append(tempUIMsg)
                let rows = IndexPath.init(row: self.uiMsgs.count-1, section: 0)
                self.tableView.insertRows(at: [rows], with: .fade)
            }
            self.tableView.endUpdates()
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+1.0, execute: {
            self.scrollToBottom(force: true)
        })
        
    }
}


// MARK: - Cell点击MessageCellDelegate
extension ChatViewController: MessageCellDelegate {
    
    func onSelectMessage(cell: MsgBaseTableCell?) {
        if let tempCell = cell {
            if tempCell.isKind(of: MsgTextTableCell.self) {
                
            }
        }
    }
    
    func onLongPressMessage(cell: MsgBaseTableCell?) {
        
        if self.chatType != .privete {
            return
        }

        var tempCellData: MsgBaseCellData?
        
        if let tempCell = cell {
            if tempCell.isKind(of: MsgTextTableCell.self) {
                if let textCell = tempCell as? MsgTextTableCell, let cellData = textCell.textCellData, cellData.direction == .inComing {
                    tempCellData = cellData
                }
            }
        }
    }
    
    func onRetryMessage(cell: MsgBaseTableCell?) { // 组装重发的消息
        
        var tempCellData: MsgBaseCellData?
        var paramsDic: [String: Any]?
        if let tempCell = cell {
            if tempCell.isKind(of: MsgTextTableCell.self) {
                if let textCell = tempCell as? MsgTextTableCell, let cellData = textCell.textCellData {
                    if cellData.msgModel?.msgType == 1 {
                        if let text = cellData.msgModel?.contentModel?.text {
                            tempCellData = cellData
                            paramsDic = ["type": 1, "content": text.base64Encoding(), "mid": aiMID] as [String: Any]
                        }
                    }
                }
            }
            if tempCellData != nil && paramsDic != nil {
                self.func__sendPriveteMsg(msgData: tempCellData!, paramsDic: paramsDic!, reSend: true)
            }
        }
    }
   
    func onRefreshImageMessage(cell: MsgBaseTableCell?) {
        guard let cellData = cell?.baseCellData,
              let row = uiMsgs.firstIndex(of: cellData),
              let _ = tableView.cellForRow(at: IndexPath(row: row, section: 0)) as? MsgTextImageTableCell else {
            return
        }
        
        UIView.performWithoutAnimation {
            self.tableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .none)
        }
        self.scrollToBottom(force: true)
    }
    
    func onTypewriterAnimationMessage(cell: MsgBaseTableCell?, isAnimate: Bool) {
        
        self.isTypewriter = isAnimate
        printLog(message: "打字动画中：\(isAnimate)")
    }
}

// MARK: - 键盘ChatInputViewDelegate
extension ChatViewController: ChatInputViewDelegate {
    
    func resetAIMsg() {
        
        var config = AlertConfig()
        config.content = "AI will delete your chat history and restart the chat. Are you sure you want to restart?"
        config.confirmTitle = "Refresh"

        let alert = BaseAlertView(config: config) { [weak self] actionIndex in
            guard let `self` = self else { return }
            if actionIndex == 2 {
                AppRequest(MessageModuleApi.resetChat(params: ["mid": self.aiMID]), modelType: BaseSmartModel.self) { dataModel, model in
                    self.showSuccessTipMsg(msg: "Refresh successful, let's start chatting again")
                }errorBlock: { [weak self] code, errStr  in
                    guard let `self` = self else { return }
                    self.didSendMsgError(msgData: MsgBaseCellData(direction: .inComing), code: code)
                }
            }
        }
        alert.show()
    }
    
    func sendTextMsg(msgStr: String) {

        let temStr = msgStr.trimmed()
        if temStr.isUnValidStr {
            showErrorTipMsg(msg: "The message content cannot be empty")
            return
        }
        if isTypewriter {
            showErrorTipMsg(msg: "Please wait for the response")
            return
        }
        
        if let textData = MsgCellDataManager.createTextMsg(mid: self.aiMID, msgStr: temStr) {
            self.func__sendPriveteMsg(msgData: textData.cellData, paramsDic: textData.paramsDic, reSend: false)
        }
    }
        
    func bottomHeightChanged(height: CGFloat) {
        UIView.animate(withDuration: 0.3) {
            self.chatInputView.snp.updateConstraints { make in
                make.bottom.equalTo(-height)
            }
            self.view.layoutIfNeeded()
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
            self.scrollToBottom(force: true)
        }
    }
    
    func inputViewHeightChanged(height: CGFloat) {
        
        UIView.animate(withDuration: 0.3) {
            self.chatInputView.snp.updateConstraints { make in
                make.height.equalTo(height)
            }
            self.view.layoutIfNeeded()
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
            self.scrollToBottom(force: true)
        }
    }
}
