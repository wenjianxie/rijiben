//
//  NavigationController.swift
//  ChildrenNet
//
//  Created by Zack on 2020/4/23.
//  Copyright © 2020 ZK. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        viewController.hidesBottomBarWhenPushed = viewControllers.count > 0
        super.pushViewController(viewController, animated: animated)
    }
    override var childForStatusBarStyle: UIViewController? {
       return topViewController
     }
    
    override var childForStatusBarHidden: UIViewController? {
        return topViewController
    }
    
    
    

}
