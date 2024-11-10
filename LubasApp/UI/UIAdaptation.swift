//
//  dddd.swift
//  LubasApp
//
//  Created by Pidong Ling on 2024/10/15.
//

import Foundation
import UIKit

// 屏幕适配

private let designedScreenW = 375.00


let kNavigationBarHeight  = 44.0

let kScreenWidth  = CGRectGetWidth(UIScreen.main.bounds)
let kScreenHeight = CGRectGetHeight(UIScreen.main.bounds)

/// 获取状态栏高度
func getStatusBarHeight() -> CGFloat {
    if #available(iOS 13, *) {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            
            return windowScene.statusBarManager?.statusBarFrame.height ?? 20.0
        }
    }else{
        return UIApplication.shared.statusBarFrame.size.height
    }
    return 20.0
}

/// 获取 底部安全区域的 高度
func getBottomSaveAreaHeight() -> CGFloat{
    // 注意：竖屏34，横屏21
    let h = getStatusBarHeight() > 20.0 ? 34.0 : 0
    return h
}

func getTabBarViewHeight() -> CGFloat{
    return getBottomSaveAreaHeight() + 49.0
}


extension Double{
    
    /// 间距、长度 适配
    public var xo: Double{
        return Double(lround( Double(self * (min(kScreenWidth, kScreenHeight) / designedScreenW))))
    }
    
    /// 字体
    func font(_ weight: UIFont.Weight) -> UIFont{
        return UIFont.systemFont(ofSize: self, weight: weight)
    }
    
}
