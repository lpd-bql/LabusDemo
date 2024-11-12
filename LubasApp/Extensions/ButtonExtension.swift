//
//  xxx.swift
//  LubasApp
//
//  Created by Pidong Ling on 2024/10/15.
//

import UIKit

extension UIButton{
    
    /// 快速创建
    static func make(with title: String, font: UIFont, txtColor: UIColor, img: UIImage) -> UIButton {
        
        let bt = UIButton()
        bt.setTitle(title, for: .normal)
        bt.setTitleColor(txtColor, for: .normal)
        bt.titleLabel?.font = font
        bt.setImage(img, for: .normal)
        
        return bt
    }
    
    /// 交换 title 和 image 的位置  
    func exchangeTitleImage(){
        
        // 设置图标和文字的位置交换
        self.semanticContentAttribute = .forceRightToLeft

        // 设置按钮两端的边距
        let horizontalPadding: CGFloat = 8.0 // 设置左右边距的大小
        self.contentEdgeInsets = UIEdgeInsets(top: 0, left: horizontalPadding, bottom: 0, right: horizontalPadding)
    }
    
}
