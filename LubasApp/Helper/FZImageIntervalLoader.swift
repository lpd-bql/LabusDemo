//
//  EBOImageLoader.swift
//  ElmApp
//
//  Created by lpd on 2025/1/17.
//  Copyright © 2025 Enabot Technology (Shenzhen) Company Limited. All rights reserved.
//

import Kingfisher

/* 图片间隔加载 */
class FZImageIntervalLoader {
    
    private let queue = DispatchQueue(label: "com.fz.imageRequestQueue")
    private var workItem: DispatchWorkItem?
    private var urlListForLoading: [URL] = []
    private var isProcessing = false
    private var indexPathDict: [URL: IndexPath] = [:]

    var loadInteral = 0.0  // 加载间隔时间
     
      
    func addRequest(url: URL, indexPath: IndexPath, completion: @escaping (IndexPath?, UIImage?) -> Void) {
        if urlListForLoading.contains(url) { return }
        
        urlListForLoading.append(url)
        
        indexPathDict[url] = indexPath
        
        queue.async { [weak self] in
            self?.startTask(completion: completion)
        }
    }
    
    // 外界须调用
    func cancelTask(){
        workItem?.cancel()
        workItem = nil  // fix：防止循环引用

    }
     
    
    private func startTask(completion: @escaping (IndexPath?, UIImage?) -> Void) {
        guard !isProcessing, let nextURL = urlListForLoading.first else { return }
        
        isProcessing = true
        urlListForLoading.removeFirst()
         
        // 检查下一个
        if let url2 = urlListForLoading.first {
            let t = KingfisherManager.shared.cache.imageCachedType(forKey: url2.relativePath)
            loadInteral = t == .none ? 0.3 : 0    // 已经有缓存，则不需要 间隔加载
        }
        
        // 加载当前
        let source = Kingfisher.ImageResource(downloadURL: nextURL, cacheKey: nextURL.relativePath)
        let retry = DelayRetryStrategy(maxRetryCount: 5, retryInterval: .accumulated(2))
        KingfisherManager.shared.retrieveImage(with: source, options: [.retryStrategy(retry)]) { [weak self] result in
            guard let weakSelf = self else { return }
            DispatchQueue.main.async {
                switch result {
                    case .success(let value):
                        if let idp = weakSelf.indexPathDict[nextURL]{
                            completion(idp, value.image)
                        }
                    case .failure: 
//                        weakSelf.urlListForLoading.append(nextURL)   // 加载失败，重新保存
                        completion(nil, nil)
                }
                
                weakSelf.workItem?.cancel() // 取消之前的任务
                
                let sec = weakSelf.loadInteral
                weakSelf.workItem = DispatchWorkItem{
                    weakSelf.isProcessing = false
                    weakSelf.startTask(completion: completion)  // 加载下一个
                }
                weakSelf.queue.asyncAfter(deadline: DispatchTime.now() + sec, execute: weakSelf.workItem!)
            }
        }
    }
}
