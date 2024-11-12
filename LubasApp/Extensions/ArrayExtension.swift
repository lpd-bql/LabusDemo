//
//  ArrayExtension.swift
//  LubasApp
//
//  Created by lpd on 2024/11/12.
//

import Foundation

extension Array where Element: Hashable {
    
    /// 去重
    /// - Parameter sorted: 是否有序去重
    func uniqueElements(sorted: Bool) -> [Element] {
        if !sorted { return Array(Set(self)) }
        
        return self.reduce(into: [Element]()) { result, element in
            if !result.contains(element) {
                result.append(element)
            }
        }
    }
    
    
}
