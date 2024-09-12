//
//  RealmManager.swift
//  RZRichTextView_Example
//
//  Created by macer on 2024/9/9.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

//import RealmSwift

import RealmSwift
import UIKit
import Photos


class RealmManager {
    
    static let shared = RealmManager()
    private let realm = try! Realm()

    // 保存或更新文章
    
    // 保存或更新文章
    func saveObjct(obj:Object) {
   
        try! realm.write {
            realm.add(obj, update: .modified)
        }
    }
    
    // 根据 ID 查询文章
    func getArticle(by id: String) -> Article? {
        return realm.object(ofType: Article.self, forPrimaryKey: id)
    }
    
    // 查询所有文章
    func getAllArticles() -> Results<Article> {
        return realm.objects(Article.self).sorted(byKeyPath: "date", ascending: false)
    }
    
    // 删除文章
    func deleteArticle(by id: String) {
        if let article = getArticle(by: id) {
            try! realm.write {
                realm.delete(article)
            }
        }
    }
}

class Article: Object {
    @objc dynamic var id: String = UUID().uuidString    // 每篇文章唯一标识
    @objc dynamic var title: String = ""                // 文章标题
    @objc dynamic var data: Data?       // 首图URL
    @objc dynamic var src:String = ""
    @objc dynamic var bodyContent: String = ""          // 正文HTML内容
    @objc dynamic var date: Date = Date()               // 创建时间
    @objc dynamic var html:String = ""
    override static func primaryKey() -> String? {
        return "id"  // 设置主键
    }
}
