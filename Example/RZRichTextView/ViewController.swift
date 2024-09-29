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
import BRPickerView
import MJRefresh
func colorWithRGBA(r: Int, g: Int, b: Int, a: CGFloat) -> UIColor {
    return UIColor(red: CGFloat(r)/255, green: CGFloat(g)/255, blue: CGFloat(b)/255, alpha: a)
}

class ViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    var list: [Article] = []
    let tableView = UITableView.init(frame: .zero, style: .plain)
    let emptyStateImageView = UIImageView()
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
                   make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)  // 顶部约束设置为 safeAreaLayoutGuide 的顶部
                   make.left.right.bottom.equalToSuperview()  // 左右和底部保持全屏
               }
        ])
        
        view.backgroundColor = UIColor.init(hex: 0xeef2f5)
        tableView.backgroundColor = UIColor.init(hex: 0xeef2f5)
        
        // 添加导航栏按钮
        let btn = UIButton()
        btn.setImage("nav_add".image, for: .normal)
        btn.addTarget(self, action: #selector(clickAddBtn), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: btn)
        
        
        
        // 创建筛选按钮
          let filterButton = UIButton(type: .system)
          filterButton.setTitle("筛选日记", for: .normal)
          filterButton.titleLabel?.font = 16.boldFont
          filterButton.setTitleColor(.k30Color, for: .normal)
          filterButton.addTarget(self, action: #selector(didTapFilterButton), for: .touchUpInside)
          
          // 设置为导航栏的中间视图
          self.navigationItem.titleView = filterButton
        
        //牛市来临？
        // Configure empty state image view
           emptyStateImageView.image = UIImage(named: "nodata") // 替换为你的图片名称
           emptyStateImageView.contentMode = .scaleAspectFit
           emptyStateImageView.isUserInteractionEnabled = true // 允许用户交互
        emptyStateImageView.isHidden = true
           // 添加点击手势
           let tapGesture = UITapGestureRecognizer(target: self, action: #selector(createNewDiary))
           emptyStateImageView.addGestureRecognizer(tapGesture)

           // 将图片视图添加到主视图中
           view.addSubview(emptyStateImageView)

        emptyStateImageView.snp.makeConstraints { make in
            make.center.equalToSuperview() // 居中显示
            make.width.height.equalTo(200) // 你可以根据需要调整大小
        }
//        emptyStateImageView.backgroundColor = .random
        
        loadDiaryData()
        
//        tableView.isHidden = true
    }
    
    @objc func createNewDiary() {
        let vc = NormalViewController() // 创建新的日记界面的控制器
        self.navigationController?.pushViewController(vc, animated: true)
    }

    
    func refreshData() {
        // 模拟网络请求或数据刷新
        DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
            // 假设这里是网络请求完成后的数据更新
            DispatchQueue.main.async {
                       // 获取 Realm 数据并转换为 Swift 数组
                
                self.list.removeAll()
               let result = RealmManager.shared.getAllArticles()
               self.list = Array(result) // 将 Results<Article> 转换为 [Article]

                if self.list.count > 0 {
                    self.emptyStateImageView.isHidden = true
                }else {
                    self.emptyStateImageView.isHidden = false
                }
               self.tableView.reloadData()

               // 结束刷新
               self.tableView.mj_header?.endRefreshing()
           }
        }
    }

    func setupPullToRefresh() {
        // 使用 MJRefreshNormalHeader 设置下拉刷新
        let header = MJRefreshNormalHeader { [weak self] in
            // 调用刷新数据的方法
            self?.refreshData()
        }
        
        // 将下拉刷新头部赋值给 tableView 的 mj_header
        tableView.mj_header = header
        
        tableView.mj_header?.beginRefreshing()
    }

    @objc func clickAddBtn() {
        let vc = NormalViewController()
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }

    func loadDiaryData() {
        // 从 Realm 中获取所有日记
        let allArticles = RealmManager.shared.getAllArticles()

        // 检查是否为空
        if allArticles.isEmpty {
            // 插入一条默认的介绍性日记
            addDefaultIntroductionForNewUsers()
        } else {
            // 正常加载数据
            setupPullToRefresh()
        }
    }

    // 插入默认的介绍性数据
    func addDefaultIntroductionForNewUsers() {
        let introArticle = Article()
        introArticle.title = "欢迎使用日记应用"
        introArticle.bodyContent = """
        亲爱的用户，欢迎来到我们的日记应用！这里你可以记录生活中的点滴、心情和想法。
        现在就开始吧，点击右上角的按钮添加你的第一篇日记！
        """
        introArticle.date = Date() // 设置当前日期为默认数据的日期

        // 保存到数据库
        RealmManager.shared.saveObjct(obj: introArticle)

        // 将这条数据显示出来
        list = [introArticle]
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
    
// MARK: - 删除功能
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // 1. 从数据源中移除
            let articleToDelete = list[indexPath.row]
            list.remove(at: indexPath.row)
            
            // 2. 从数据库中删除 (例如，Realm)
            RealmManager.shared.deleteArticle(articleToDelete)
            
            // 3. 更新表格视图
            tableView.deleteRows(at: [indexPath], with: .automatic)
   
              // 检查是否为空
              if list.isEmpty {
                  // 显示 emptyStateImageView
                  emptyStateImageView.isHidden = false
                  // 插入一条默认的介绍性日记
//                  addDefaultIntroductionForNewUsers()
                  
                  view.bringSubviewToFront(emptyStateImageView)
              } else {
                  // 隐藏 emptyStateImageView
                  emptyStateImageView.isHidden = true
                  // 正常加载数据
              }
        }
    }
    
    @objc func didTapFilterButton() {
       
        let datePickView = BRDatePickerView()
        datePickView.title = "选择年月日"
        datePickView.show()
        datePickView.pickerMode = .YM
        datePickView.resultBlock = { (selectDate,value) in
            print(value)
            print(selectDate)
            print(selectDate?.description)
            
            if let date = selectDate {
                self.filterDiaryByMonth(selectedDate: date)
            }
           
        }
    }
    
    
    func filterDiaryByMonth(selectedDate: Date) {
        // 获取日历实例
        let calendar = Calendar.current
        
        // 获取选中日期的年份和月份
        let selectedYear = calendar.component(.year, from: selectedDate)
        let selectedMonth = calendar.component(.month, from: selectedDate)

        // 过滤出与 selectedDate 同一个月的日记
        let filteredResults = RealmManager.shared.getAllArticles().filter { article in
            let articleDate = article.date

            // 获取日记的年份和月份
            let articleYear = calendar.component(.year, from: articleDate)
            let articleMonth = calendar.component(.month, from: articleDate)

            // 比较年份和月份
            return articleYear == selectedYear && articleMonth == selectedMonth
        }
        
        var tempList: [Article] = []
        for obj in filteredResults {
            tempList.append(obj)
        }

        // 更新列表
        self.list = tempList
        self.tableView.reloadData()
    }

    
 
}




extension ViewController:NormalViewControllerDelegate {
    func releaseArticle() {
        loadDiaryData()
    }
}
