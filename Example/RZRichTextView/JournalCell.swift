//
//  JournalCell.swift
//  RZRichTextView_Example
//
//  Created by macer on 2024/9/10.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit

class JournalCell: UITableViewCell {

    let lab = UILabel()
    
    let coverImageView = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        contentView.addSubview(lab)
        contentView.addSubview(coverImageView)
        
        lab.snp.makeConstraints { make in
            make.left.equalTo(12)
            make.centerY.equalToSuperview()
        }
        
        coverImageView.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-12)
//            make.centerY.equalToSuperview()
            make.top.equalTo(6)
            make.bottom.equalToSuperview().offset(-6)
            make.width.equalTo(160)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }

}
