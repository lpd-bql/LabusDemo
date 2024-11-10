//
//  xxxxxx.swift
//  LubasApp
//
//  Created by Pidong Ling on 2024/10/16.
//

import UIKit

extension String{
    
    /// 计算字符串长度
    func w(for fontsize: CGFloat) -> CGFloat{
        
        let theFont = UIFont.systemFont(ofSize: fontsize)

        let maxSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: (fontsize + 2.0))
        let textAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: theFont]

        let textWidth = (self as NSString).boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: textAttributes, context: nil).size.width
        
        return textWidth
    }
    
    
    static func JSONStringFromDict(_ dict: [String: Any]) -> String? {
        // 1. 将字典转换为 JSON 数据
        guard let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: []) else {
            return nil
        }
        
        // 2. 将 JSON 数据转换为字符串
        let jsonString = String(data: jsonData, encoding: .utf8)
        
        // 3. 对 JSON 字符串进行 URL 编码
//        let urlEncodedString = jsonString?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        return jsonString
    }

}
