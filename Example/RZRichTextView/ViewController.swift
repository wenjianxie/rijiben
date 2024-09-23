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
class ViewController: BaseViewController {
    
    var list:[Article] = []
    let tableView = UITableView.init(frame: .zero, style: .plain)
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if #available(iOS 16.0, *) {
            customBackButton.isHidden = true
        } else {
            // Fallback on earlier versions
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
        
        
       
        tableView.separatorStyle = .none
        tableView.register(JournalCell.self, forCellReuseIdentifier: "cell")
        tableView.qnumberofRows { section in
            return self.list.count
        }
        

        
        .qheightForRow { indexPath in
            return 80
        }
        .qcell { tableView, indexPath in
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as!JournalCell
            
            
            let item = self.list[indexPath.row]
          
            cell.model = item
            
            return cell
        }
        
        .qdidSelectRow { tableView, indexPath in
            tableView.deselectRow(at: indexPath, animated: false)
            
            let vc = NormalViewController()
            if self.list.count > 0 {
                let html = self.list[indexPath.row].html
                
                vc.textView.html2Attributedstring(html: html)
                vc.article = self.list[indexPath.row]
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        
        self.view.qbody([
            tableView.qmakeConstraints({ make in
                make.edges.equalToSuperview()
            })
        ])
        
        
        view.backgroundColor = UIColor.init(hex: 0xeef2f5)
        
        tableView.backgroundColor = UIColor.init(hex: 0xeef2f5)
        
        print("list == \(list)")
        print("list == \(list)")
        
        
    
        
        
        let btn = UIButton()
        btn.setImage("nav_add".image, for: .normal)
        btn.addTarget(self, action: #selector(clickAddBtn), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: btn)
    }
    
   
   @objc func clickAddBtn() {
        let vc = NormalViewController()
     
        self.navigationController?.pushViewController(vc, animated: true)
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

