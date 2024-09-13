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
    
    
    let leftTimeLab = UILabel()
    
    let rightLineView = UIView()
    
    let rightPointView = UIView()
    
    
    var model:Article? {
        didSet {
            guard let model = model else {
                return
            }
            titleLab.text = model.title
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
        contentView.addSubview(titleLab)
        contentView.addSubview(coverImageView)
        contentView.addSubview(timeLab)
        
        
        contentView.addSubview(leftTimeLab)
        leftTimeLab.text = "2024.9"
        
        leftTimeLab.snp.makeConstraints { make in
            make.left.equalTo(2)
            make.top.equalTo(0)
        }
        
        coverImageView.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-12)
//            make.centerY.equalToSuperview()
            make.top.equalTo(80)
            make.bottom.equalToSuperview().offset(-6)
            make.width.equalTo(80)
        }
        
        coverImageView.backgroundColor = .red
        
        titleLab.numberOfLines = 0
        leftTimeLab.font = UIFont.systemFont(ofSize: 12)
        titleLab.snp.makeConstraints { make in
            make.left.equalTo(80)
            make.top.equalTo(2)
            make.right.equalToSuperview().offset(-90)
        }
        
        timeLab.font = UIFont.systemFont(ofSize: 14)
        timeLab.snp.makeConstraints { make in
            make.left.equalTo(80)
            make.bottom.equalToSuperview().offset(-4)
        }
        
        timeLab.text = "09:32"
        
        contentView.addSubview(rightLineView)
        rightLineView.snp.makeConstraints { make in
            make.left.equalTo(leftTimeLab.snp.right).offset(10)
            make.top.equalTo(0)
            make.bottom.equalToSuperview()
            make.width.equalTo(1)
        }
        
        rightLineView.backgroundColor = .gray
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }

}
