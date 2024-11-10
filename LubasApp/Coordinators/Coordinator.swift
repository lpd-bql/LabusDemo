//
//  Coordinator.swift
//  LubasApp
//
//  Created by Pidong Ling on 2024/10/15.
//

import UIKit

// 定义基本的导航功能，所有Coordinator需要遵守这个协议

protocol Coordinator {
    
    var navigationController: BaseNavigationController { get set }
        
    // 必须实现的协议方法
    func start()
    
}
