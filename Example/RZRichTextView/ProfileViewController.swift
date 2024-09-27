//
//  ProfileViewController.swift
//  RZRichTextView_Example
//
//  Created by macer on 2024/9/25.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
import UIKit

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate {

    var privacyContent:String = ""
    var userAgreementContent:String = ""
    let tableView = UITableView()
    let headerView = ProfileHeaderView() // 使用新的 HeaderView
    
    let titleArr = ["资料修改","隐私协议","用户协议","好评鼓励","密码锁","分享给朋友"]
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        setupTableView()
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        
        tableView.reloadData()
    }

    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 60
        tableView.separatorStyle = .none
        tableView.register(ProfileTableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)
        
        // 添加到视图并设置约束
        self.view.qbody([
            tableView.qmakeConstraints { make in
                   make.top.equalTo(0)  // 顶部约束设置为 safeAreaLayoutGuide 的顶部
                   make.left.right.bottom.equalToSuperview()  // 左右和底部保持全屏
               }
        ])
        setupHeaderView()
        tableView.tableHeaderView = headerView
        
        
        // 隐私协议内容
         privacyContent = """
        隐私政策
        我们非常重视用户的隐私，并致力于保护用户的个人信息。在本隐私政策中，我们将向您说明我们如何收集、使用和保护您的信息。

        1. 信息收集
        我们可能会收集您在使用本应用时提供的个人信息，如姓名、电子邮件地址等。

        2. 信息使用
        我们将使用您的信息为您提供更好的服务，并改进我们的应用。

        3. 信息保护
        我们采取适当的技术和管理措施，以保护您的信息安全。

        4. 联系我们
        如果您对本隐私政策有任何疑问，请通过应用内反馈联系我们。
        """

        // 用户协议内容
        userAgreementContent = """
        用户协议
        欢迎使用我们的应用。请在使用前仔细阅读本用户协议。

        1. 服务说明
        本应用为用户提供日记记录功能，用户可以在其中记录个人日常。

        2. 用户责任
        用户需对自己在应用内的行为负责，不得发布违法信息。

        3. 知识产权
        本应用的所有内容均为我们或我们的合作伙伴所有，未经授权不得使用。

        4. 免责声明
        我们不对因使用本应用而导致的任何损失承担责任。

        5. 修改条款
        我们有权随时修改本协议条款，修改后将通过应用内通知用户。
        """

    }
    
    func setupHeaderView() {
        headerView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 200) // Initial height
    }
    
    // MARK: - UITableViewDelegate and UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as!ProfileTableViewCell
        cell.titleLable.text = titleArr[indexPath.row]
        cell.selectionStyle = .none
        
        if indexPath.row == 4 {
            cell.myswitch.isHidden = false
            cell.arrowImgeView.isHidden = true
            let isSecurityEnabled = UserDefaults.standard.bool(forKey: "isSecurityEnabled")
            
            cell.myswitch.isOn = isSecurityEnabled
        }else {
            cell.myswitch.isHidden = true
            cell.arrowImgeView.isHidden = false
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 { // 假设 0 是资料修改
            let editProfileVC = EditProfileViewController()
            editProfileVC.title = "修改资料"
            editProfileVC.delegate = self
            editProfileVC.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(editProfileVC, animated: true)
        } else if indexPath.row == 1 { // 隐私协议
            let privacyVC = AgreementViewController(title: "隐私协议", content: privacyContent)
            navigationController?.pushViewController(privacyVC, animated: true)
        } else if indexPath.row == 2 { // 用户协议
            let userAgreementVC = AgreementViewController(title: "用户协议", content: userAgreementContent)
            userAgreementVC.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(userAgreementVC, animated: true)
        } else if indexPath.row == 3 { // 好评鼓励
            
            let appid = ""
            if let url = URL(string: "itms-apps://itunes.apple.com/app/\(appid)") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }else if indexPath.row == 4 {
     
            
            
            
        } else if indexPath.row == 5 { // 分享给朋友
            let textToShare = "我刚刚在这个应用上记录了一些有趣的事情，快来看看吧！" // 你可以自定义分享的内容
            let activityViewController = UIActivityViewController(activityItems: [textToShare], applicationActivities: nil)
            
            // 在 iPad 上需要指定源视图
            activityViewController.popoverPresentationController?.sourceView = self.view
            
            present(activityViewController, animated: true, completion: nil)
        }
    }
}

extension ProfileViewController:EditProfileViewControllerDelegate {
    func editProfile() {
        headerView.nameLab.text = UserDefaults.standard.string(forKey: "nickname")
        headerView.textLab.text = UserDefaults.standard.string(forKey: "signature")
    }
}

// 处理下拉放大
extension ProfileViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        if offsetY < 0 {
            var transform = CATransform3DTranslate(CATransform3DIdentity, 0, offsetY, 0)
            let scaleFactor = 1 + (-1 * offsetY / (headerView.height / 2))
            transform = CATransform3DScale(transform, scaleFactor, scaleFactor, 1)
            headerView.bgImageView.layer.transform = transform
        }
        else {
            headerView.bgImageView.layer.transform = CATransform3DIdentity
        }
    }
}


