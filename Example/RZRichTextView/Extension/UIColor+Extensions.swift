//
//  UIColor+Extensions.swift
//  DrivingTour
//
//  Created by Zack on 2019/7/12.
//  Copyright © 2019 Zack. All rights reserved.
//

import Foundation
import UIKit


@objc extension UIColor {
    // APP一些颜色
//    /// 主题色（#F2612F）橙色
    static let kthemeColor = UIColor(hexString: "FF7EA3")
//    /// 主题色（#F2612F）橙色不可用状态
//    static let kthemeDisableColor = UIColor(hex: 0xf2612f, alpha: 0.5)
    /// 蒙版颜色
    static let kMaskColor = UIColor(hex: 0x000000, alpha: 0.7)
    static let kMask28Color = UIColor(hex: 0x000000, alpha: 0.28)
    static let kMask16Color = UIColor(hex: 0x000000, alpha: 0.16)
    static let kMask56Color = UIColor(hex: 0x000000, alpha: 0.56)
    static let kfMaskWhiteColor = UIColor(hex: 0xffffff, alpha: 0.7)
    static let kh36Color = UIColor(hex: 0x000000, alpha: 0.36)
    static let kf37Color = UIColor(hex: 0xffffff, alpha: 0.37)
    static let kf88Color = UIColor(hex: 0xffffff, alpha: 0.88)
    static let kfColor = UIColor(hex: 0xffffff)
    static let kf5Color = UIColor(hex: 0xf5f5f5)
    ///一级文字（#0.92）中性色/黑色/92%
    static let k92Color = UIColor(hexString: "0x000000",alpha: 0.92)
    ///二级文字（#222222）072
    static let k72Color = UIColor(hexString: "0x000000",alpha: 0.72)
  
    static let kf39MaskColor = UIColor(hexString: "0xFFE39C",alpha: 0.50) //
    static let kf39Color = UIColor(hexString: "0xFFE39C") //
    static let k30Color = UIColor(hexString: "0x301F11") //
    static let k3Color = UIColor(hexString: "0x333333") //
    static let k66Color = UIColor(hexString: "0x666A6E") //
    
    static let k16Color = UIColor(hexString: "0x16181B") //
    
    static let k91Color = UIColor(hexString: "0x918B87") //
   

    static var random: UIColor {
        let r = Int(arc4random_uniform(255))
        let g = Int(arc4random_uniform(255))
        let b = Int(arc4random_uniform(255))
        return UIColor(red: r, green: g, blue: b)
    }
}

// MARK: - Initializers
extension UIColor {
    convenience init(hex: Int, alpha: CGFloat) {
        let r = CGFloat((hex & 0xFF0000) >> 16)/255
        let g = CGFloat((hex & 0xFF00) >> 8)/255
        let b = CGFloat(hex & 0xFF)/255
        self.init(red: r, green: g, blue: b, alpha: alpha)
    }
    
    convenience init(hex: Int) {
        self.init(hex: hex, alpha: 1.0)
    }
    
    /**
     Creates an UIColor from HEX String in "#363636" format
     
     - parameter hexString: HEX String in "#363636" format
     - returns: UIColor from HexString
     */
    convenience init(hexString: String, alpha: CGFloat = 1) {
        
        let hexString: String       = (hexString as NSString).trimmingCharacters(in: .whitespacesAndNewlines)
        let scanner                 = Scanner(string: hexString as String)
        
        if hexString.hasPrefix("#") {
            scanner.scanLocation = 1
        }
        var color: UInt32 = 0
        scanner.scanHexInt32(&color)
        
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
    
    /// Create UIColor from RGB values with optional transparency.
    ///
    /// - Parameters:
    ///   - red: red component.
    ///   - green: green component.
    ///   - blue: blue component.
    ///   - transparency: optional transparency value (default is 1)
    convenience init(red: Int, green: Int, blue: Int, transparency: CGFloat = 1) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        var trans: CGFloat {
            if transparency > 1 {
                return 1
            } else if transparency < 0 {
                return 0
            } else {
                return transparency
            }
        }
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: trans)
    }
}

extension UIColor {
    public var redComponent: Int {
        var r: CGFloat = 0
        getRed(&r, green: nil, blue: nil, alpha: nil)
        return Int(r * 255)
    }

    /// EZSE: Green component of UIColor (get-only)
    public var greenComponent: Int {
        var g: CGFloat = 0
        getRed(nil, green: &g, blue: nil, alpha: nil)
        return Int(g * 255)
    }

    /// EZSE: blue component of UIColor (get-only)
    public var blueComponent: Int {
        var b: CGFloat = 0
        getRed(nil, green: nil, blue: &b, alpha: nil)
        return Int(b * 255)
    }

    /// EZSE: Alpha of UIColor (get-only)
    public var alpha: CGFloat {
        var a: CGFloat = 0
        getRed(nil, green: nil, blue: nil, alpha: &a)
        return a
    }

    /// EZSE: Returns random UIColor with random alpha(default: false)
    public static func random(randomAlpha: Bool = false) -> UIColor {
        let randomRed = CGFloat.random()
        let randomGreen = CGFloat.random()
        let randomBlue = CGFloat.random()
        let alpha = randomAlpha ? CGFloat.random() : 1.0
        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: alpha)
    }

    /// Color to Image
    func toImage(size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
        let rect:CGRect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, true, 0)
        self.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image! // was image
    }
}
