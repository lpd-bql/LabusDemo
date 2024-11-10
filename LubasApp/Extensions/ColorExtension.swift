//
//  xxxxxx.swift
//  LubasApp
//
//  Created by Pidong Ling on 2024/10/15.
//

import Foundation
import UIKit

extension UIColor{
    
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: 1.0)
    }
    
    convenience init(hex: UInt) {
        self.init(
            red:   CGFloat((hex & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((hex & 0x00FF00) >> 8) / 255.0,
            blue:  CGFloat(hex & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    static func hex(_ hexValue: UInt) -> UIColor{
        return UIColor.init(hex: hexValue)
    }
    
    /// 随机颜色
    static func randomColor() -> UIColor {
        return UIColor(r: CGFloat(arc4random_uniform(256)), g: CGFloat(arc4random_uniform(256)), b: CGFloat(arc4random_uniform(256)))
    }
    
}
