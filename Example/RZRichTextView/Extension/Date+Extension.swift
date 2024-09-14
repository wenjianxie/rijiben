//
//  Date+Extension.swift
//  camera_magic
//
//  Created by macer on 2024/7/4.
//

import Foundation


extension Date {
    // 从时间戳创建日期对象
    init(milliseconds: TimeInterval) {
        self = Date(timeIntervalSince1970: milliseconds / 1000)
    }
    
    // 格式化日期
    func formatted(_ format: String = "yyyy-MM-dd HH:mm:ss") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
    // 判断日期是否在当前日期之后
    func isAfterCurrentDate() -> Bool {
        return self > Date()
    }
}
extension Date {
    
    // 获取年份
    func getYear() -> Int {
        return Calendar.current.component(.year, from: self)
    }
    
    // 获取月份
    func getMonth() -> Int {
        return Calendar.current.component(.month, from: self)
    }
    
    // 获取几号
    func getDay() -> Int {
        return Calendar.current.component(.day, from: self)
    }
    
    
    // 获取几号，带前导零
       func getDayWithLeadingZero() -> String {
           let day = Calendar.current.component(.day, from: self)
           return String(format: "%02d", day)  // 格式化为两位数
       }
    
    // 获取星期几
    func getWeekday() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN") // 设置为简体中文
        formatter.dateFormat = "EEEE" // 显示星期的全称 (如 "Monday")
        return formatter.string(from: self)
    }
    
    // 获取日期的详细信息，返回年月日以及星期几
    func getDateDetails() -> (year: Int, month: Int, day: String, weekday: String,hour:String ) {
        let year = self.getYear()
        let month = self.getMonth()
        let day = self.getDayWithLeadingZero()
        let weekday = self.getWeekday()
        let time = self.formattedTime()
        
        
        return (year, month, day, weekday,time)
    }
    
    func formattedTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm" // 24小时制，使用 "hh:mm" 是12小时制
        return dateFormatter.string(from: self)
    }
}
