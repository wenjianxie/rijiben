//
//  TabBarViewController.swift
//  RZRichTextView_Example
//
//  Created by macer on 2024/9/25.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

   
        let AICtr = ViewController()
        AICtr.title = "日记"
        AICtr.tabBarItem.image = "tab_icon_book".image
        AICtr.tabBarItem.selectedImage = "tab_icon_book".image
        let AICtrNav = UINavigationController.init(rootViewController: AICtr)

        let meCtr1 = ProfileViewController()
//        meCtr1.title = "我的"
        meCtr1.tabBarItem.title = "我的"
        meCtr1.tabBarItem.image = "tab_icon_me".image
        meCtr1.tabBarItem.selectedImage = "tab_icon_me".image
        
        
        let meNav1 = UINavigationController.init(rootViewController: meCtr1)
        
        self.viewControllers = [AICtrNav,meNav1]
        
        tabBar.tintColor = .k16Color
        tabBar.unselectedItemTintColor = UIColor.init(hex: 0xC0C4C9)
        
        // 设置文本颜色
        UITabBarItem.appearance().setTitleTextAttributes([.foregroundColor: UIColor.gray], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([.foregroundColor: UIColor.k16Color], for: .selected)
    }

}
