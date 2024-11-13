//
//  APIService.swift
//  LubasApp
//
//  Created by Pidong Ling on 2024/10/22.
//

import Alamofire

// 基于 NetworkManager 封装的业务层方法，用于定义应用中各个具体的 API 请求。

enum userAPI{
    case getUser
}

class APIService{
     
    
    // 获取用户信息；指定模型 User
    static func getUsers(params: [String: Any], completion: @escaping (Result<User, Error>) -> Void) {
        let url = "apiUrlG"
        NetworkManager.shared.GET(url: url, useCache: true, parameters: params, completion: completion)
    }
    
    
    static func getBall(useCache: Bool, params: [String: Any], completion: @escaping (Result<Ball, Error>) -> Void) {
        let url = "/api/MP4_xiaojiejie"
        NetworkManager.shared.GET(url: url, useCache: useCache, parameters: params, completion: completion)
    }
    
    
}
