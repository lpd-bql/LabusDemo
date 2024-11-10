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
    func asTextImage(padding: CGFloat){

        let spacing: CGFloat = 8.0  // 文字和图标之间的间距
        self.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        self.titleLabel?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        self.imageView?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)

        // 设置图标和文字的间距
        self.titleEdgeInsets = UIEdgeInsets(top: 0, left: padding, bottom: 0, right: -padding)
        self.imageEdgeInsets = UIEdgeInsets(top: 0, left: -padding, bottom: 0, right: padding)
    }
    
}
