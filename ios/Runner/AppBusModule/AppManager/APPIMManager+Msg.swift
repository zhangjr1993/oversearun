//
//  APPIMManager+Msg.swift
//  AIRun
//
//  Created by Bolo on 2025/2/12.
//

import Foundation

extension APPIMManager {
    /// 删除单个会话
    func deleteAiConversation(aiMid: Int, isNeedTip: Bool = false) {
        V2TIMManager.sharedInstance().deleteConversation("c2c_\(aiMid)") {
            self.convSafeArray.remove { model in
                model.userID == aiMid.stringValue
            }
            self.invokeIMDelegate { $0.onRefreshConversationList?()}
            if isNeedTip { self.showSuccessTipMsg(msg: "The chat has been deleted") }
        } fail: { code, errorStr in
            APPLogManager.default.writeLog(logStr: "会话\(aiMid)删除失败，des:\(errorStr ?? "")")
            self.showErrorTipMsg(msg: errorStr ?? "Failed to delete, please try again")
        }
        
        AppDBManager.default.deleteFromDb(fromTable: BasicAIDataTable, where: ChatQueryInfoModel.Properties.mid == aiMid)
    }
    
    /// 会话已读
    func markAiConversation(aiMid: Int) {
        V2TIMManager.sharedInstance().cleanConversationUnreadMessageCount("c2c_\(aiMid.stringValue)", cleanTimestamp: 0, cleanSequence: 0) { [weak self] in
            self?.invokeIMDelegate { $0.onRefreshConversationList?()}
        } fail: { code, msg in
            APPLogManager.default.writeLog(logStr: "当前会话已读失败，code=\(code), mid=\(aiMid), errStr = \(msg)")
        }
    }
}

// MARK: - 本地插入
extension APPIMManager {
//    func insertCustomJumpLocalMsg(type: CustomLocalMsgType, toUser: String, sender: String) {
//        if let msg = MsgCellDataManager.createJumpLocalMsg(mid: sender.intValue, type: type) {
//            
//            V2TIMManager.sharedInstance().insertC2CMessage(toLocalStorage: msg, to: toUser, sender: sender) { [weak self] in
//                guard let `self` = self else { return }
//                self.invokeIMDelegate { $0.onRecvNewMessage?(msg: msg) }
//
//            } fail: { code, msg in }
//        }
//    }
}
