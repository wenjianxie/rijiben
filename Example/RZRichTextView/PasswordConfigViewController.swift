//
//  PasswordConfigViewController.swift
//  Example
//
//  Created by jiaxin on 2019/6/28.
//  Copyright © 2019 jiaxin. All rights reserved.
//

import UIKit
import JXPatternLock

enum PasswordConfigType {
    case setup
    case modify
    case vertify
}

extension CALayer {
    func shakeBody() {
        let keyFrameAnimation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        keyFrameAnimation.values = [0, 16, -16, 8, -8 ,0]
        keyFrameAnimation.duration = 0.3
        keyFrameAnimation.repeatCount = 1
        add(keyFrameAnimation, forKey: "shake")
    }
}

class PasswordConfigViewController: ExampleViewController {
    
    var pushType:Int = 0
    private let type: PasswordConfigType
    private var pathView: PatternLockPathView!
    private var tipsLabel: UILabel!
    private var currentPassword: String = ""
    private var firstPassword: String = ""
    private var secondPassword: String = ""
    private var canModify: Bool = false
    private let maxErrorCount: Int = 5
    private var currentErrorCount: Int = 0

    init(config: PatternLockViewConfig, type: PasswordConfigType) {
        self.type = type
        super.init(config: config)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tipsLabel = UILabel()
        tipsLabel.textColor = .lightGray
        view.addSubview(tipsLabel)
        tipsLabel.translatesAutoresizingMaskIntoConstraints = false
        tipsLabel.bottomAnchor.constraint(equalTo: lockView.topAnchor, constant: -20).isActive = true
        tipsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true

        var pathConifg = LockConfig()
        pathConifg.gridSize = CGSize(width: 10, height: 10)
        pathConifg.matrix = Matrix(row: 3, column: 3)
        let tintColor = colorWithRGBA(r: 18, g: 143, b: 235, a: 1)
        pathConifg.initGridClosure = {(matrix) -> PatternLockGrid in
            let gridView = GridView()
            let outerStrokeLineWidthStatus = GridPropertyStatus<CGFloat>.init(normal: 1, connect: 1, error: 1)
            let outerStrokeColorStatus = GridPropertyStatus<UIColor>(normal: tintColor, connect: tintColor, error: UIColor.red)
            let outerFillColorStatus = GridPropertyStatus<UIColor>(normal: nil, connect: tintColor, error: UIColor.red)
            gridView.outerRoundConfig = RoundConfig(radius: 5, lineWidthStatus: outerStrokeLineWidthStatus, lineColorStatus: outerStrokeColorStatus, fillColorStatus: outerFillColorStatus)
            gridView.innerRoundConfig = RoundConfig.empty
            return gridView
        }

        let lineView = ConnectLineView()
        lineView.lineColorStatus = .init(normal: tintColor, error: .red)
        lineView.lineWidth = 1
        pathConifg.connectLine = lineView

        pathView = PatternLockPathView(config: pathConifg)
        view.addSubview(pathView)
        pathView.translatesAutoresizingMaskIntoConstraints = false
        pathView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        pathView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        pathView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        pathView.bottomAnchor.constraint(equalTo: tipsLabel.topAnchor, constant: -10).isActive = true

        switch type {
        case .setup:
            tipsLabel.text = "绘制解锁图案"
        case .modify:
            tipsLabel.text = "请输入原手势密码"
            pathView.isHidden = true
        case .vertify:
            tipsLabel.text = "请输入原手势密码"
            pathView.isHidden = true
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

    }

    //MARK: - Event
    @objc func didRestButtonClicked() {
        showNormalText("绘制解锁图案")
        currentPassword = ""
        firstPassword = ""
        secondPassword = ""
        pathView.reset()
        lockView.reset()
        self.navigationItem.rightBarButtonItem = nil
    }

    func showResetButtonIfNeeded() {
        guard type == .setup || type == .modify else {
            return
        }
        if !firstPassword.isEmpty {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "重设", style: .plain, target: self, action: #selector(didRestButtonClicked))
        }
    }

    func shouldShowErrorWithSavedAndCurrentPassword() -> Bool {
        if currentPassword == PasswordManager.currentPassword() {
            //当前密码与保存的密码相同，不需要显示error
            return false
        }else {
            return true
        }
    }

    func shouldShowErrorWithFirstAndSecondPassword() -> Bool {
        if firstPassword.isEmpty {
            //第一次密码还未配置，不需要显示error
            return false
        }else if firstPassword == currentPassword {
            //两次输入的密码相同，不需要显示error
            return false
        }else {
            return true
        }
    }

    func setupPassword() {
        if firstPassword.isEmpty {
            firstPassword = currentPassword
            showNormalText("再次绘制解锁图案")
        } else {
            secondPassword = currentPassword
            if firstPassword == secondPassword {
                PasswordManager.updatePassword(firstPassword)
                UserDefaults.standard.set(true, forKey: "isSecurityEnabled")
                let alert = UIAlertController(title: nil, message: "恭喜您！密码设置成功", preferredStyle: .alert)
                let confirm = UIAlertAction(title: "确定", style: .cancel){ (_) in
                    self.navigationController?.popToRootViewController(animated: true)
                }
                alert.addAction(confirm)
                present(alert, animated: true, completion: nil)
            } else {
                showResetButtonIfNeeded()
                showErrorText("与上次绘制不一致，请重新绘制")
                secondPassword = ""
            }
        }
    }

    func showErrorText(_ text: String) {
        tipsLabel.text = text
        tipsLabel.textColor = .red
        tipsLabel.layer.shakeBody()
    }

    func showNormalText(_ text: String) {
        tipsLabel.text = text
        tipsLabel.textColor = .lightGray
    }

    func showPasswordError() {
        currentErrorCount += 1
        if currentErrorCount == maxErrorCount {
            
            showErrorText("")
            // 从 UserDefaults 中获取密保问题和答案
            guard let savedQuestions = UserDefaults.standard.dictionary(forKey: "securityQuestions") as? [String: String] else {
                self.showErrorText("未设置密保问题")
                return
            }

            var questionIndex = 0
            let questions = Array(savedQuestions.keys)

            func askQuestion() {
                if questionIndex < questions.count {
                    let question = questions[questionIndex]
                    let alert = UIAlertController(title: "回答密保问题", message: question, preferredStyle: .alert)

                    alert.addTextField { textField in
                        textField.placeholder = "请输入答案"
                        textField.isSecureTextEntry = false
                    }

                    let confirm = UIAlertAction(title: "确定", style: .default) { _ in
                        if let answer = alert.textFields?.first?.text, answer == savedQuestions[question] {
                            print("答案正确,进入下一环节")
                            
                            if self.pushType == 0 {
                                let rootVc = TabBarViewController()
                                if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                                    appDelegate.window?.rootViewController = rootVc
                                    appDelegate.window?.makeKeyAndVisible()
                                }
                            } else {
                                self.navigationController?.popViewController(animated: true)
                            }
                            // 处理正确逻辑，可以直接结束
                        } else {
                            print("答案错误，检查是否为最后一个问题")

                            if questionIndex == questions.count - 1 {
                                // 如果是最后一个问题，直接处理所有问题均回答错误的逻辑
                                handleAllQuestionsWrong()
                            } else {
                                // 不是最后一个问题，继续下一个问题
                                // 提示用户答案错误
                                  let errorAlert = UIAlertController(title: "错误", message: "答案错误，请尝试下一个问题。", preferredStyle: .alert)
                                  errorAlert.addAction(UIAlertAction(title: "确定", style: .default, handler: { _ in
                                      // 不是最后一个问题，继续下一个问题
                                      questionIndex += 1
                                      askQuestion()
                                  }))
                                  self.present(errorAlert, animated: true, completion: nil)
                            }
                          
                        }
                    }

                    alert.addAction(confirm)
                    present(alert, animated: true, completion: nil)
                } else {
                    // 所有问题都已问完，提示用户
                    handleAllQuestionsWrong()
                }
            }

            func handleAllQuestionsWrong() {
                let alert = UIAlertController(title: nil, message: "所有密保问题均回答错误，为保护隐私执行销毁模式", preferredStyle: .alert)
                let confirm = UIAlertAction(title: "确定", style: .cancel) { (_) in
                
                    UserManager.share.clearUser()

                    if self.pushType == 0 {
                        let rootVc = TabBarViewController()
                        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                            appDelegate.window?.rootViewController = rootVc
                            appDelegate.window?.makeKeyAndVisible()
                        }
                    } else {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
                alert.addAction(confirm)
                present(alert, animated: true, completion: nil)
            }

            askQuestion() // 开始询问问题
        } else {
            if currentErrorCount < maxErrorCount {
                showErrorText("密码错误，还可以输入 \(maxErrorCount - currentErrorCount) 次")
            }
        }
    }


    func shouldHandlePathView() -> Bool {
        if firstPassword.isEmpty {
            //第一次的密码未输入，才需要更新path
            if type == .setup {
                return true
            }else if type == .modify {
                if canModify {
                    //修改时，第一次验证成功之后才需要更新path
                    return true
                }
            }
        }
        return false
    }

    //MARK: - PatternLockViewDelegate
    override func lockView(_ lockView: PatternLockView, didConnectedGrid grid: PatternLockGrid) {
        currentPassword += grid.identifier
        if shouldHandlePathView() {
            pathView.addGrid(at: grid.matrix)
        }
    }

    override func lockViewDidConnectCompleted(_ lockView: PatternLockView) {
        if currentPassword.count < 4 {
            showErrorText("至少链接4个点，请重新输入")
            if shouldHandlePathView() {
                pathView.reset()
            }
            showResetButtonIfNeeded()
        } else {
            switch type {
            case .setup:
                setupPassword()
            case .modify:
                if canModify {
                    setupPassword()
                } else {
                    if currentPassword == PasswordManager.currentPassword() {
                        pathView.isHidden = false
                        showNormalText("绘制解锁图案")
                        canModify = true
                    } else {
                        showPasswordError()
                    }
                }
            case .vertify:
                if currentPassword == PasswordManager.currentPassword() {
                    
                    let alert = UIAlertController(title: nil, message: "验证成功，进入主页面", preferredStyle: .alert)
                    
                    let confirm = UIAlertAction(title: "确定", style: .cancel){ (_) in
                        
                        if self.pushType == 0 {
                            //从appdelegate 进来的
                            let rootVc = TabBarViewController()
                            
                            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                                appDelegate.window?.rootViewController = rootVc
                                appDelegate.window?.makeKeyAndVisible()
                            }
                            
                        }else {
                            UserDefaults.standard.set(false, forKey: "isSecurityEnabled")
                            self.navigationController?.popViewController(animated: true)
                        }
                       
                    }
                    alert.addAction(confirm)
                    present(alert, animated: true, completion: nil)
                } else {
                    showPasswordError()
                }
            }
        }
        print(currentPassword)
        currentPassword = ""
    }

    override func lockViewShouldShowErrorBeforeConnectCompleted(_ lockView: PatternLockView) -> Bool {
        if type == .vertify {
            return shouldShowErrorWithSavedAndCurrentPassword()
        }else if type == .setup {
            return shouldShowErrorWithFirstAndSecondPassword()
        }else if type == .modify {
            if !canModify {
                return shouldShowErrorWithSavedAndCurrentPassword()
            }else {
                return shouldShowErrorWithFirstAndSecondPassword()
            }
        }
        return false
    }
}

