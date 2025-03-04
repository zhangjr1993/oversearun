//
//  String+Extension.swift
//  AIRun
//
//  Created by AIRun on 20247/7.
//

import Foundation
import CommonCrypto


extension String {
    /// 是否是有效的字符串（当是nil、@""、空格、\n、null、<null>等，返回NO）
    var isValidStr: Bool {
        guard !self.isEmpty else { return false }
        guard self != "null" else { return false }
        guard self != "nil" else { return false }
        guard self != "<null>" else { return false }
        guard self != "" else { return false }

        var t = self.trimmingCharacters(in: .whitespacesAndNewlines)
        t = t.replacingOccurrences(of: " ", with: "")
        t = t.replacingOccurrences(of: "\r", with: "")
        t = t.replacingOccurrences(of: "\n", with: "")
        guard !t.isEmpty else { return false }
        return true
    }
    
    
    
    /// 是否是无效的字符
    var isUnValidStr: Bool {
        return !self.isValidStr
    }
    
    var intValue: Int {
        Int(self) ?? 0
    }
    
    var integerValue: NSInteger {
        NSInteger(self) ?? 0
    }
    
    var doubleValue: Double {
        Double(self) ?? 0
    }
    
    var boolValue: Bool {
        switch self.lowercased() {
        case "true","yes","1":
            return true
        case "false","no","0":
            return false
        default:
            if let int = Int(self) {
                return int != 0
            }
            return false
        }
    }
    var md5Value:String {
        let utf8 = cString(using: .utf8)
        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        CC_MD5(utf8, CC_LONG(utf8!.count - 1), &digest)
        return digest.reduce("") { $0 + String(format:"%02X", $1) }
    }
    
    func trimmed() -> String{
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static func containsEmoji(_ string: String) -> Bool {
        for scalar in string.unicodeScalars {
            if scalar.value >= 0x1F600 && scalar.value <= 0x1F64F {
                // 特殊表情符号-表情（Emoji表情）
                return true
            }
            if scalar.value >= 0x2600 && scalar.value <= 0x26FF {
                // 特殊表情符号-符号
                return true
            }
            if scalar.value >= 0x2700 && scalar.value <= 0x27BF {
                // 特殊表情符号-符号
                return true
            }
           
        }
        return false
    }
}


//MARK: String Encrypt
extension String {

    /// 参数RSA 加密
    func rsaEncrypted() -> String {
        var reslutStr = ""
        do {
            let rsa_publicKey = try PublicKey(pemEncoded: AppConfig.runningRsaPublicKey)
            let clear = try ClearMessage(string: self, using: .utf8)
            reslutStr = try clear.encrypted(with: rsa_publicKey, padding: .PKCS1).base64String
        }catch {
            printLog(message: "RSA加密失败")
        }
        return reslutStr
    }
    
    /// 随机字符串
    static func randomString(length: Int) -> String {
        let letters: NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMnopQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        var randomString = ""
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar,length: 1) as String
        }
        return randomString
    }
    
    ///  接口 AES加密
    func aes256Encrypt(key: String) -> String? {
        do {
            let aes = try AES(key: Padding.zeroPadding.add(to: key.bytes, blockSize: 32), blockMode: ECB(), padding: .pkcs7)
            let encrypted = try aes.encrypt(self.bytes)
            let str = encrypted.toBase64()
            print("加密结果(base64)：\(str)")
            return str
        } catch {
            print(error)
        }
        return nil
    }
    
    /// 接口 AES 解密
    func aes256Decrypt(key: String) -> String? {
        do {
            let aes = try AES(key: Padding.zeroPadding.add(to: key.bytes, blockSize: 32), blockMode: ECB(), padding: .pkcs7)
            guard let cipherData = Data(base64Encoded: self) else { return nil }
            let plainTextBytes = try aes.decrypt([UInt8](cipherData))
            let str = String(bytes: plainTextBytes, encoding: .utf8)?.trimmingCharacters(in: .controlCharacters)
            printLog(message: "解密结果：\(str ?? "")")
            return str
        } catch {
            printLog(message: error)
        }
        return nil
    }
    
    func base64Encoding() -> String {
        if let temData = self.data(using: .utf8) {
            let base64Str = temData.base64EncodedString()
            return base64Str
        }
        return ""
    }
    
    func base64Decodeding() -> String {
        
        let temData = NSData(base64Encoded: self)
        if let decodedString = NSString(data: temData! as Data, encoding: String.Encoding.utf8.rawValue) {
            return decodedString as String
        }
        return ""
    }
    
    func checkDomain() -> String {
        if !self.hasPrefix("https://") && !self.hasPrefix("http://") {
            return APPManager.default.config.staticUrlDomain + "/" + self
        }
        return self
    }
    
    func removeLastLine() -> String {
        if self.count > 1 {
            let subStr = self.substring(from: self.count-1)
            if subStr == "\n" {
                return self.substring(to: self.count-1)
            }
        }
        return self
    }
}


extension String {
    
    func textSizeIn(size: CGSize, font: UIFont, lineSpace: CGFloat, breakMode: NSLineBreakMode, alignment : NSTextAlignment) -> CGSize {
        
        var contentSize = CGSize.zero
        let paragraphStyle = NSMutableParagraphStyle.init()
        paragraphStyle.lineBreakMode = breakMode
        paragraphStyle.alignment = alignment
        paragraphStyle.lineSpacing = lineSpace

        let attributes: [NSAttributedString.Key: Any] = [.paragraphStyle: paragraphStyle, .font:font]
        let size = self.boundingRect(with: size, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: attributes, context: nil).size
        contentSize = CGSize(width: size.width + 1, height: size.height + 1)
        return contentSize
    }
    
    func convertToRichText(font: UIFont, color: UIColor, lineSpace: CGFloat = 2) -> NSMutableAttributedString {
        let attributedStr = NSMutableAttributedString(string: self, attributes: [.font: font, .foregroundColor: color])
        let style = NSMutableParagraphStyle()
        style.lineSpacing = lineSpace
        attributedStr.paragraphStyle = style
        return attributedStr
    }

}


extension String {
    var urlParameters: [String: Any]? {
        
        var params: [String: Any] = [:]
        
        let urlComponents = self.components(separatedBy:"&")
        for component in urlComponents {
            let pairComponents = component.components(separatedBy: "=")
            let key = pairComponents.first?.removingPercentEncoding
            let value = pairComponents.last?.removingPercentEncoding
            if let key = key, let value = value {
                params[key] = value
            }
        }
        return params
    }
    
    var urlDecoded: String {
        return removingPercentEncoding ?? self
    }
    
    var urlEncodedString: String? {
        let allowedCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~")
        return addingPercentEncoding(withAllowedCharacters: allowedCharacters)
    }
    
    
}

extension String {
    
    
    func matches(forPattern pattern: String?) -> NSMutableArray? {
        guard let pattern = pattern else {
            return nil
        }
          
        do {
            let regx = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
            let results = NSMutableArray()
            let searchRange = NSRange(location: 0, length: self.count)
              
            regx.enumerateMatches(in: self, options: [], range: searchRange) { (result, flags, stop) -> Void in
                if let result = result {
                    let groupRange = result.range(at: 1)
                    let match = (self as NSString).substring(with: groupRange)
                    results.add(match)
                }
            }
            return results
        } catch {
            print("Error for create regular expression:\nString: \(self)\nPattern: \(pattern)\nError: \(error)\n")
            return nil
        }
    }
    
    func ranges(withPattern pattern: String) -> [NSValue]? {
          
        var error: NSError?
        let regExp = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        let result = regExp?.matches(in: self, options: [], range: NSMakeRange(0, self.count))
          
        if let error = error {
            print("ERROR: \(result)")
            return nil
        }
          
        let count = result?.count ?? 0
        if count == 0 {
            return []
        }
          
        var ranges = [NSValue]()
        for i in 0..<count {
            if let aRange = (result?[i] as? NSTextCheckingResult)?.range {
                ranges.append(NSValue(range: aRange))
            }
            
        }
          
        return ranges
    }
    
}

// 日期选择器里的
extension String {
    /// 截取字符串从开始到 index
    ///
    /// - Parameter index: 截止字符下标
    /// - Returns: 截取的 String
    func substring(to index: Int) -> String {
        guard let end_Index = validEndIndex(original: index) else {
            return self
        }
        return String(self[startIndex..<end_Index])
    }
    /// 截取字符串从index到结束
    ///
    /// - Parameter index: 开始字符的下标
    /// - Returns: 截取的 String
    func substring(from index: Int) -> String {
        guard let start_index = validStartIndex(original: index)  else {
            return self
        }
        return String(self[start_index..<endIndex])
    }
    /// 切割字符串(区间范围 前闭后开)
    ///
    /// - Parameter range: 截取的区间范围
    /// - Returns: 截取的 String
    func sliceString(_ range: CountableRange<Int>) -> String {
        guard
            let startIndex = validStartIndex(original: range.lowerBound),
            let endIndex   = validEndIndex(original: range.upperBound),
            startIndex <= endIndex
            else {
                return ""
        }
        return String(self[startIndex..<endIndex])
    }
    /// 切割字符串(区间范围 前闭后闭)
    ///
    /// - Parameter range: 截取的区间范围
    /// - Returns: 截取的 String
    func sliceString(_ range: CountableClosedRange<Int>) -> String {
        guard
            let start_Index = validStartIndex(original: range.lowerBound),
            let end_Index   = validEndIndex(original: range.upperBound),
            startIndex <= endIndex
            else {
                return ""
        }
        
        if endIndex.utf16Offset(in: self) <= end_Index.utf16Offset(in: self) {
            return String(self[start_Index..<endIndex])
        }
        return String(self[start_Index...end_Index])
    }
    // MARK: - 校验字符串位置 是否合理，并返回String.Index
    private func validIndex(original: Int) -> String.Index {
        switch original {
        case ...startIndex.utf16Offset(in: self) : return startIndex
        case endIndex.utf16Offset(in: self)...   : return endIndex
        default                          : return index(startIndex, offsetBy: original)
        }
    }
    // MARK: - 校验是否是合法的起始位置
    private func validStartIndex(original: Int) -> String.Index? {
        guard original <= endIndex.utf16Offset(in: self) else { return nil }
        return validIndex(original: original)
    }
    // MARK: - 校验是否是合法的结束位置
    private func validEndIndex(original: Int) -> String.Index? {
        guard original >= startIndex.utf16Offset(in: self) else { return nil }
        return validIndex(original: original)
    }

    /// 字符串时间转 Date
    ///
    /// - Parameter formatter: 字符串时间的格式 yyyy-MM-dd/YYYY-MM-dd/HH:mm:ss/yyyy-MM-dd HH:mm:ss
    /// - Returns: Date
    func toDate(formatter: String) -> Date {
        if self.isUnValidStr {
            return Date()
        }
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = formatter
        let date = dateFormatter.date(from: self)
        return date ?? Date()
    }
    
}

extension Collection where Element: Equatable {
    func indexDistance(of element: Element) -> Int? {
        guard let index = firstIndex(of: element) else { return nil }
        return distance(from: startIndex, to: index)
    }
}
extension StringProtocol {
    func indexDistance(of string: Self) -> Int? {
        guard let index = range(of: string)?.lowerBound else { return nil }
        return distance(from: startIndex, to: index)
    }
}

// MARK: - 富文本匹配
extension String {
    func matchAttributedStr(_ textColor: UIColor, _ textFont: UIFont, _ matchColor: UIColor, _ matchFont: UIFont, _ match: String, lineSpace: CGFloat = 0) -> NSMutableAttributedString {
        
        let temp = NSMutableAttributedString(string: self,
                                             attributes: [.font: textFont, .foregroundColor: textColor])
        
        if !match.isValidStr {
            return temp
        }
        
        let range = (temp.string as NSString).range(of: match)
        temp.addAttributes([.font: matchFont, .foregroundColor: matchColor], range: range)
        if lineSpace > 0 {
            let style = NSMutableParagraphStyle()
            style.lineSpacing = lineSpace
            temp.paragraphStyle = style
        }
        
        return temp
    }
}
