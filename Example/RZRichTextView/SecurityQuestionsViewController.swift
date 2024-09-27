//
//  SecurityQuestionsViewController.swift
//  RZRichTextView_Example
//
//  Created by macer on 2024/9/26.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
import JXPatternLock

class SecurityQuestionsViewController: BaseViewController {
    
    let questions = [
        "你第一次喜欢的人叫什么名字？",
        "你最喜欢的宠物叫什么名字？",
        "你的父母结婚纪念日是？",
        "你出生的城市是哪里？",
        "你的第一辆车是什么品牌？",
        "你最喜欢的颜色是什么？",
        "你小时候的梦想是什么？",
        "你最喜欢的食物是什么？",
        "你最喜欢的电影是什么？",
        "你最喜欢的节日是哪个？",
        "你最喜欢的运动是什么？",
        "你最难忘的旅行是哪里？",
        "你最喜欢的书籍是什么？",
        "你童年时的玩具是什么？"
    ]
    
    var textLab = UILabel()
    var selectedQuestions: [(question: String, answer: String)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        customBackButton.isHidden = false
        view.backgroundColor = .white
        
        // 随机选择3个问题
        selectRandomQuestions()
        
        initUI()
    }
    
    func initUI() {
        for (index, question) in selectedQuestions.enumerated() {
            let label = UILabel()
            label.text = question.question
            label.frame = CGRect(x: 20, y: 120 + index * 100, width: 300, height: 30)
            view.addSubview(label)
            label.tag = index + 100
            let textField = UITextField(frame: CGRect(x: 20, y: 150 + index * 100, width: 300, height: 30))
            textField.borderStyle = .roundedRect
            textField.placeholder = "请输入答案"
            textField.tag = index
            textField.addTarget(self, action: #selector(answerChanged(_:)), for: .editingChanged)
            view.addSubview(textField)
        }
        
 
        let confirmButton = UIButton(type: .system)
        confirmButton.setTitle("绘制锁屏图案", for: .normal)
        confirmButton.setTitleColor(.k3Color, for: .normal)
        confirmButton.layer.borderWidth = 1
        confirmButton.layer.borderColor = UIColor.k66Color.cgColor
        confirmButton.frame = CGRect(x: 20, y: 510, width: 160, height: 40)
        confirmButton.centerX = view.centerX
        confirmButton.layer.cornerRadius = 20
        confirmButton.addTarget(self, action: #selector(confirmAnswers), for: .touchUpInside)
        view.addSubview(confirmButton)

        textLab.adhere(toSuperView: view).layout { make in
            make.left.equalTo(20)
            make.right.equalToSuperview().offset(-20)
            make.top.equalTo(confirmButton.snp.bottom).offset(20)
        }.config { lb in
            
            lb.font = 14.font
            lb.textColor = .k66Color
            lb.numberOfLines = 0
            lb.text = "请注意，为保护您的隐私您的日记将保存在本地，而不会存储到任何服务器，，以确保您的数据安全。如果您在密保锁屏时连续输入错误超过5次，并且密保问题也未能正确回答，我们将清除您的日记内容。"
        }
        
        
        setupNavigationBar()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
//    @objc func refreshQuestions() {
//        selectRandomQuestions() // 重新选择问题
//        setupUI() // 更新 UI
//        
//       
//    }
    @objc func refreshQuestions() {
        selectedQuestions.removeAll() // 清空旧的问题
        let shuffledQuestions = questions.shuffled()
        for i in 0..<3 {
            selectedQuestions.append((shuffledQuestions[i], ""))
        }
        
        // 更新 UI 中的问题标签和文本框
        for (index, question) in selectedQuestions.enumerated() {
            if let label = view.viewWithTag(index + 100) as? UILabel {
                label.text = question.question
            }
            if let textField = view.viewWithTag(index) as? UITextField {
                textField.text = ""
            }
        }
    }

    func setupUI() {
        // 清除旧的 UI 元素
        view.subviews.forEach { $0.removeFromSuperview() }
        
        for (index, question) in selectedQuestions.enumerated() {
            let label = UILabel()
            label.text = question.question
            label.frame = CGRect(x: 20, y: 120 + index * 100, width: 300, height: 30)
            view.addSubview(label)
            
            let textField = UITextField(frame: CGRect(x: 20, y: 150 + index * 100, width: 300, height: 30))
            textField.borderStyle = .roundedRect
            textField.placeholder = "请输入答案"
            textField.tag = index
            textField.addTarget(self, action: #selector(answerChanged(_:)), for: .editingChanged)
            view.addSubview(textField)
        }
    }
    
    
    func setupNavigationBar() {
        let refreshButton = UIBarButtonItem(title: "刷新", style: .plain, target: self, action: #selector(refreshQuestions))
        navigationItem.rightBarButtonItem = refreshButton
    }
    
    func selectRandomQuestions() {
        let shuffledQuestions = questions.shuffled()
        selectedQuestions.removeAll()
        for i in 0..<3 {
            selectedQuestions.append((shuffledQuestions[i], ""))
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func answerChanged(_ textField: UITextField) {
        selectedQuestions[textField.tag].answer = textField.text ?? ""
    }
    
    @objc func confirmAnswers() {
        // 检查是否所有答案都填写
        for question in selectedQuestions {
            if question.answer.isEmpty {
                let alert = UIAlertController(title: "提示", message: "请填写所有问题的答案", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
                present(alert, animated: true, completion: nil)
                return
            }
        }
        
        // 持久化存储问题和答案
        let securityQuestionsDict = Dictionary(uniqueKeysWithValues: selectedQuestions.map { ($0.question, $0.answer) })
        UserDefaults.standard.set(securityQuestionsDict, forKey: "securityQuestions")

        let vc = PasswordConfigViewController(config: ArrowConfig(), type: .setup)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
