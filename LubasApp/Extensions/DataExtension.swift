//
//  DataExtension.swift
//  LubasApp
//
//  Created by lpd on 2024/11/13.
//
import Foundation

extension Data {
    
    static func byEncoded<T: Codable>(_ model: T) -> Data? {
        let encoder = JSONEncoder()
        if let encodedData = try? encoder.encode(model) {
            return encodedData
        }
        
        return nil
    }
    
    static func byDecoded<T: Codable>(_ data: Data) -> T? {
        let decoder = JSONDecoder()
        guard let loaded = try? decoder.decode(T.self, from: data) else {
            return nil
        }
        return loaded
    }
    
}
