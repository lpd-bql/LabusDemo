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
    private let cacheQueue = DispatchQueue(label: "com.example.networkCache", qos: .background)
    
    private let maxDiskCacheSize: Int64 = 50 * 1024 * 1024 // 磁盘缓存上限为50MB

    init() {
        // 指定缓存目录   cachesDirectory
        diskCacheDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("NetworkCache")
        print("diskCacheDirectory: \(diskCacheDirectory)")

        // 检查并创建目录
        if !fileManager.fileExists(atPath: diskCacheDirectory.path) {
            do {
                try fileManager.createDirectory(at: diskCacheDirectory, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Failed to create cache directory: \(error)")
            }
        }
    }

    // 异步获取缓存并解码为 Decodable 类型
    func getCachedObject<T: Decodable>(for key: String, as type: T.Type, completion: @escaping (T?) -> Void) {
        if let memoryData = memoryCache.object(forKey: key as NSString) {
            if let object = try? JSONDecoder().decode(T.self, from: memoryData as Data) {
                completion(object)
                return
            }
        }
        
        let filePath = diskCacheDirectory.appendingPathComponent(key)
        
        cacheQueue.async {
            if let diskData = try? Data(contentsOf: filePath) {
                self.memoryCache.setObject(diskData as NSData, forKey: key as NSString)
                if let object = try? JSONDecoder().decode(T.self, from: diskData) {
                    completion(object)
                } else {
                    completion(nil)
                }
            } else {
                completion(nil)
            }
        }
    }

    // 缓存数据并编码为 JSON
    func cacheObject<T: Encodable>(_ object: T, for key: String) {
        if let data = try? JSONEncoder().encode(object) {
            memoryCache.setObject(data as NSData, forKey: key as NSString)
            
            let filePath = diskCacheDirectory.appendingPathComponent(key)
            cacheQueue.async {
                do {
                    // 确保文件夹存在
                    if !self.fileManager.fileExists(atPath: self.diskCacheDirectory.path) {
                        try self.fileManager.createDirectory(at: self.diskCacheDirectory, withIntermediateDirectories: true, attributes: nil)
                    }
                    
                    try data.write(to: filePath)
                    self.enforceDiskCacheLimit()
                } catch {
                    print("Failed to write cache data to disk: \(error)")
                }
            }
        }
    }

}

extension NetworkCache {
    // 磁盘缓存限制
    private func enforceDiskCacheLimit() {
        cacheQueue.async {
            let fileURLs = (try? self.fileManager.contentsOfDirectory(at: self.diskCacheDirectory, includingPropertiesForKeys: [.contentModificationDateKey, .fileSizeKey], options: .skipsHiddenFiles)) ?? []
            
            var totalSize: Int64 = 0
            var cacheFiles: [(url: URL, size: Int64, date: Date)] = []

            for url in fileURLs {
                if let attributes = try? url.resourceValues(forKeys: [.contentModificationDateKey, .fileSizeKey]),
                   let modificationDate = attributes.contentModificationDate,
                   let fileSize = attributes.fileSize {
                    totalSize += Int64(fileSize)
                    cacheFiles.append((url: url, size: Int64(fileSize), date: modificationDate))
                }
            }
            
            if totalSize > self.maxDiskCacheSize {
                cacheFiles.sort { $0.date < $1.date }
                
                for file in cacheFiles {
                    do {
                        try self.fileManager.removeItem(at: file.url)
                        totalSize -= file.size
                        if totalSize <= self.maxDiskCacheSize {
                            break
                        }
                    } catch {
                        print("Failed to remove cache file: \(error)")
                    }
                }
            }
        }
    }
}


