//
//  NormalViewController.swift
//  RZRichTextView_Example
//
//  Created by rztime on 2023/7/24.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import QuicklySwift
import RZRichTextView

class NormalViewController: UIViewController {
    let textView = RZRichTextView.init(frame: .init(x: 15, y: 0, width: qscreenwidth - 30, height: 300), viewModel: .shared())
        .qbackgroundColor(.qhex(0xf5f5f5))
        .qplaceholder("请输入正文")
        .qisHidden(false)

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.view.qbody([
            textView.qmakeConstraints({ make in
                make.left.right.equalToSuperview().inset(15)
                make.top.equalToSuperview().inset(100)
                make.bottom.equalToSuperview().inset(qbottomSafeHeight)
            }),
        ])
        
        NotificationCenter.default.qaddKeyboardObserver(target: self, object: nil) { [weak self] keyboardInfo in
            let y = keyboardInfo.frameEnd.height
            let ishidden = keyboardInfo.isHidden
            self?.textView.snp.updateConstraints({ make in
                make.bottom.equalToSuperview().inset(ishidden ? qbottomSafeHeight : y)
            })
        }
        
        let btn = UIButton.init(type: .custom)
            .qtitle("转html")
            .qtitleColor(.red)
            .qtap { [weak self] view in
                guard let self = self else { return }
                let attachments = self.textView.attachments
                if let _ = attachments.firstIndex(where: { info in
                    if case .complete(let success, _) = info.uploadStatus.value {
                        return !success
                    }
                    return true
                }) {
                    // 有未完成上传的
                    print("有未完成上传的")
                    return
                }
                let html = self.textView.code2html()
                
                
                let article = Article()
                article.title = textView.text
                
                // 取第一张首图
                for(index,obj) in attachments.enumerated() {
                    
                    if obj.type == .image {
                        
                        
                        if let asset = obj.asset {
                            RZRichTextViewModel.saveImageFromAsset(asset: asset) { url in
                                
                                article.data = url
                                
                                RealmManager.shared.saveObjct(obj: article)
                                
                                print("保存成功")
                            }
                        }
                    }
                }
                
                print("\(html)")
            }
        /// 上传完成时，可以点击
        textView.viewModel.uploadAttachmentsComplete.subscribe({ [weak btn] value in
            btn?.isEnabled = value
            btn?.alpha = value ? 1 : 0.3
        }, disposebag: btn)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: btn)
    }
}
