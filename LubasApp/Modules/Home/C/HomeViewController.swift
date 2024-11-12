//
//  ddddd.swift
//  LubasApp
//
//  Created by Pidong Ling on 2024/10/16.
//

import UIKit

class HomeViewController: BaseViewController{
    var coordinator: HomeCoordinator?   // 导航管理

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "主页"

        let b = UIButton()
        b.setTitle("改变", for: .normal)
        b.setTitleColor(.gray, for: .normal)
        b.setImage(.init(named: "arrow"), for: .normal)
        b.exchangeTitleImage()
        view.addSubview(b)
        b.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    
    }
    
}
