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

class ViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    var list: [Article] = []
    let tableView = UITableView.init(frame: .zero, style: .plain)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        // 设置表格视图的代理和数据源
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.separatorStyle = .none
        tableView.register(JournalCell.self, forCellReuseIdentifier: "cell")
        
        // 添加到视图并设置约束
        self.view.qbody([
            tableView.qmakeConstraints { make in
                make.edges.equalToSuperview()
            }
        ])
        
        view.backgroundColor = UIColor.init(hex: 0xeef2f5)
        tableView.backgroundColor = UIColor.init(hex: 0xeef2f5)
        
        // 添加导航栏按钮
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
        
        // 更新数据源
        list.removeAll()
        let result = RealmManager.shared.getAllArticles()
        for obj in result {
            list.append(obj)
        }
        
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! JournalCell
        let item = list[indexPath.row]
        cell.model = item
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        let vc = NormalViewController()
        if self.list.count > 0 {
            let html = self.list[indexPath.row].html
            vc.textView.html2Attributedstring(html: html)
            vc.article = self.list[indexPath.row]
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
