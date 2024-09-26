//
//  ProfileTableViewCell.swift
//  RZRichTextView_Example
//
//  Created by macer on 2024/9/26.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
import LLScreenLock

class TableViewCell: UITableViewCell {


    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.backgroundColor = UIColor.white
        configUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configUI() {
        
    }
}


class ProfileTableViewCell: TableViewCell {
    
  
    let iconView = UIImageView()
   
    let titleLable = UILabel()
    
    let arrowImgeView = UIButton()
    
    let myswitch = UISwitch()
    
    override func configUI() {
        super.configUI()
        
        iconView.adhere(toSuperView: contentView).layout {make in
            make.left.equalTo(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }
        
        titleLable.adhere(toSuperView: contentView).layout {make in
            make.left.equalTo(24)
            make.centerY.equalToSuperview()
        }.config { lab in
            lab.numberOfLines = 1
            lab.font = 14.font
            lab.textColor = .k92Color
        }
        
        arrowImgeView.adhere(toSuperView: contentView).layout {make in
            
            make.right.equalToSuperview().offset(-24)
            make.width.height.equalTo(20)
            make.centerY.equalTo(titleLable)
        }.config { lv in
            lv.setImage("arrow_icon".image, for: .normal)
        }
        myswitch.addTarget(self, action: #selector(switchValueChanged(_:)), for: .valueChanged)
        myswitch.adhere(toSuperView: contentView).layout { make in
            make.right.equalToSuperview().offset(-24)
            make.centerY.equalTo(titleLable)
            make.width.height.equalTo(40)
                                 
        }
        myswitch.isHidden = true
    }
    
    @objc func switchValueChanged(_ sender: UISwitch) {
        
        /*
         
         let vc = SecurityQuestionsViewController()
         vc.title = "设置密保问题"
         vc.hidesBottomBarWhenPushed = true
         navigationController?.pushViewController(vc, animated: true)
         **/
        
        if sender.isOn {
            // 开关打开时的操作
            print("Switch is ON")
//            LLScreenLock.lock(.new, type: .gesture, target: ez.topMostVC?.navigationController) {
//
//            }
            
            print("代码解锁了")
            
            let vc = SecurityQuestionsViewController()
            vc.title = "设置密保问题"
            vc.hidesBottomBarWhenPushed = true
            ez.topMostVC?.navigationController?.pushViewController(vc, animated: true)
           
        } else {
            // 开关关闭时的操作
            print("Switch is OFF")
        }
    }

}
