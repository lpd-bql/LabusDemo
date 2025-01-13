//
//  NetworkManager.swift
//  LubasApp
//
//  Created by Pidong Ling on 2024/10/22.
//

import Alamofire

class NetworkManager{
    // 单例
    static let shared = NetworkManager()
    private init() {}
    
    let baseUrl = "https://api.kuleu.com"
    
    let reachabilityManager = NetworkReachabilityManager()

    private let cache = NetworkCache()  // 缓存
    
    lazy var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()

    lazy var headers: HTTPHeaders = {
        var headers = HTTPHeaders.init()
        headers.add(name: "appid", value: "1")
        headers.add(name: "Content-Type", value: "application/json")
        
        return headers
    }()
    
    // 通用的网络请求方法；使用泛型来适配不同的数据模型，统一处理网络请求；
    public func GET<T: Codable>(
        url: String,
        useCache: Bool,
        parameters: [String: Any]? = nil,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        if !isNetworkReachable {
//            let result: Result<T, Error> = .failure(.asAFError(.))
//            completion(.failure()
            return
        }
        
        let absolutUrl = baseUrl + url
        let fetchBlock = {
            AF.request(absolutUrl, method: .get, parameters: parameters, headers: self.headers)
                .validate()
                .responseDecodable(of: T.self, decoder: self.decoder) { response in
                    // 通过 responseDecodable 方法，可轻松将 JSON 响应转换为 Swift 对象
                    debugPrint("网络请求返回：\(String(describing: response.data))")
                    switch response.result {
                    case .success(let data):
                        // 缓存
                        let cacheKey = absolutUrl + "?" + DataUtils.stringFromParamters(dict: parameters)
                        self.cache.cacheObject(data, for: cacheKey)
                        
                        completion(.success(data))
                    case .failure(let error):
                        print("失败错误: \(error.localizedDescription)")
                        completion(.failure(error))
                    }
                }
        }
        
        if useCache {
            let cacheKey = absolutUrl + "?" + DataUtils.stringFromParamters(dict: parameters)
            cache.getCachedObject(for: cacheKey, as: T.self) { cachedObject in
                if let cachedObject = cachedObject {
                    completion(.success(cachedObject))
                }else{
                    fetchBlock()
                }
            }
        } else {
            fetchBlock()
        }
        
    }
    
    
    public func POST<T: Codable>(
        url: String,
        useCache: Bool,
        parameters: [String: Any]? = nil,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        let absolutUrl = baseUrl + url
        
        let fetchBlock = {
            AF.request(absolutUrl, method: .post, parameters: parameters, headers: self.headers)
                .validate()
                .responseDecodable(of: T.self, decoder: self.decoder) { response in
                    switch response.result {
                    case .success(let data):
                        // 缓存
                        let cacheKey = absolutUrl + "?" + DataUtils.stringFromParamters(dict: parameters)
                        self.cache.cacheObject(data, for: cacheKey)
                        
                        completion(.success(data))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
        }
        if useCache {
            let cacheKey = absolutUrl + "?" + DataUtils.stringFromParamters(dict: parameters)
            cache.getCachedObject(for: cacheKey, as: T.self) { cachedObject in
                if let cachedObject = cachedObject {
                    completion(.success(cachedObject))
                }else{
                    fetchBlock()
                }
            }
        } else {
            fetchBlock()
        }
    }
}

extension NetworkManager {
    /// 网络状态
    public var networkStatus: NetworkStatus {
        guard let status = reachabilityManager?.status else { return .Unknown }
        switch status {
            case .unknown:
            return .Unknown
            case .notReachable:
            return .NotReachable
            case .reachable(let type):
                switch type {
                    case .ethernetOrWiFi:
                    return .WiFi
                    case .cellular:
                    return .WWAN
                }
        }
    }
    
    /// 网络是否可用
    public var isNetworkReachable: Bool {
        return networkStatus == .WiFi || networkStatus == .WWAN
    }
}
