//
//  Constant.swift
//  camera_magic
//
//  Created by macer on 2024/4/29.
//

import UIKit


public let kScreenW: CGFloat = UIScreen.main.bounds.width
public let kScreenH: CGFloat = UIScreen.main.bounds.height
//414
public let kScaleW: CGFloat = (UIScreen.main.bounds.width / 375.0)
public let kScaleH: CGFloat = (UIScreen.main.bounds.height / 812)

func getTopSafeAreaHeight() -> CGFloat {
    if let window = UIApplication.shared.windows.first {
       let topSafeAreaH = window.safeAreaInsets.top
        return topSafeAreaH
    }
    return 0
}

//360*598

public let ConvertioW:CGFloat = 0

//状态栏高度
let kStatusBarH:CGFloat = UIApplication.shared.statusBarFrame.height

//导航栏高度
let kNavigationHeight:CGFloat = (kStatusBarH + 44)

//tabbar高度
let kTabBarHeight = kStatusBarH == 44.0 ? 83.0 : 49.0

//底部的安全距离
let kBottomSafeAreaHeight = (kTabBarHeight - 49)

// 函数用于将设计稿中的宽度转换为实际显示宽度
func convertDesignWidthToActualWidth(_ designWidth: CGFloat) -> CGFloat {
    let designWidthReference: CGFloat = 375 // 设计稿中的宽度参考值
    let actualWidth = designWidth * UIScreen.main.bounds.width / designWidthReference
    return actualWidth
}

// 函数用于将设计稿中的高度转换为实际显示高度
func convertDesignHeightToActualHeight(_ designHeight: CGFloat) -> CGFloat {
    let designHeightReference: CGFloat = 812 // 设计稿中的高度参考值
    let actualHeight = designHeight * UIScreen.main.bounds.height / designHeightReference
    return actualHeight
}

// MARK: - 封装的日志输出功能（T表示不指定日志信息参数类型）
func KKLog<T>(_ message: T, file: String = #file, function: String = #function, line: Int = #line)
{
    #if DEBUG
        //获取文件名
        let fileName = (file as NSString).lastPathComponent
        print("💖fileName💖: \(fileName) -> 🌹line: \(line)🌹 -> func: \(function)")
        print(message)
    #endif
}


func Log<T>(message:T, file:String = #file, funcName:String = #function, lineNum:Int = #line) {

// #if DEBUG
     let fileName = (file as NSString).lastPathComponent;

      print("[文件名:\(fileName)]:[行数:\(lineNum)]-打印内容:\n\(message)");

// #endif
}

enum Placehold:String {
    
    case placehold159_240
    case placehold311_466
    
    var str: String {
       
        switch self {
            
        case .placehold159_240:
            return "placehold2_4"
        
        case .placehold311_466:
            return "placehold311_466"
        }
    }
}


// Constants.swift
struct UserDefaultsKeys {
    /// 记录是否首次制作
    static let hasUsedFreeTrial = "HasUsedFreeTrial"
    
    /// 用户隐私测协议
    static let userAgreed = "userAgreed"
    
    /// 记录相机
    static let photoPermissionKey = "photoPermission_key"
    static let cameraPermissionKey = "cameraPermissionKey_key"
    
    /// 记录是否看过广告
    static let lastAdDateKey = "lastAdDate_Key"
    
    /// 首页向上滑动的次数
    static let scrollUpCount_home = "scrollUpCount_key"
    /// 首页向下滑动的次数
    static let scrollDownCount_home = "scrollDownCount_key"
    
    /// 首页最后一次更新的时间
    static let lastUpdateDate_home = "lastUpdateDate_key"
    
    //更多页面左右
    static let scrollRightCount_video = "scrollRightCount_video_key"
    static let scrollLeftCount_video = "scrollLeftCount_video_key"
    static let scrollUpCount_video = "scrollUpCount_video_key"
    static let scrollDownCount_video = "scrollDownCount_video_key"
    
    //更多页面左右
    static let scrollRightCount_more = "scrollRightCount_more_key"
    static let scrollLeftCount_more = "scrollLeftCount_more_key"
    //更多页面上下
    static let scrollUpCount_more = "scrollUpCount_more_key"
    static let scrollDownCount_more = "scrollDownCount_more_key"
    
    ///特效页
    static let scrollRightCount_special = "scrollRightCount_special"
    static let scrollLeftCount_special = "scrollLeftCount_special"
    
    /// 启动次数
    static let launchCount = "launchCount"
    
    static let install_code = "install_code_key"
    
    static let ex_head = "ex_head_key"
    
    static let phead = "phead_key"
    
    static let uid = "uid_key"
    static let d_code = "d_code_key"
    static let freeCount = "freeCount_key"
    
    static let subscriptionExpirationKey = "subscriptionExpirationKey_key"
    
    static let idKey = "idKey_key"
}



enum NotificationManager:String {
    
    /// 使用商品成功
    case appGoodUseResultSuccess
    
    /// 收藏商品
    case collectGoodSuccess
    
    var value: Notification.Name {
       
        switch self {
            
        case .appGoodUseResultSuccess:
            return Notification.Name(rawValue: "_appGoodUseResultSuccess")
        case .collectGoodSuccess:
            return Notification.Name(rawValue: "_collectGoodSuccess")
        }
    }
}



extension Notification.Name {
    static let didFinishVIPPurchase = Notification.Name("didFinishVIPPurchase")
    
    static let didUserIdSuccess = Notification.Name("userIdSuccessNotificationKey")
}


