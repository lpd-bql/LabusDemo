//
//  DateExtension.swift
//  LubasApp
//
//  Created by lpd on 2024/11/12.
//

import Foundation

extension Date {
    static func from(timestamp: Int) -> Date? {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone.current
        
        return dateFormatter.date(from: timestamp.description)
    }
    
    // 判断时间戳是否已过期
    func isExpired() -> Bool {
        return self < Date.now
    }
}
