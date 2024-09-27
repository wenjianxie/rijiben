//
//  UserManager.swift
//  RZRichTextView_Example
//
//  Created by macer on 2024/9/27.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit

class UserManager: NSObject {

    static let share = UserManager()
    
    func clearUser() {
        RealmManager.shared.deleteAllArticles()
        PasswordManager.updatePassword(nil)
        UserDefaults.standard.set(false, forKey: "isSecurityEnabled")
        // 清除用户信息
        UserDefaults.standard.removeObject(forKey: "nickname")
        UserDefaults.standard.removeObject(forKey: "signature")
        UserDefaults.standard.removeObject(forKey: "background")
        UserDefaults.standard.removeObject(forKey: "avatar")
        
        // 如果需要清空其他相关数据，可以继续添加
        UserDefaults.standard.synchronize() // 确保立即保存更改
    }
}
