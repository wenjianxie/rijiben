//
//  JournalCell.swift
//  RZRichTextView_Example
//
//  Created by macer on 2024/9/10.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit

class JournalCell: UITableViewCell {

    let titleLab = UILabel()
    
    let coverImageView = UIImageView()
    
    let timeLab = UILabel()
    
    
    var leftWeekLab = UILabel()
    
    let leftTimeLab = UILabel()
    
    let leftLineView = UIView()
    
    let leftPointView = UIView()
    
    /// 容器
    let leftContainerView = UIView()
    
    var rightContainerView = UIView()
    
    var model:Article? {
        didSet {
            guard let model = model else {
                return
            }
            titleLab.text = model.title
            print(model.date.getDateDetails())
            
            let timeStr = model.date.getDateDetails()
            leftTimeLab.text = "\(timeStr.year).\(timeStr.month)"
            leftWeekLab.text = String("\(timeStr.day),\(timeStr.weekday)")
            timeLab.text = timeStr.hour
            let fileName =  model.src
            if fileName.count > 0 {
                // 拼接路径
                let fileURL = URL.documentsURL.appendingPathComponent(fileName)
                UIImage.asyncImageBy(fileURL.absoluteString) {  image in
                    self.coverImageView.image = image
                }
            }else {
                self.coverImageView.image = UIImage()
            }
         
            if model.src.count == 0 {
//                titleLab.snp.updateConstraints { make in
//                    make.right.equalToSuperview()
//                }
            }
        }
    }
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        
        contentView.backgroundColor = UIColor.init(hex: 0xeef2f5)
        
        leftContainerView.backgroundColor = UIColor.init(hex: 0xeef2f5)
    
        leftContainerView.adhere(toSuperView: contentView).layout { make in
            make.left.equalToSuperview()
            make.height.equalToSuperview()
            make.width.equalTo(100)
        }
        
        rightContainerView.adhere(toSuperView: contentView).layout { make in
            make.top.equalTo(4)
            make.left.equalTo(leftContainerView.snp.right)
            make.right.equalToSuperview().offset(-10)
            make.bottom.equalToSuperview().offset(-4)
        }.config { lv in
            lv.backgroundColor = .white
            lv.layer.cornerRadius = 4
            lv.clipsToBounds = true
        }
        
        coverImageView.adhere(toSuperView: rightContainerView).layout { make in
            make.right.equalToSuperview().offset(-12)
            make.top.equalTo(6)
            make.bottom.equalToSuperview().offset(-6)
            make.width.equalTo(80)
            
        }.config { lv in
            lv.backgroundColor = .clear
            lv.layer.cornerRadius = 4
            lv.clipsToBounds = true
            lv.contentMode = .scaleAspectFit
        }
        
        timeLab.adhere(toSuperView: rightContainerView).layout { make in
            make.left.equalTo(6)
            make.bottom.equalToSuperview().offset(-4)
        }.config { lb in
            lb.numberOfLines = 0
            lb.font = UIFont.systemFont(ofSize: 12)
            lb.text = "09:32"
            lb.textColor = .k72Color
        }
        
        titleLab.adhere(toSuperView: rightContainerView).layout { make in
            make.left.equalTo(6)
            make.top.equalTo(6)
            make.right.equalTo(coverImageView.snp.left).offset(-4)
            make.bottom.equalTo(timeLab.snp.top)
        }.config { lb in
            lb.numberOfLines = 0
            lb.font = UIFont.systemFont(ofSize: 12)
        }
        
        leftLineView.adhere(toSuperView: leftContainerView).layout { make in
            make.left.equalTo(80)
            make.top.equalTo(0)
            make.bottom.equalToSuperview()
            make.width.equalTo(1)
        }.config { lv in
            lv.backgroundColor = .gray
        }
        
        
        leftPointView.adhere(toSuperView: leftContainerView).layout { make in
            make.centerX.equalTo(leftLineView)
            make.width.height.equalTo(15)
            make.top.equalTo(16)
        }.config { lv in
            lv.layer.cornerRadius = 8
            lv.layer.masksToBounds = true
            lv.backgroundColor = UIColor.init(hex: 0xeef2f5)
            lv.layer.borderWidth = 0.5
            lv.layer.borderColor = UIColor.k66Color.cgColor
        }
        
        leftTimeLab.adhere(toSuperView: leftContainerView).layout { make in
            make.left.equalTo(10)
            make.top.equalTo(4)
        }.config { lb in
            lb.text = "2024.9"
            lb.font = UIFont.systemFont(ofSize: 12)
        }
        
        leftWeekLab.adhere(toSuperView: leftContainerView).layout { make in
            make.left.equalTo(10)
            make.top.equalTo(leftTimeLab.snp.bottom).offset(4)
        }.config { lb in
            lb.font = 12.font
        }
        
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }

}
