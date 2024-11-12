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
    
    let baseUrl = "https://google.com"
    
    let reachabilityManager = NetworkReachabilityManager()
    
    private let cache = NetworkCache()  // 缓存

    lazy var headers: HTTPHeaders = {
        var headers = HTTPHeaders.init()
        headers.add(name: "appid", value: "1")
        
        return headers
    }()
    
    // 通用的网络请求方法；使用泛型来适配不同的数据模型，统一处理网络请求；
    public func GET<T: Decodable>(
        url: String,
        parameters: [String: Any]? = nil,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        
        let absolutUrl = baseUrl + url
        AF.request(absolutUrl, method: .get, parameters: parameters, headers: self.headers)
            .validate()
            .responseDecodable(of: T.self) { response in
                // 通过 responseDecodable 方法，可轻松将 JSON 响应转换为 Swift 对象
                switch response.result {
                case .success(let data):
                    
                    completion(.success(data))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    
    public func POST<T: Decodable>(
        url: String,
        parameters: [String: Any]? = nil,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        
        let absolutUrl = baseUrl + url
        AF.request(absolutUrl, method: .post, parameters: parameters, headers: self.headers)
            .validate()
            .responseDecodable(of: T.self) { response in
                switch response.result {
                case .success(let data):
                    completion(.success(data))
                case .failure(let error):
                    completion(.failure(error))
                }
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
