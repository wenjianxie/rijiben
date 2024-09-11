//
//  LabelLoadHtmlViewController.swift
//  RZRichTextView_Example
//
//  Created by rztime on 2023/8/3.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import RZRichTextView
import QuicklySwift
/// 大量富文本的时候，不建议使用，会卡顿，
class LabelLoadHtmlViewController: UIViewController {

    let tableView = UITableView.init(frame: .zero, style: .plain)

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.view.qbody([
            tableView.qmakeConstraints({ make in
                make.edges.equalToSuperview()
            })
        ])
        tableView.qnumberofRows { section in
            return 20
        }
        .qcell { tableView, indexPath in
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? TestCell ?? TestCell(style: .default, reuseIdentifier: "cell")
            cell.indexPath = indexPath
            cell.reload = { [weak self] indexPath in
                self?.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            cell.html = try? String.init(contentsOfFile: "/Users/rztime/Desktop/test.html")
            return cell
        }
    }
}
class TestCell: UITableViewCell {
    lazy var htmlLabel = UILabel().qpreferredMaxLayoutWidth(qscreenwidth - 20).qnumberOfLines(0)
    var reload: ((_ indexPath: IndexPath) -> Void)?
    var indexPath: IndexPath = .init(row: 0, section: 0)
    
    var html: String? {
        didSet {
            htmlLabel.html2AttributedString(html: html) { [weak self] in
                // label里的富文本图片改变，此时内容高度会有变化，可以按需更新高度
                if let self = self {
                    self.reload?(self.indexPath)
                }
            } preview: { tapActionId in
                if tapActionId.hasPrefix("<NSTextAttachment") {
                    print("预览附件:\(tapActionId)")// 通过富文本，获取所有的附件，然后预览
                } else {
                    print("处理链接:\(tapActionId)")
                }
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.qbody([
            htmlLabel.qmakeConstraints({ make in
                make.edges.equalToSuperview().inset(10)
            })
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
