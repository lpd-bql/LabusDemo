//
//  dddd.swift
//  LubasApp
//
//  Created by Pidong Ling on 2024/10/15.
//

import UIKit

extension UILabel{
    
    static func make(with text: String, font: UIFont, color: UIColor, align: NSTextAlignment) -> UILabel {
        let lb = UILabel()
        lb.text = text
        lb.textColor = color
        lb.font = font
        lb.textAlignment = align
        
        return lb
    }
    
}
