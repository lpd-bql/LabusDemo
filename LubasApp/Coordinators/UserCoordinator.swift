//
//  UserCoordinator.swift
//  LubasApp
//
//  Created by Pidong Ling on 2024/10/15.
//

import UIKit

// 子Coordinator，每个子Coordinator负责特定的导航逻辑。

class UserCoordinator: Coordinator{
    
    // 管理与用户相关的页面跳转逻辑。它会负责在用户模块中导航到不同的页面。

    var navigationController: BaseNavigationController

    init() {
        self.navigationController = BaseNavigationController()
    }

    // 打开 userVC
    func start() {
        let userVC = UserViewController()
        userVC.coordinator = self  // 让vc引用 Coordinator
        userVC.tabBarItem = UITabBarItem(title: "个人", image: UIImage(systemName: "person"), tag: 2)
        
        navigationController.pushViewController(userVC, animated: false)
    }
    
    
    
}
