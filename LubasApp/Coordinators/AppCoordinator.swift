//
//  AppCoordinator.swift
//  LubasApp
//
//  Created by Pidong Ling on 2024/10/15.
//

import UIKit

// 主Coordinator，管理应用程序的主导航逻辑
// 负责管理应用程序的整体导航逻辑，通常包括启动应用程序的根视图控制器，以及初始化子Coordinator。

class AppCoordinator: Coordinator{
    var navigationController: BaseNavigationController
    var tabBarController: TabbarController

    init(navigationController: BaseNavigationController) {
                
        self.navigationController = navigationController
        
        self.tabBarController = TabbarController()

    }

    // 启动-打开 App，决定展示哪个页面
    func start() {
        
        let hc = HomeCoordinator()
        let uc = UserCoordinator()
        
        hc.start()
        uc.start()

        tabBarController.viewControllers = [hc.navigationController, uc.navigationController]

        // 设置 TabBar 的控制器为根控制器
        navigationController.setViewControllers([tabBarController], animated: false)
         
    }
        
}
