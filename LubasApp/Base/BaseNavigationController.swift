//
//  xxxx.swift
//  LubasApp
//
//  Created by Pidong Ling on 2024/10/15.
//

import UIKit

class BaseNavigationController: UINavigationController{
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        self.initStyle()
    }
    
//    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
//        if viewControllers.count > 0 {
//            // 隐藏底部 tabBar
//            viewController.hidesBottomBarWhenPushed = true
//            
//            viewController.navigationItem.leftBarButtonItem = UIBarButtonItem.init(imageName: "nav_btn_back_white", higImageName: "", size: .zero, target: self, action: #selector(popVC))
//        }
//        super.pushViewController(viewController, animated: animated)
//    }
    
    
    // 改变状态栏颜色
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    // 点击空白 退出键盘
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}


extension BaseNavigationController{
    // 自定义 样式
    fileprivate func initStyle() {
        //设置字体大小和颜色
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white,NSAttributedString.Key.font : UIFont.systemFont(ofSize: 18)]
        //设置背景色
        UINavigationBar.appearance().barTintColor = UIColor.brown
        //设置半透明
        UINavigationBar.appearance().isTranslucent = false
        // 设置导航栏背景图片
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        //隐藏navigationBar下面的分割线
        UINavigationBar.appearance().shadowImage = UIImage()
         
    }
}
