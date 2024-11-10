//
//  APIService.swift
//  LubasApp
//
//  Created by Pidong Ling on 2024/10/22.
//

import Alamofire

// 基于 NetworkManager 封装的业务层方法，用于定义应用中各个具体的 API 请求。

class APIService{
    
    // 获取用户信息；指定模型 User
    static func getUsers(url: String, params: [String: Any], completion: @escaping (Result<[User], Error>) -> Void) {
        NetworkManager.shared.GET(url: url, parameters: params, completion: completion)
    }
    
    
    
    
    
}
