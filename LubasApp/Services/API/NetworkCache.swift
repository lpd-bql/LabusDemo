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
    private let maxDiskCacheSize: Int64 = 150 * 1024 * 1024 // 设置磁盘缓存上限为150MB

    init() {
        diskCacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
    }

    // 异步获取缓存数据
    func getCachedData(for key: String, completion: @escaping (Data?) -> Void) {
        // 从缓存取
        if let memoryData = memoryCache.object(forKey: key as NSString) {
            completion(memoryData as Data)
            return
        }
        // 从磁盘取
        let filePath = diskCacheDirectory.appendingPathComponent(key)
        
        cacheQueue.async {
            if let diskData = try? Data(contentsOf: filePath) {
                // 缓存
                self.memoryCache.setObject(diskData as NSData, forKey: key as NSString)
                completion(diskData)
            } else {
                completion(nil)
            }
        }
    }

    // 异步缓存数据
    func cacheData(_ data: Data, for key: String) {
        memoryCache.setObject(data as NSData, forKey: key as NSString)
        
        let filePath = diskCacheDirectory.appendingPathComponent(key)
        
        cacheQueue.async {
            do {
                try data.write(to: filePath)
                self.enforceDiskCacheLimit()
            } catch {
                print("Failed to write cache data to disk: \(error)")
            }
        }
    }

    // 清除所有缓存
    func clearCache() {
        memoryCache.removeAllObjects()
        try? fileManager.removeItem(at: diskCacheDirectory)
    }
}

extension NetworkCache {
    // 限制磁盘缓存大小，按LRU策略清理
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
            
            // 如果总大小超过限制，按修改日期排序并删除最早的文件
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
