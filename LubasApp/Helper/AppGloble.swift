//
//  AppGloble.swift
//  LubasApp
//
//  Created by lpd on 2024/11/11.
//

import Foundation

class AppGloble{
    static let shared = AppGloble()
    private init() {}
    
    lazy var dateFomatter: DateFormatter = {
        let dateFm = DateFormatter()
        dateFm.dateFormat = "yyyy-MM-dd"
        return dateFm
    }()
    
    
    
    
    
    
}
