//
//  SecurityQuestionsViewController.swift
//  RZRichTextView_Example
//
//  Created by macer on 2024/9/26.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
import UIKit

import UIKit
import LLScreenLock

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
        "你最喜欢的节日是哪个？"
    ]
    
    var selectedQuestions: [(question: String, answer: String)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        // 随机选择3个问题
        let shuffledQuestions = questions.shuffled()
        for i in 0..<3 {
            selectedQuestions.append((shuffledQuestions[i], ""))
        }
        
        setupUI()
    }
    
    func setupUI() {
        for (index, question) in selectedQuestions.enumerated() {
            let label = UILabel()
            label.text = question.question
            label.frame = CGRect(x: 20, y: 100 + index * 100, width: 300, height: 30)
            view.addSubview(label)
            
            let textField = UITextField(frame: CGRect(x: 20, y: 130 + index * 100, width: 300, height: 30))
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
        confirmButton.frame = CGRect(x: 20, y: 400, width: 100, height: 40)
        confirmButton.centerX = view.centerX
        confirmButton.layer.cornerRadius = 20
        confirmButton.addTarget(self, action: #selector(confirmAnswers), for: .touchUpInside)
        view.addSubview(confirmButton)
        
        
        // 添加手势识别器
         let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
         view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    @objc func answerChanged(_ textField: UITextField) {
        selectedQuestions[textField.tag].answer = textField.text ?? ""
    }
    
    @objc func confirmAnswers() {
        // 检查是否所有答案都填写
//        for question in selectedQuestions {
//            if question.answer.isEmpty {
//                let alert = UIAlertController(title: "提示", message: "请填写所有问题的答案", preferredStyle: .alert)
//                alert.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
//                present(alert, animated: true, completion: nil)
//                return
//            }
//        }
//        
//        // 持久化存储问题和答案
//        for question in selectedQuestions {
//            UserDefaults.standard.set(question.answer, forKey: question.question)
//        }
//        
//        // 返回或进行后续处理
//
        
        LLScreenLock.lock(.new, type: .gesture, target: ez.topMostVC?.navigationController) {
            
            print("锁屏结束了")
            print("锁屏结束了")
            self.dismiss(animated: true, completion: nil)
        }
    }

}
