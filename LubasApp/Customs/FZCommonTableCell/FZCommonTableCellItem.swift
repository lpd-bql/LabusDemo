//
//  FZCommonTableCellItem.swift
//  ElmApp
//
//  Created by lpd on 2025/2/14.
//  Copyright © 2025 Enabot Technology (Shenzhen) Company Limited. All rights reserved.
//

import UIKit

typealias FZCommonTableItems = [[FZCommonTableCellItem]]

extension FZCommonTableItems{
    
    /// 单选 场景
    mutating func singleSelect(indexPath: IndexPath){
        for (s, models) in self.enumerated(){
            for (r, _) in models.enumerated(){
                let idp = IndexPath.init(row: r, section: s)
                
                self[s][r].isTicked = idp == indexPath
                
            }
        }
    }
    
    /// 多选 场景
    mutating func multipleSelectByClick(indexPath: IndexPath){
        for (s, models) in self.enumerated(){
            for (r, _) in models.enumerated(){
                
                let idp = IndexPath.init(row: r, section: s)
                if idp == indexPath {
                    let isTicked = self[s][r].isTicked ?? false
                    self[s][r].isTicked = !isTicked
                }
            }
        }
    }
    
}

extension FZCommonTableItems{
      
    /// 根据ctionType，更新某row的数据
    mutating func update(row t: FZCommonTableCellActionType, subTitle: String? = nil, valueStr: String? = nil, isOn: Bool? = nil, isTicked: Bool? = nil){
        
        var indexPath = IndexPath.init(row: 0, section: 0)
        for (s, models) in self.enumerated(){
            for (r, item) in models.enumerated(){
                if item.actionType == t {
                    indexPath = IndexPath.init(row: r, section: s)
//                    print("pdd update section\(s) row\(r)")
                    break
                }
            }
        }
        
        if let subTitle = subTitle {
            self[indexPath.section][indexPath.row].subTitle = subTitle
        }
        if let valueStr = valueStr {
            self[indexPath.section][indexPath.row].valueStr = valueStr
        }
        if let isOn = isOn {
            self[indexPath.section][indexPath.row].isOn = isOn
        }
        if let isTicked = isTicked {
            self[indexPath.section][indexPath.row].isTicked = isTicked
        }
         
    }
}

// Item 对应 row cell
class FZCommonTableCellItem {
    
    var title: String = ""
    var cellType: FZCommonTableCellType = .titleWithArrow

    var actionType: FZCommonTableCellActionType?

    var subTitle: String?
    var valueStr: String?
    var isOn: Bool?          // 开关
    var isTicked: Bool?      // 打钩

    /// 能否触发事件；true 则 需要在 didSelectRowAt 处理cell 点击事件；false 则 需要 设置cell的代理方法 处理
    var selectRowEnable: Bool {
        switch self.cellType {
            case .titleSubtitleWithSwitch, .titleWithSwitch:
                return false
            default:
                return true
        }
    }
    
    init(title: String, cellType: FZCommonTableCellType, actionType: FZCommonTableCellActionType? = nil, subTitle: String? = nil, valueStr: String? = nil, isOn: Bool? = nil, isTicked: Bool? = nil) {
        
        self.title = title
        self.cellType = cellType
        self.actionType = actionType
        self.subTitle = subTitle
        self.valueStr = valueStr
        self.isOn = isOn
        self.isTicked = isTicked
    }
     
}

 

extension FZCommonTableCellItem{
    
   public func cellHeight() -> CGFloat {
     switch cellType {
         case .titleWithSwitch, .titleValueWithArrow, .titleWithTick, .titleWithArrow:
             return 50
         default:
             return UITableView.automaticDimension
     }
   }
   
   public static func sectionHeaderHeight(by sectionTitle: String) -> CGFloat{
       if sectionTitle.isEmpty{
           return 0
       }
       return 24 
   }
   
    public static func footerHeight() -> CGFloat {
        return 0.01
    }
}
