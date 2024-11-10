//
//  PDAlertView.swift
//  OpenBoy
//
//  Created by Mac on 2020/6/28.
//  Copyright © 2020 Mac. All rights reserved.
//

import Foundation
import SwiftMessages

//消息类型
enum ThemeType : String {
    case Info = "Info"
    case Success = "Success"
    case Warning = "Warning"
    case Error = "Error"
}


//位置类型
enum PositionType : String {
    case fromTop
    case fromCenter
    case fromBottom
}


class Alert{
    
    
    /// 简单提示
    static func toast(_ content: String){
        
        let view = MessageView.viewFromNib(layout: .cardView)
        view.id = "123"
        view.button?.isHidden = true

        view.layoutMarginAdditions = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        (view.backgroundView as? CornerRoundingView)?.cornerRadius = 16
        // 样式
        view.configureTheme(backgroundColor: .black, foregroundColor: .white)
        view.configureDropShadow()  // 阴影
        view.bodyLabel?.textAlignment = .center  // 文字居中
        let w = min( content.w(for: 15) , kScreenWidth - 40)
        view.configureBackgroundView(width: w)  // 宽度
        // view.backgroundHeight = 100
        
        // 内容
        view.configureContent(title: "", body: content)
        
        view.tapHandler = {_ in
            SwiftMessages.hide(id: view.id)
        }
    
        // 配置
        var cfg = SwiftMessages.Config()
        cfg.duration = .automatic        // 显示多久
        cfg.presentationStyle = .center  // 显示位置
        
        SwiftMessages.show(config: cfg, view: view)
    }

    /// 标题、文字提示
    static func toast(title: String, content: String, position: PositionType){
        
        let view = MessageView.viewFromNib(layout: .cardView)
        
        view.layoutMarginAdditions = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        (view.backgroundView as? CornerRoundingView)?.cornerRadius = 16
        
        view.configureTheme(backgroundColor: .black, foregroundColor: .white)
        view.configureDropShadow()
        view.id = "123"
        // 提示内容
        view.configureContent(title: title, body: content, iconText: "")
        
        view.button?.isHidden = true
        
        view.tapHandler = {_ in
            SwiftMessages.hide(id: view.id)
        }
        
        var cfg = SwiftMessages.Config()
        cfg.duration = .automatic

        switch position {
        case .fromTop:
            cfg.presentationStyle = .top
        case .fromBottom:
            cfg.presentationStyle = .bottom
        default:
            cfg.presentationStyle = .center
        }
        
        SwiftMessages.show(config: cfg, view: view)
    }
    
    /// 显示操作结果提示（自动消失）
    static func toastActionTip(title: String, content: String, resultType: ThemeType){

        let view = MessageView.viewFromNib(layout: .cardView)
        (view.backgroundView as? CornerRoundingView)?.cornerRadius = 16
        view.layoutMarginAdditions = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
//        view.configureDropShadow()
        view.configureContent(title: title, body: content )
        view.button?.isHidden = true
        
        view.tapHandler = {_ in
            SwiftMessages.hide(id: view.id)
        }
        
        switch resultType {
        case .Success:
            view.configureTheme(.success)
        case .Error:
            view.configureTheme(.error)
        case .Warning:
            view.configureTheme(.warning)
        default:
            view.configureTheme(.info)
        }
        
        var cfg = SwiftMessages.defaultConfig
        cfg.duration = .automatic
        cfg.presentationStyle = .top
        
        SwiftMessages.show(config: cfg, view: view)
    }
    
    
    // 类方法
    static func toast(title: String, content: String, action: @escaping ()->()){
        
        let view = MessageView.viewFromNib(layout: .cardView)
        
        view.configureTheme(backgroundColor: UIColor(hex: 0xF5F5F5), foregroundColor: .link)
        view.configureDropShadow()
        
        view.button?.setTitle("好的", for: .normal)
        view.button?.setTitleColor(.link, for: .normal)
        view.button?.titleLabel?.textAlignment = .center
        view.button?.backgroundColor = .white
//        view.button?.isHidden = true

        view.buttonTapHandler = { _ in
            SwiftMessages.hide()
            
            action()
        }
        // 提示框点击事件
        view.tapHandler = { _ in
            SwiftMessages.hide()
        }
        
//        view.titleLabel?.isHidden = true
        
        let iconText = ["🤔", "😳", "🙄", "😶"].randomElement()!
        view.configureContent(title: title, body: content, iconText: iconText)
        
        view.layoutMarginAdditions = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        (view.backgroundView as? CornerRoundingView)?.cornerRadius = 16
        
        SwiftMessages.show(view: view)
        
        // 接下来一段时间内 暂不显示提示
        SwiftMessages.pauseBetweenMessages = 2.0
    }
    
    
    static func show2(){
        // 配置
        var config = SwiftMessages.Config()
        config.presentationStyle = .center
        config.presentationContext = .window(windowLevel: .statusBar)
        config.duration = .seconds(seconds: 3)
        config.dimMode = .gray(interactive: true)
        config.interactiveHide = false
 
        config.preferredStatusBarStyle = .lightContent
//        config.keyboardTrackingView = KeyboardTrackingView()
        config.eventListeners.append() { event in
            if case .didHide = event {
                print("yep")
            }
        } 

        let view = MessageView.viewFromNib(layout: .cardView)
        view.configureTheme(.warning)
        view.configureDropShadow()
        // 支持 emoji表情文字
        let iconText = ["🤔", "😳", "🙄", "😶"].randomElement()!
        view.configureContent(title: "标题", body: "请问你需要吗？", iconText: iconText)
        view.button?.titleLabel?.text = "OK"
        view.layoutMarginAdditions = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        (view.backgroundView as? CornerRoundingView)?.cornerRadius = 10
        
        SwiftMessages.show(config: config, view: view)
    }
    
    
    class func hide(){
        // 隐藏当前提示
        SwiftMessages.hide()

        // 隐藏当前提示 清除队列
//        SwiftMessages.hideAll()
        // 隐藏特定提示
//        SwiftMessages.hide(id: "123")
        // 隐藏可能重复的特定提示
//        SwiftMessages.hideCounted(id: "123")
    }
    
    // 找回 提示框，用于看情况实时 更新or隐藏提示
    func find(id:String)  {
        if let view = SwiftMessages.current(id: id) {
            
        }
 
        if let view = SwiftMessages.queued(id: id) {
            
        }
 
        if let view = SwiftMessages.currentOrQueued(id: id) {
            
        }
    }
}
