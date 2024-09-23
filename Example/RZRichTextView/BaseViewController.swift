//
//  BaseViewController.swift
//  RZRichTextView_Example
//
//  Created by macer on 2024/9/23.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {

    var customBackButton:UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        
        customBackButton = UIButton()
        customBackButton.setImage(UIImage(named: "nav_back_black"), for: .normal)
        
        customBackButton.addTarget(self, action: #selector(customBackAction), for: .touchUpInside)
        // 创建自定义的返回按钮
            let rightItem = UIBarButtonItem.init(customView: customBackButton)
            
            // 将自定义的返回按钮设置为左侧按钮
            navigationItem.leftBarButtonItem = rightItem
      
        // Do any additional setup after loading the view.
    }
    
    @objc func customBackAction() {
        self.navigationController?.popViewController(animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
