//
//  ViewController.swift
//  RZRichTextView
//
//  Created by rztime on 07/20/2023.
//  Copyright (c) 2023 rztime. All rights reserved.
//

import UIKit
import RZRichTextView
import QuicklySwift
import SwiftUI

class ViewController: UIViewController {
    
    var list:[Article] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
      let result  = RealmManager.shared.getAllArticles()
        
        for(index,obj) in result.enumerated() {
            list.append(obj)
        }
        
        QuicklyAuthorization.result(with: .photoLibrary) { result in
            if !result.granted {
                print("---- 请给相册权限")
            }
        }
        
//        let items: [(UIViewController.Type, String)] = [
//            (NormalViewController.self, "正常使用"),
//            (HTML2AttrViewController.self, "html转富文本"),
//            (CustomRichTextViewController.self, "自定义编辑器"),
//            (LabelLoadHtmlViewController.self, "UILabel加载html"),
//            (TestViewController.self, "测试"),
//            (TableViewViewController.self, "列表"),
//            (NormalTestViewController.self, "正常TextView")
//        ]
        
        
        let tableView = UITableView.init(frame: .zero, style: .plain)
        
        tableView.register(JournalCell.self, forCellReuseIdentifier: "cell")
        tableView.qnumberofRows { section in
            return self.list.count
        }
        .qheightForRow { indexPath in
            return 60
        }
        .qcell { tableView, indexPath in
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as!JournalCell
            
            
            let item = self.list[indexPath.row]
            
//            let item = items[qsafe: indexPath.row]
            cell.textLabel?.text = item.title
            
            
            if let data = item.data {
                if let image = UIImage(data: data) {
                    cell.coverImageView.image = image  // 设置 UIImageView 的图片
                }
            }
          
//            cell.detailTextLabel?.text = "\(String(describing: item?.0 ?? UIViewController.self))"
            return cell
        }
        .qdidSelectRow { tableView, indexPath in
            tableView.deselectRow(at: indexPath, animated: false)
//            if let item = items[qsafe: indexPath.row] {
//                let vc = item.0.init()
//                vc.title = item.1
//                qAppFrame.pushViewController(vc)
//            }
        }
        self.view.qbody([
            tableView.qmakeConstraints({ make in
                make.edges.equalToSuperview()
            })
        ])
        
        
       
        
        print("list == \(list)")
        print("list == \(list)")
        
        
        let addBtn = UIButton()
        addBtn.setTitle("addBtn", for: .normal)
        addBtn.addTarget(self, action: #selector(clickAddBtn), for: .touchUpInside)
        
        addBtn.backgroundColor = .red
        addBtn.frame = CGRect.init(x: 300, y: 600, width: 60, height: 60)
        view.addSubview(addBtn)
    }
    
    
   @objc func clickAddBtn() {
        let vc = NormalViewController()
        
        self.navigationController?.pushViewController(vc, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

