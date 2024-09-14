//
//  String+Extension.swift
//  camera_magic
//
//  Created by macer on 2024/3/13.
//

import Foundation
import UIKit
import CommonCrypto

// MARK: - 文本
public extension String {
    /// 计算单行文本行高、支持包含emoji表情符的计算。开头空格、自定义插入的文本图片不纳入计算范围
    ///
    /// - Parameter font: 字体
    /// - Returns: 文字大小
    func singleLineSize(font: UIFont) -> CGSize {
        let cfFont = CTFontCreateWithName(font.fontName as CFString, font.pointSize, nil)
        var leading = font.lineHeight - font.ascender + font.descender
        var paragraphSettings = [
            CTParagraphStyleSetting(spec: .lineSpacingAdjustment, valueSize: MemoryLayout<CGFloat>.size, value: &leading)
        ]
        let paragraphStyle = CTParagraphStyleCreate(&paragraphSettings, 1)
        let ocString = self as NSString
        let textRange = CFRange(location: 0, length: ocString.length)
        let string = CFAttributedStringCreateMutable(kCFAllocatorDefault, ocString.length)
        CFAttributedStringReplaceString(string, CFRangeMake(0, 0), ocString)
        CFAttributedStringSetAttribute(string, textRange, kCTFontAttributeName, cfFont)
        CFAttributedStringSetAttribute(string, textRange, kCTParagraphStyleAttributeName, paragraphStyle)
        guard let lstring = string else { return CGSize.zero }
        let framesetter = CTFramesetterCreateWithAttributedString(lstring)
        return CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, 0), nil, CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude), nil)
    }

    /// 指定字体单行高度
    ///
    /// - Parameter font: 字体
    /// - Returns: 高度
    func height(for font: UIFont) -> CGFloat {
        return size(for: font, size: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude), lineBreakMode: .byWordWrapping).height
    }

    /// 指定字体单行宽度
    ///
    /// - Parameter font: 字体
    /// - Returns: 宽度
    func width(for font: UIFont) -> CGFloat {
        return size(for: font, size: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude), lineBreakMode: .byWordWrapping).width
    }

    /// 计算指定字体的尺寸
    ///
    /// - Parameters:
    ///   - font: 字体
    ///   - size: 区域大小
    ///   - lineBreakMode: 换行模式
    /// - Returns: 尺寸
    func size(for font: UIFont, size: CGSize, lineBreakMode: NSLineBreakMode) -> CGSize {
        var attr: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: font]
        if lineBreakMode != .byWordWrapping {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineBreakMode = lineBreakMode
            attr[.paragraphStyle] = paragraphStyle
        }
        let rect = (self as NSString).boundingRect(with: size, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: attr, context: nil)
        return rect.size
    }
    
    // 返回组成字符串的字符数组
    var charactersArray: [Character] {
        return Array(self)
    }
    
//    // 去掉字符串首尾的空格换行，中间的空格和换行忽略
//    var trimmed: String {
//        return trimmingCharacters(in: .whitespacesAndNewlines)
//    }
//    
//    /// 是否不为空
//    ///
//    /// "", "  ", "\n", "  \n   "都视为空
//    /// 不为空返回true， 为空返回false
//    var isNotBlank: Bool {
//        return !trimmed.isEmpty
//    }
    
    /// 字符串的全部范围
    var rangeOfAll: NSRange {
        return NSRange(location: 0, length: count)
    }
    
    /// NSRange转换为当前字符串的Range
    ///
    /// - Parameter range: NSRange对象
    /// - Returns: 当前字符串的范围
    func range(for range: NSRange) -> Range<String.Index>? {
        return Range(range, in: self)
    }
}

// MARK: - 沙盒路径
public extension String {
    // Documents目录路径
    static var documentsDirectoryPath: String {
        return URL.documentsURL.path
    }
    
    // Caches目录路径
    static var cachesDirectoryPath: String {
        return URL.cachesURL.path
    }
    
    // Library目录路径
    static var libraryDirectoryPath: String {
        return URL.libraryURL.path
    }
    
    // tmp目录路径
    static var tmpDirectoryPath: String {
        return URL.tmpURL.path
    }
}
extension String {
    
    /// 返回拼接图片url
    var ImageUrl: String {
//        var url = self
//        if url.hasPrefix("http") {
//            return url
//        }
//        // baseCdnUrl
//        if url.hasPrefix("/") {
//            url.remove(at: url.startIndex)
//        }
        
//        QL2(UserManager.shared.baseCdnUrl + url)
//        return UserManager.shared.baseCdnUrl + url
        return self
    }
    
    var SourceUrl:String {
        var url = self
        if (url.contains("http://") || url.contains("https://")) {
            return url
        }else {
            //sourceUrl.contains("http://") || model.sourceUrl.contains("https://")
            if url.hasPrefix("www"){
                url = "http://" + url
            }
            return url
        }
    }
    
    var image: UIImage? {
        return UIImage(named: self)
    }
    
    var originalImage: UIImage? {
        return UIImage(named: self)?.withRenderingMode(.alwaysOriginal)
    }

    
}
// MARK: -  base64
extension String {
    
    /// base64加密
    ///
    /// - Parameter str: 目标字符串
    /// - Returns: 加密后的字符串
    static func base64EncodeFromString(_ str: String) -> String? {
        guard let base64Data = str.data(using: .utf8) else { return nil }
        return base64Data.base64EncodedString()
    }
    
    /// base64解密
    ///
    /// - Parameter str: 目标字符串
    /// - Returns: 解密后的字符串
    static func base64DecodeFromString(_ str: String) -> String? {
        guard let base64Data = Data(base64Encoded: str) else { return nil }
        return String(data: base64Data, encoding: .utf8)
    }
    
    
    /// base64加密
    ///
    /// - Parameter str: 目标字符串
    /// - Returns: 加密后的字符串
     func base64EncodeFromStr() -> String? {
        guard let base64Data = self.data(using: .utf8) else { return nil }
        return base64Data.base64EncodedString()
    }
    
    /// base64解密
    ///
    /// - Parameter str: 目标字符串
    /// - Returns: 解密后的字符串
     func base64DecodeFromString() -> String? {
        guard let base64Data = Data(base64Encoded: self) else { return nil }
        return String(data: base64Data, encoding: .utf8)
    }
}

// MARK: - 时间相关
extension String {
   static func currentTimeStamp() -> TimeInterval {
        let date = Date()
        return date.timeIntervalSince1970

    }
     func currentTimeStamp() -> TimeInterval {
         let date = Date()
         return date.timeIntervalSince1970

     }
    
    static func currentTime() -> Int {
        let currentTime = Date().timeIntervalSince1970
        let milliseconds = Int(currentTime * 1000)
        return milliseconds
    }
    


    
    /// 获取时间
    ///
    /// - Parameter format: 时间格式例如："yyyy-MM-dd"
    /// - Returns: date
    func getDate(format: String = "yyyy-MM-dd") -> Date? {
        let dataFormat = DateFormatter()
        dataFormat.dateFormat = format
        dataFormat.locale = Locale.current
        return dataFormat.date(from: self)
    }
    
    
    /// 获取时间
    ///
    /// - Parameter format: 时间格式例如："yyyy-MM-dd"
    /// - Returns: date
    static func getDate(timeStr:String,format: String = "yyyy-MM-dd") -> Date? {
        let dataFormat = DateFormatter()
        dataFormat.dateFormat = format
        dataFormat.locale = Locale.current
        return dataFormat.date(from: timeStr)
    }
    
    
    /// 传时间字符串 返回是否是今天还是昨天
    static func isDateToDateStr(timeStr:String,format: String = "yyyy-MM-dd") -> String? {
        
        if let date = getDate(timeStr: timeStr, format: format) {
            
            let calendar = Calendar.current
            /// 是否是今天
            if calendar.isDateInToday(date) {
                KKLog("今天")
                return "今天"
            }else if calendar.isDateInYesterday(date) {
                ///是否是昨天
                return "昨天"
            }else {
                
                if let dataStr = String.dateString(timeStamp: timeStr, format: "MM-dd HH:mm") {
                    return dataStr
                }
            }
        }
      
        return nil
    }
    
    /// 返回日期格式字符串
    ///
    /// - Parameters:
    ///   - timeStamp: 时间戳
    ///   - format: 日期格式- 默认 yyyy-MM-dd HH:mm
    /// - Returns: 字符串
    static func dateString(timeStamp: String, format: String = "yyyy-MM-dd HH:mm") -> String? {
        if !timeStamp.isNumber() {return nil}
        
    

        let interval = timeStamp.toDouble() ?? Date().timeIntervalSince1970
        let formatter = DateFormatter()
        //        formatter.dateStyle = .medium
        //        formatter.locale = Locale.init(identifier: "zh_CN")
        //        formatter.timeStyle = .short
        formatter.dateFormat = format
        let date = Date(timeIntervalSince1970: interval / 1000)
        return formatter.string(from: date)
    }
    
    /// 时间戳 时间转换
    func time(format: String = "yyyy-MM-dd HH:mm") -> String {
        if !isNumber() {return self}
        let formatter = DateFormatter()
        formatter.dateFormat = format
        let date = Date(timeIntervalSince1970: self.toDouble()!)
        return formatter.string(from: date)
    }
    
    
    
    /// 返回当前日期的描述信息
    /*
     刚刚（一分钟内）
     X分钟前（一小时内）
     X小时前（当天）
     昨天 HH：mm
     MM-dd HH：mm（一年内）
     yyyy-MM-dd HH：MM （更早期）
     
     */
    static func dateDescription(date: Date?) -> String {
        if date == nil {
            return ""
        }
        let calendar = Calendar.current
        //处理今天的日期
        if calendar.isDateInToday(date!) {
            let delta = Int(Date().timeIntervalSince(date!))
            if delta < 60 {
                return "刚刚"
            }
            if delta < 3600 {
                return "\(delta / 60)分钟前"
            }
            return "\(delta / 3600)小时前"
        }
        var fmt = " HH:mm"
        //根据格式字符串生成描述字符串
        let df = DateFormatter()
        df.locale = Locale(identifier: "en")
        
        if calendar.isDateInYesterday(date!) {
            df.dateFormat = fmt
            return "昨天" + df.string(from: date!)
        }else {
            fmt = "MM-dd" + fmt
            //canlendar.component(.year, from: date)  // 直接获取年的数值
            let comps = calendar.dateComponents([.year], from: date!, to: Date())
            if comps.year! > 0 {
                fmt = "yyyy-" + fmt
            }
        }
        
        df.dateFormat = fmt
        return df.string(from: date!)
    }
    
    
    
    func strikethroughText(_ text: String) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributedString.length))
        return attributedString
    }
    
    
    func strikethroughText() -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: self)
        attributedString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributedString.length))
        return attributedString
    }
    
}

extension String {
    /// 处理url携带中文情况
  
    func myUrlEncode() ->String {
        
        if let urlComponents = URLComponents(string:self) {
            var hostStr = ""
            if let host = urlComponents.host {
                hostStr = host
            }
            // 获取URL的path部分
             let path = urlComponents.path

            let trimmedPath = path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
         
            let url = "https://" + hostStr + "/" + trimmedPath.urlEncoded()
            
           return url
        }
        return self
    }
}
