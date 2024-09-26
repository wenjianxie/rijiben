//
//  ProfileHeaderView.swift
//  RZRichTextView_Example
//
//  Created by macer on 2024/9/26.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit

class ProfileHeaderView: UIView,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let profileImageView = UIImageView()
    
    let bgImageView = UIImageView()
    
    let nameLab = UILabel()
    
    let textLab = UILabel()
    
    
    var tempTag:Int = 0
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        profileImageView.image = UIImage(named: "user_icon") 
        bgImageView.image = UIImage(named: "header_defult.jpg", in: .main, with: nil)

       
        addSubview(bgImageView)
        addSubview(profileImageView)
        bgImageView.snp.makeConstraints { make in
            make.top.left.right.bottom.equalToSuperview()
        }
        
        bgImageView.isUserInteractionEnabled = true
        bgImageView.tag = 1001
        profileImageView.snp.makeConstraints { make in
            make.top.equalTo(30)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(80)
        }
        profileImageView.tag = 1002
        profileImageView.backgroundColor = .white
        profileImageView.clipsToBounds = true
        profileImageView.isUserInteractionEnabled = true
        profileImageView.layer.cornerRadius = 40 // 圆形头像
           
        addProfileImageTapGesture(target: self, action: #selector(changeProfileImage))
        
        
        nameLab.adhere(toSuperView: self).layout { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(profileImageView.snp.bottom).offset(10)
        }.config { lb in
            lb.font = 16.font
            lb.textColor = .white
            lb.text = "我是昵称"
            
            lb.layer.shadowColor = UIColor.black.cgColor
            lb.layer.shadowOpacity = 0.5
            lb.layer.shadowOffset = CGSize(width: 1, height: 1)
            lb.layer.shadowRadius = 2
        }
        
        
        textLab.adhere(toSuperView: self).layout { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(nameLab.snp.bottom).offset(20)
        }.config { lb in
            lb.font = 14.font
            lb.numberOfLines = 2
            lb.textColor = .white
            lb.text = "我是个性签名"
            lb.layer.shadowColor = UIColor.black.cgColor
            lb.layer.shadowOpacity = 0.5
            lb.layer.shadowOffset = CGSize(width: 1, height: 1)
            lb.layer.shadowRadius = 2
        }
        
        
        nameLab.text = UserDefaults.standard.string(forKey: "nickname")
        textLab.text = UserDefaults.standard.string(forKey: "signature")
        
        
        loadProfileImage() // 加载头像和背景图片
    }
    
 
    func addProfileImageTapGesture(target: Any, action: Selector) {
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: target, action: action))
        
        bgImageView.addGestureRecognizer(UITapGestureRecognizer(target: target, action: action))
    }
    
    // 保存图片到文档目录
    private func saveImage(image: UIImage, key: String) {
        guard let data = image.jpegData(compressionQuality: 1) else { return }
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let filePath = documentsURL.appendingPathComponent("\(key).jpg")

        do {
            try data.write(to: filePath)
            UserDefaults.standard.set(filePath.path, forKey: key) // 保存路径到 UserDefaults
        } catch {
            print("Error saving image: \(error)")
        }
    }
    
    // 在初始化时加载头像
    private func loadProfileImage() {
        if let path = UserDefaults.standard.string(forKey: "profileImagePath"),
           let image = UIImage(contentsOfFile: path) {
            profileImageView.image = image
        }
        
        if let bgPath = UserDefaults.standard.string(forKey: "bgImagePath"),
           let bgImage = UIImage(contentsOfFile: bgPath) {
            bgImageView.image = bgImage
        }
    }
    
    // MARK: - Change Profile Image
    
    @objc func changeProfileImage(tap:UITapGestureRecognizer) {
        
        tempTag = tap.view?.tag ?? 0
        let alert = UIAlertController(title: "更换头像", message: "选择头像来源", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "相机", style: .default, handler: { _ in
            self.presentImagePicker(sourceType: .camera)
        }))
        alert.addAction(UIAlertAction(title: "相册", style: .default, handler: { _ in
            self.presentImagePicker(sourceType: .photoLibrary)
        }))
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        
        ez.topMostVC?.present(alert, animated: true, completion: nil)
    }
    
    func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
        guard UIImagePickerController.isSourceTypeAvailable(sourceType) else { return }
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        ez.topMostVC?.present(imagePicker, animated: true, completion: nil)
    }
    
       // MARK: - Image Picker Delegate
       
       func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
           if let image = info[.originalImage] as? UIImage {
               
               if tempTag == 1001 {
                   bgImageView.image = image
                   saveImage(image: image, key: "bgImagePath") // 保存背景图片
                   
               }else {
                   profileImageView.image = image
                   saveImage(image: image, key: "profileImagePath") // 保存头像
               }
           }
           ez.topMostVC?.dismiss(animated: true, completion: nil)
       }
       
       func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
           ez.topMostVC?.dismiss(animated: true, completion: nil)
       }
}
