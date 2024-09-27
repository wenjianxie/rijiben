//
//  EditProfileViewController.swift
//  RZRichTextView_Example
//
//  Created by macer on 2024/9/26.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit

import UIKit

protocol EditProfileViewControllerDelegate:NSObjectProtocol {
    func editProfile()
}

class EditProfileViewController: BaseViewController {
    
    weak var delegate:EditProfileViewControllerDelegate?
    let nameTextField = UITextField()
    let signatureTextField = UITextField()
    let saveButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "修改资料"
        setupViews()
        loadCurrentProfile()
    }
    
    private func setupViews() {
        nameTextField.placeholder = "修改昵称"
        nameTextField.borderStyle = .roundedRect
        view.addSubview(nameTextField)
        
        signatureTextField.placeholder = "修改个性签名"
        signatureTextField.borderStyle = .roundedRect
        view.addSubview(signatureTextField)
        
        saveButton.setTitle("保存", for: .normal)
        saveButton.setTitleColor(.k3Color, for: .normal)
        saveButton.backgroundColor = .white
        saveButton.layer.borderWidth = 1
        saveButton.layer.borderColor = UIColor.kMask56Color.cgColor
        saveButton.addTarget(self, action: #selector(saveProfile), for: .touchUpInside)
        saveButton.layer.cornerRadius = 20
        saveButton.clipsToBounds = true
        view.addSubview(saveButton)
        
        // 布局
        nameTextField.frame = CGRect(x: 40, y: 100, width: view.frame.width - 80, height: 40)
        signatureTextField.frame = CGRect(x: 40, y: 160, width: view.frame.width - 80, height: 40)
        saveButton.frame = CGRect(x: 40, y: 220, width: view.frame.width - 80, height: 40)
        
        
    }
    
    @objc override func customBackAction() {
        
        delegate?.editProfile()
        self.navigationController?.popViewController(animated: true)
     
    }
    
    private func loadCurrentProfile() {
        // 从持久化存储加载昵称和个性签名
        nameTextField.text = UserDefaults.standard.string(forKey: "nickname")
        signatureTextField.text = UserDefaults.standard.string(forKey: "signature")
    }
    
    @objc private func saveProfile() {
        // 保存到持久化存储
        UserDefaults.standard.set(nameTextField.text, forKey: "nickname")
        UserDefaults.standard.set(signatureTextField.text, forKey: "signature")
        delegate?.editProfile()
        navigationController?.popViewController(animated: true)
    }
}

