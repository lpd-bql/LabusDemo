//
//  Utilities.swift
//  LubasApp
//
//  Created by Pidong Ling on 2024/10/15.
//

import UIKit

// 工具方法

struct AppUtils{
    
    /// 当前app版本号
    static func appCurrentVersion() -> String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
    }



    /*
     延迟执行
      - delayTime: 延迟时间
      - qosClass: 使用的全局Q0S类(默认为nil, 表示主线程)
      - closure: 延迟运行的代码
     */
    static func delayExecute(by delayTime: TimeInterval, qosClass: DispatchQoS.QoSClass? = nil,
                      closure: @escaping () -> Void) {
        
        let dispatchQueue = qosClass != nil ? DispatchQueue.global(qos: qosClass!) : .main
        dispatchQueue.asyncAfter(deadline: DispatchTime.now() + delayTime, execute: closure)
    }

}

struct DeviceUtils{
    
    static func is_iPad() -> (Bool) {
        if (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad) {
            return true;
        }
        return false;
    }

    /// 跳转 系统设置
    static func toSystemSettings()  {
        guard let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) else {
            return
        }

        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    
}

