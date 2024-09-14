//
//  URL+Extension.swift
//  camera_magic
//
//  Created by macer on 2024/3/13.
//

import Foundation

public extension URL {
    /// Documents目录Url
    static var documentsURL: URL {
        return try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
    }
    
    /// Caches目录Url
    static var cachesURL: URL {
        return try! FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
    }
    
    /// Library目录Url
    static var libraryURL: URL {
        return try! FileManager.default.url(for: .libraryDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
    }
    
    /// tmp目录Url
    static var tmpURL: URL {
        return URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
    }
}
