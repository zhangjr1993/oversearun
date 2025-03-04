//
//  MsgCellDataManager.swift
//  AIRun
//
//  Created by Bolo on 2025/2/12.
//

import UIKit

class MsgCellDataManager: NSObject {

    static func userId() -> Int {
        return APPManager.default.loginUserModel?.user?.uid ?? 0
    }
    
    static func nickname() -> String {
        return APPManager.default.loginUserModel?.user?.nickname ?? ""
    }

    /// 文本 类型消息，消息类型 1
    static func createTextMsg(mid: Int, msgStr: String) -> (cellData: MsgTextCellData, paramsDic: [String: Any])? {
        
        let userInfo = ["nickname": MsgCellDataManager.nickname(),
                        "uid": MsgCellDataManager.userId()] as [String: Any]

        let msgContent = ["text": msgStr]
        let contentData = JSON.init(msgContent)
        let contentStr = contentData.rawString()
        
        let msgInfo = ["msgContent": contentStr ?? "",
                       "msgType": 1,
                       "toUid": mid,
                       "fromUid": MsgCellDataManager.userId(),
                       "msgSendTime": "",
                       "userInfo": userInfo] as [String: Any]
    
        let msgInfoData = JSON.init(msgInfo)
        if  let msgInfoStr = msgInfoData.rawString(), let cData = msgInfoStr.data(using: .utf8), var msgModel = ALMsgModel.deserialize(from: msgInfo) {
            let cellData = MsgTextCellData(direction: .outGoing)
            cellData.innerMessage = V2TIMManager.sharedInstance().createCustomMessage(cData)
            var contentModel = ALMsgContentModel()
            contentModel.text = msgStr
            msgModel.contentModel = contentModel
            cellData.msgModel = msgModel
            let paramsDic = ["content": msgStr.base64Encoding(), "mid": mid] as [String: Any]
           
            return (cellData, paramsDic)
        }
        return nil
    }
    
    /// 未登录的开场白和图片
    static func createOpenmarkMsgCell(mid: Int, text: String, imgUrl: String?) -> MsgTextImageCellData? {
        let userInfo = ["nickname": MsgCellDataManager.nickname(),
                        "uid": MsgCellDataManager.userId()] as [String: Any]
        
        let msgContent: [String: Any] = ["text": text,
                                         "imgMsg": ["imgUrl": imgUrl ?? "", "imgType": 1]]
//#if DEBUG
//        msgContent = ["text": "AI message: When the user and AI chat for the first time, the opening line is sent by the AI; And AI messages need to display AI avatar + nickname\n- Text messages: Special styles are displayed with content framed by *, and the normal style and special style are not in the same paragraph (text content with different styles is displayed in line wrap)",
//                      
//                      "imgMsg": ["imgUrl": "diyAiPic/greeting/2025_02_27/310d0430-cedf-4419-87ec-ec539cd59d3e.jpg",
//                                 "imgType": 1]]
//#endif
        
        let contentData = JSON.init(msgContent)
        let contentStr = contentData.rawString()
        
        let msgInfo = ["msgType": 2,
                       "msgContent": contentStr ?? "",
                       "toUid": APPManager.default.loginUserModel?.user?.uid ?? 0,
                       "fromUid": mid,
                       "userInfo": userInfo] as [String: Any]
        
        let msgInfoData = JSON.init(msgInfo)
        if let msgInfoStr = msgInfoData.rawString(), let cData = msgInfoStr.data(using: .utf8), var msgModel = ALMsgModel.deserialize(from: msgInfo) {
            
            let cellData = MsgTextImageCellData(direction: .inComing)
#if DEBUG
            // 调试
            cellData.isNeedAnimate = true
#endif
            
            cellData.innerMessage = V2TIMManager.sharedInstance().createCustomMessage(cData)
            let contentModel = ALMsgContentModel.deserialize(from: msgContent)
            msgModel.contentModel = contentModel
            cellData.msgModel = msgModel
            cellData.msgStatus = .Success
            cellData.reuseId = MsgTextImageTableCell.description()
            return cellData
        }
        
        return nil
    }
}


// MARK: - 斜体匹配
extension MsgCellDataManager {
    
    static func createParenthesisAttributedString(from text: String) -> NSAttributedString {
        let defaultAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.regularFont(size: 16),
            .foregroundColor: UIColor.appItalicColor()
        ]
        
        let attributedString = NSMutableAttributedString(string: text, attributes: defaultAttributes)
        
        let pstyle = NSMutableParagraphStyle.init()
        pstyle.lineSpacing = 1
        attributedString.paragraphStyle = pstyle
        
        // 将字符串转换为字符数组
        let chars = Array(text)
        var matchedRanges: [(Int, Int)] = []
        var usedIndices = Set<Int>()
        
        // 从右向左查找匹配的星号对
        var i = chars.count - 1
        while i >= 0 {
            // 如果当前位置已被使用或不是星号，继续向左
            if usedIndices.contains(i) || chars[i] != "*" {
                 i -= 1
                continue
            }
            
            // 找到右边的星号后，继续向左查找下一个未使用的星号
            var leftStarIndex: Int? = nil
            let k = i-1 < 0 ? 0 : i-1
            for j in (0...k).reversed() {
                if chars[j] == "*" && !usedIndices.contains(j) {
                    leftStarIndex = j
                    break
                }
            }
            
            // 如果找到配对的星号
            if let startIndex = leftStarIndex {
                matchedRanges.append((startIndex, i))
                usedIndices.insert(startIndex)
                usedIndices.insert(i)
            }
            
            i -= 1
        }
        
        // 从后向前处理每个匹配的范围，以避免修改影响后续范围的位置
        for (startIndex, endIndex) in matchedRanges.sorted(by: { $0.0 > $1.0 }) {
            let range = NSRange(location: startIndex, length: endIndex - startIndex + 1)
            let matchText = (text as NSString).substring(with: range)
            
            // 创建带有换行符的文本
            var finalText = matchText
            let isLeftAtStart = startIndex == 0
            let isRightAtEnd = endIndex == text.count - 1
            let newLineStr = "\n"
            
            // 检查前后是否已存在换行符
            let hasNewLineBefore = startIndex > 0 && chars[startIndex - 1] == "\n"
            let hasNewLineAfter = endIndex < chars.count - 1 && chars[endIndex + 1] == "\n"
            
            // 处理换行符
            if isLeftAtStart {
                // 左侧在开头，右侧不在末尾时添加换行符
                if !isRightAtEnd && !hasNewLineAfter {
                    finalText = finalText + newLineStr
                }
            } else if isRightAtEnd {
                // 右侧在末尾，左侧不在开头时添加换行符
                if !hasNewLineBefore {
                    finalText = newLineStr + finalText
                }
            } else {
                // 都在中间时前后都添加换行符（如果不存在）
                if !hasNewLineBefore {
                    finalText = newLineStr + finalText
                }
                if !hasNewLineAfter {
                    finalText = finalText + newLineStr
                }
            }
            
            let italicString = NSMutableAttributedString(string: finalText)
            
            // 设置斜体效果
            let italicMatrix = CGAffineTransform(1, 0, 0.3, 1, 0, 0)
            let fontDescriptor = UIFont.regularFont(size: 16).fontDescriptor
            let italicDescriptor = fontDescriptor.withMatrix(italicMatrix)
            let italicFont = UIFont(descriptor: italicDescriptor, size: 16)
            
            // 应用字体和颜色
            italicString.setFont(italicFont, range: NSRange(location: 0, length: finalText.count))
            italicString.setColor(UIColor.appItalicColor(alpha: 0.6), range: NSRange(location: 0, length: finalText.count))
            
            // 添加左偏移
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.firstLineHeadIndent = -6
            italicString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: finalText.count))
            
            // 替换原文本（包括星号和可能的换行符）
            attributedString.replaceCharacters(in: range, with: italicString)
        }
        
        return attributedString
    }
}

// MARK: - 固定消息文案
extension MsgCellDataManager {
    static func getLocalEnumMsgContent(msgEnumType: Int?) -> String {
        guard let msgEnumType else {
            return ""
        }
        
        if msgEnumType == ALCustomLocalMsgType.lapseMonthMembership.rawValue {
            return"Your monthly membership has expired and chat will be subject to message limits."
       
        }else if msgEnumType == ALCustomLocalMsgType.lapseYearMembership.rawValue {
            return "Your annual membership has expired and chat will be subject to message limits."
            
        }else if msgEnumType == ALCustomLocalMsgType.openMonthMember.rawValue {
            return "You have activated the monthly membership and can enjoy unlimited chat privileges,faster response speed and better chat model."
            
        }else if msgEnumType == ALCustomLocalMsgType.openYearMember.rawValue {
            return "You have activated the annual membership and can enjoy unlimited chat privileges,faster response speed and better chat model."
            
        }
        
        return ""
    }
}
