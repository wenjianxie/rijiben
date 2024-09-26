//
//  AgreementViewController.swift
//  RZRichTextView_Example
//
//  Created by macer on 2024/9/26.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit



// 创建协议页面的视图控制器
class AgreementViewController: BaseViewController {

    let contentLabel = UILabel()

    var content: String
    
    init(title: String, content: String) {
        self.content = content
        super.init(nibName: nil, bundle: nil)
        self.title = title
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white

        navigationItem.title = title
        
        contentLabel.text = content
        contentLabel.numberOfLines = 0

        view.addSubview(contentLabel)
        
        
        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(10)
            make.left.equalTo(10)
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}
