//
//  xxxx.swift
//  LubasApp
//
//  Created by lpd on 2024/11/12.
//

import Foundation

class NetworkCache {
    private let memoryCache = NSCache<NSString, NSData>()
    private let fileManager = FileManager.default
    private let diskCacheDirectory: URL

    init() {
        diskCacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
    }

    // 获取缓存数据
    func getCachedData(for key: String) -> Data? {
        if let memoryData = memoryCache.object(forKey: key as NSString) {
            return memoryData as Data
        }
        
        let filePath = diskCacheDirectory.appendingPathComponent(key)
        if let diskData = try? Data(contentsOf: filePath) {
            memoryCache.setObject(diskData as NSData, forKey: key as NSString)
            return diskData
        }
        return nil
    }

    // 缓存数据
    func cacheData(_ data: Data, for key: String) {
        memoryCache.setObject(data as NSData, forKey: key as NSString)
        
        let filePath = diskCacheDirectory.appendingPathComponent(key)
        try? data.write(to: filePath)
    }

    // 清除所有缓存
    func clearCache() {
        memoryCache.removeAllObjects()
        try? fileManager.removeItem(at: diskCacheDirectory)
    }
}
