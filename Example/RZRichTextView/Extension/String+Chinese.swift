//
//  String+Chinese.swift
//  FGToolKit
//
//  Created by xgf on 2018/1/26.
//  Copyright © 2018年 xgf. All rights reserved.
//

import Foundation
import UIKit

public extension String {
    var pinyin:String? {
        get {
            let tmp = NSMutableString.init(string: self) as CFMutableString
            CFStringTransform(tmp, nil, kCFStringTransformMandarinLatin, false)
            CFStringTransform(tmp, nil, kCFStringTransformStripDiacritics, false)
            let ret = (tmp as String).lowercased()
            return ret
        }
    }
    var hasChinese:Bool {
        get {
            for ch in unicodeScalars {
                if (0x4e00 < ch.value  && ch.value < 0x9fff) {
                    return true
                }
            }
            return false
        }
    }
    var firstLetter:String? {
        get {
            guard let py = pinyin else {
                return nil
            }
            let index = py.index(py.startIndex, offsetBy: 1)
            return String(py[..<index]).uppercased()
        }
    }
    func chineseBetween(min:Int,max:Int) -> Bool {
        let reg = "[\\u4e00-\\u9fa5]{\(min),\(max)}"
        let predicate = NSPredicate.init(format: "SELF MATCHES %@", reg)
        let result = predicate.evaluate(with: self)
        return result
    }
}
extension String{
/// 富文本设置 字体大小 行间距 字间距
    func attributedString(font: UIFont, textColor: UIColor, lineSpaceing: CGFloat, wordSpaceing: CGFloat,style:NSMutableParagraphStyle) -> NSAttributedString {
        
       
        style.lineSpacing = lineSpaceing
        let attributes = [
                NSAttributedString.Key.font             : font,
                NSAttributedString.Key.foregroundColor  : textColor,
                NSAttributedString.Key.paragraphStyle   : style,
                NSAttributedString.Key.kern             : wordSpaceing]
            
            as [NSAttributedString.Key : Any]
        let attrStr = NSMutableAttributedString.init(string: self, attributes: attributes)
        
        // 设置某一范围样式
        // attrStr.addAttribute(<#T##name: NSAttributedString.Key##NSAttributedString.Key#>, value: <#T##Any#>, range: <#T##NSRange#>)
        return attrStr
    }
}
extension String {
    /// 改变字符串中数字的颜色和字体
    ///  prizeLabel.attributedText = "今日奖金50万".numberChange(color: red, font:.systemFont(ofSize: 27))
    /// - Parameters:
    ///   - color: 颜色
    ///   - font: 字体
    ///   - regx: 正则 默认数字 "\\d+"
    /// - Returns: attributeString
    func numberChange(color: UIColor,
                      font: UIFont,
                      regx: String = "\\d+") -> NSMutableAttributedString {
        let attributeString = NSMutableAttributedString(string: self)
        do {
            // 数字正则表达式
            let regexExpression = try NSRegularExpression(pattern: regx, options: NSRegularExpression.Options())
            let result = regexExpression.matches(
                in: self,
                options: NSRegularExpression.MatchingOptions(),
                range: NSMakeRange(0, count)
            )
            for item in result {
                attributeString.setAttributes(
                    [.foregroundColor : color, .font: font],
                    range: item.range
                )
            }
        } catch {
            print("Failed with error: \(error)")
        }
        return attributeString
        //prizeLabel.attributedText = "今日奖金50万".numberChange(color: red, font:.systemFont(ofSize: 27))

    }
}

extension NSMutableAttributedString {
    convenience init?(elements: [(str : String , attr : [NSAttributedString.Key : Any])]) {
        self.init(string: "")
        for ele in elements {
            let eleAttr = NSAttributedString(string: ele.str, attributes: ele.attr)
            self.append(eleAttr)
        }
    }

    
}





extension String {
    /// range转换为NSRange
    func nsRange(from range: Range<String.Index>) -> NSRange {
        return NSRange(range, in: self)
    }
    
    
    func tempDestPath() -> String? {
        var path = NSSearchPathForDirectoriesInDomains(.cachesDirectory,
            .userDomainMask, true)[0]
        path += "/\(NSUUID().uuidString)"
        let url = NSURL(fileURLWithPath: path)
         
        do {
            try FileManager.default.createDirectory(at: url as URL,
                withIntermediateDirectories: true, attributes: nil)
        } catch {
            return nil
        }
         
        if let path = url.path {
            return path
        }
         
        return nil
    }
    
   static func tempDestPath() -> String? {
        var path = NSSearchPathForDirectoriesInDomains(.cachesDirectory,
            .userDomainMask, true)[0]
        path += "/\(NSUUID().uuidString)"
        let url = NSURL(fileURLWithPath: path)
         
        do {
            try FileManager.default.createDirectory(at: url as URL,
                withIntermediateDirectories: true, attributes: nil)
        } catch {
            return nil
        }
         
        if let path = url.path {
            return path
        }
         
        return nil
    }
}

