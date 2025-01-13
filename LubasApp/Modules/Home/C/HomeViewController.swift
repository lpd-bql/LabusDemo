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
        b.setTitle("正常", for: .normal)
        b.setTitleColor(.gray, for: .normal)
        b.addTarget(self, action: #selector(clickBtn), for: .touchUpInside)
        view.addSubview(b)
        b.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    
        let b2 = UIButton()
        b2.setTitle("使用缓存", for: .normal)
        b2.setTitleColor(.gray, for: .normal)
        b2.addTarget(self, action: #selector(clickBtn2), for: .touchUpInside)
        view.addSubview(b2)
        b2.snp.makeConstraints { make in
            make.centerY.leading.equalToSuperview()
        }
    }
    
    
    @objc func clickBtn(){
        
        APIService.getBall(useCache: false, params: ["type":"json"]) { res in
            switch res {
            case .success(let data):
                let b = data.mp4Video
                print("ddddd:\(b)")
            case .failure(let failure):
                print("d")
            }
        }
    }
    
    @objc func clickBtn2(){
        APIService.getBall(useCache: true, params: ["type":"json"]) { res in
            switch res {
            case .success(let success):
                print("d")
            case .failure(let failure):
                print("d")
            }
        }
    }
}
