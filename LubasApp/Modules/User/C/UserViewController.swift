//
//  UserViewController.swift
//  LubasApp
//
//  Created by Pidong Ling on 2024/10/15.
//

import UIKit

class UserViewController: BaseViewController{
    var coordinator: UserCoordinator?  // 导航管理者，外部set
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 设置视图
        title = "个人"

        let v = UIButton()
        v.backgroundColor = .init(hex: 0x333333)
        v.frame = .init(x: 33, y: 100, width: 333, height: 46)
        v.addTarget(self, action: #selector(click), for: .touchUpInside)
        view.addSubview(v)
        
        
    }
    
    @objc func click(){
        Alert.toast(title: "提示", content: "请问你需要吗？") {
            debugPrint("134341244124142")
        }
//        Alert.toast("温馨xxxxxxxxxxxxx提示")
//        Alert.toastTip(title: "标题", content: "温馨提示", position: .fromCenter)
//        Alert.toastActionTip(title: "标题", content: "温馨提示", resultType: .Success)
    }

    // 点击查看详情，调用Coordinator来 导航
    func clickUserDetail() {
//        在vc中，不再直接处理跳转，而是通过Coordinator
//        let user = User(id: 1, name: "John", email: "xxxx")
//        coordinator?.showUserDetail(user: user)
    }
    
}

extension UserViewController{
    
    func dddd(){
        let u = User.init(id: 1, name: "", email: "")
        u.fetchUserInfo { data in
            if let d = data{
                
            }else{
                
            }
        }
    }
}
