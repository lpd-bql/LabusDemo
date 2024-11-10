//
//  DataUtils.swift
//  LubasApp
//
//  Created by Pidong Ling on 2024/10/26.
//

import Foundation

class DataUtils{
    
    /// 从URL中提取参数，输出为字典
    func extractURLParameters(from url: URL) -> [String: Any]? {
        // 用 URLComponents 来解析 URL
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems else {
            return nil
        }
        // 将查询参数转换为字典
        var params: [String: Any] = [:]
        for queryItem in queryItems {
            if let val = queryItem.value?.removingPercentEncoding{
                // 解码
                params[queryItem.name] = val
            }else{
                params[queryItem.name] = queryItem.value
            }
        }
        return params
    }
    
    /// 将字典转换为 JSON 数据
    func jsonFromDict(dict: [String: Any]) -> String?{
        if let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: []) {
            // 将 JSON 数据转换为字符串
            let jsonString = String(data: jsonData, encoding: .utf8)
            return jsonString
        }else{
            return nil
        }
    }
    
    /// 将字典转换为 URL 编码字符串
    func paramsStringFromDict(dict: [String: Any]) -> String{
        let queryString = dict.map { key, value in
            var val = ""
            if let vall = value as? String{
                val = vall
            }else{
                val = String(describing: value)
            }
            return "\(key)=\(val.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        }.joined(separator: "&")
        
        return queryString
    }
    
}

