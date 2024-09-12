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
import Kingfisher
class ViewController: UIViewController {
    
    var list:[Article] = []
    let tableView = UITableView.init(frame: .zero, style: .plain)
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
   
        
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
        
        
       
        
        tableView.register(JournalCell.self, forCellReuseIdentifier: "cell")
        tableView.qnumberofRows { section in
            return self.list.count
        }
        .qheightForRow { indexPath in
            return 120
        }
        .qcell { tableView, indexPath in
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as!JournalCell
            
            
            let item = self.list[indexPath.row]
            cell.textLabel?.text = item.title

            UIImage.asyncImageBy(item.src) {  image in
                cell.coverImageView.image = image
            }
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
       
       if list.count > 0 {
           let html = list[0].html
           vc.textView.html2Attributedstring(html: html)
       }
    
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        list.removeAll()
        let result  = RealmManager.shared.getAllArticles()
          
          for(index,obj) in result.enumerated() {
              list.append(obj)
          }
        
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

