//
//  dddd.swift
//  LubasApp
//
//  Created by Pidong Ling on 2024/10/15.
//

import UIKit


class UserPopupView: PopupView{
    
    
    override func setupUI() {
        
        let lb = UILabel.make(with: "标题", font: 18.font(.medium), color: themeTextColor, align: .center)
        contentView.addSubview(lb)
        lb.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(20.xo)
        }
        
//        let xb = UIButton
        
        
    }
    
}
