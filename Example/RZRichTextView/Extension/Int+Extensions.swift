//
//  Int+Extensions.swift
//  DrivingTour
//
//  Created by Zack on 2019/7/20.
//  Copyright © 2019 Zack. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation


extension Int {
    public func format(_ f: String) -> String {
        return String(format: "%\(f)ld", self)
    }
}


extension Int {
    var font: UIFont {
//        KKLog(UIFont.systemFont(ofSize: CGFloat(self)))//PingFang SC ?? UIFont.systemFont(ofSize: CGFloat(self))
        return UIFont.init(name: "PingFangSC-Regular", size: CGFloat(self))!
//        return UIFont.systemFont(ofSize: CGFloat(self))
    }
    
    var boldFont: UIFont {
        //?? UIFont.boldSystemFont(ofSize: CGFloat(self))
        return  UIFont.init(name: "PingFangSC-Semibold", size: CGFloat(self))!
//        return UIFont.boldSystemFont(ofSize: CGFloat(self))
    }
    var regular: UIFont {
        return UIFont.init(name: "PingFangSC-Regular", size: CGFloat(self))!
//        return UIFont.systemFont(ofSize: CGFloat(self), weight: .regular)
    }
    
    var light: UIFont {
        return  UIFont.init(name: "PingFangSC-Light", size: CGFloat(self)) ?? UIFont.systemFont(ofSize: CGFloat(self), weight: .light)
//        return UIFont.systemFont(ofSize: CGFloat(self), weight: .light)
    }
    
    var mediumFont: UIFont {
        //?? UIFont.systemFont(ofSize: CGFloat(self), weight: .medium)
        return  UIFont.init(name: "PingFangSC-Medium", size: CGFloat(self))!
//        return UIFont.systemFont(ofSize: CGFloat(self), weight: .medium)
    }
    
    var lineHeight: NSMutableParagraphStyle {
        let para = NSMutableParagraphStyle()
        para.maximumLineHeight = CGFloat(self)
        para.minimumLineHeight = CGFloat(self)
        return para
    }
    
    var size: CGSize {
        return CGSize(width: self, height: self)
    }
    
    var supplementZero: String {
        return String(format: "%02d", self)
    }
}

extension Int {
    /// EZSE: Checks if the integer is even.
    public var isEven: Bool { return (self % 2 == 0) }

    /// EZSE: Checks if the integer is odd.
    public var isOdd: Bool { return (self % 2 != 0) }

    /// EZSE: Checks if the integer is positive.
    public var isPositive: Bool { return (self > 0) }

    /// EZSE: Checks if the integer is negative.
    public var isNegative: Bool { return (self < 0) }

    /// EZSE: Converts integer value to Double.
    public var toDouble: Double { return Double(self) }

    /// EZSE: Converts integer value to Float.
    public var toFloat: Float { return Float(self) }

    /// EZSE: Converts integer value to CGFloat.
    public var toCGFloat: CGFloat { return CGFloat(self) }

    /// EZSE: Converts integer value to String.
    public var toString: String { return String(self) }

    /// EZSE: Converts integer value to UInt.
    public var toUInt: UInt { return UInt(self) }

    /// EZSE: Converts integer value to Int32.
    public var toInt32: Int32 { return Int32(self) }

    /// EZSE: Converts integer value to a 0..<Int range. Useful in for loops.
    public var range: CountableRange<Int> { return 0..<self }

    /// EZSE: Returns number of digits in the integer.
    public var digits: Int {
        if self == 0 {
            return 1
        } else if Int(fabs(Double(self))) <= LONG_MAX {
            return Int(log10(fabs(Double(self)))) + 1
        }
    }
    
    /// EZSE: The digits of an integer represented in an array(from most significant to least).
    /// This method ignores leading zeros and sign
    public var digitArray: [Int] {
        var digits = [Int]()
        for char in self.toString {
            if let digit = Int(String(char)) {
                digits.append(digit)
            }
        }
        return digits
    }

    /// EZSE: Returns a random integer number in the range min...max, inclusive.
    public static func random(within: Range<Int>) -> Int {
        let delta = within.upperBound - within.lowerBound
        return within.lowerBound + Int(arc4random_uniform(UInt32(delta)))
    }
}

extension UInt {
    /// EZSE: Convert UInt to Int
    public var toInt: Int { return Int(self) }
    
    /// EZSE: Greatest common divisor of two integers using the Euclid's algorithm.
    /// Time complexity of this in O(log(n))
    public static func gcd(_ firstNum: UInt, _ secondNum: UInt) -> UInt {
        let remainder = firstNum % secondNum
        if remainder != 0 {
            return gcd(secondNum, remainder)
        } else {
            return secondNum
        }
    }
    
    /// EZSE: Least common multiple of two numbers. LCM = n * m / gcd(n, m)
    public static func lcm(_ firstNum: UInt, _ secondNum: UInt) -> UInt {
        return firstNum * secondNum / UInt.gcd(firstNum, secondNum)
    }
}
