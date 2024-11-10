//
//  xxxxx.swift
//  LubasApp
//
//  Created by Pidong Ling on 2024/10/16.
//

import UIKit


class HomeCoordinator: Coordinator{
    
    // 管理与用户相关的页面跳转逻辑。它会负责在用户模块中导航到不同的页面。

    var navigationController: BaseNavigationController

    init() {
        self.navigationController = BaseNavigationController()
    }

    // 打开
    func start() {
        let homeVC = HomeViewController()
        homeVC.coordinator = self
        homeVC.tabBarItem = UITabBarItem(title: "主页", image: UIImage(systemName: "house"), tag: 0)
        
        navigationController.pushViewController(homeVC, animated: false)
    }
    
    /// 跳转到 详情页面
    /// - Parameter params: 页面传参
    func showDetail(params: [String]) {
        let vc = DetailViewController()
        navigationController.pushViewController(vc, animated: true)
    }
    
}

