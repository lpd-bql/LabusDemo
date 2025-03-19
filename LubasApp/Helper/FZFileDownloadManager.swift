//
//  FZFileDownloadManager.swift
//  ElmApp
//
//  Created by lpd on 2025/1/6.
//  Copyright © 2025 Enabot Technology (Shenzhen) Company Limited. All rights reserved.
//

import Foundation
import Alamofire
 

class FZFileDownloadManager{
    // 下载状态
    enum FZDownloadStatus {
        case pending
        case downloading(progress: Double)
        case paused(progress: Double)
        case completed(String)
        case failed(Error)
    }
     
    struct FZDownloadParam {
        let url: String
        let progress: (Progress) -> Void
        let completion: (Result<URL?, Error>) -> Void
    }
    
    // 处理 业务相关
    var fileDownloadInfosDict: [String : FZFileDownloadInfo] = [:]   //下载链接 作为key
    private var lock: NSRecursiveLock? = NSRecursiveLock()

    // 本身 
    static let shared = FZFileDownloadManager.init()
     
    private let maxConcurrentDownloads: Int = 1  // 最大同时下载数
    
    private var session: Alamofire.Session
    private var downloadingTasks: [String: DownloadRequest] = [:]    // 进行中的 任务
    private var pendingDownloads: [String: FZDownloadParam] = [:]    // 等待中的 任务
    private var downloadStatus: [String: FZDownloadStatus] = [:]
    
    let downloadDirectory: URL
    let cacheDirectory: URL
    
    private let downloadQueue = DispatchQueue(label: "com.fz.downloader")

    private let operationQueue: OperationQueue = {
        let queue = OperationQueue()
        return queue
    }()
    
    private init() {
        
        let configuration = URLSessionConfiguration.default
        configuration.httpMaximumConnectionsPerHost = maxConcurrentDownloads
        session = Alamofire.Session(configuration: configuration)
        
        operationQueue.maxConcurrentOperationCount = maxConcurrentDownloads

        let fileManager = FileManager.default
         
        let path1 = "FZFileDownloads"
        downloadDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(path1)
        if !fileManager.fileExists(atPath: downloadDirectory.path) {
            try? fileManager.createDirectory(at: downloadDirectory, withIntermediateDirectories: true, attributes: nil)
        }

        cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
    }
     
}

 
extension FZFileDownloadManager{
     
    /// 获取 文件的下载状态
    func getStatus(for url: String) -> FZDownloadStatus? {
        return downloadStatus[url]
    }
    
    /// 获取 文件的下载进度
    func getProgress(for url: String) -> Double? {
        if case let .downloading(progress) = downloadStatus[url] {
            return progress
        } else if case let .paused(progress) = downloadStatus[url] {
            return progress
        }
        return nil
    } 
    
}

extension FZFileDownloadManager{
    private func removeResumeData(url: String){
         
        guard let resumeDataURL = getResuemDataCacheURL(with: url) else { return }
         
        do {
            try FileManager.default.removeItem(at: resumeDataURL)
        } catch {
            print("pdd Download removeItem error \(error.localizedDescription)")
        }
    }
    
    private func cacheResumeData(_ resumeData: Data, url: String){
         
        guard let resumeDataURL = getResuemDataCacheURL(with: url) else { return }
        print("pdd 开始 保存断点 ")
        do {
            try resumeData.write(to: resumeDataURL)
            print("pdd 断点保存了 \(resumeData.count)")
        } catch {
            print("pdd 断点保存 error \(error.localizedDescription)")
        }
    }
    
    private func getResumeData(url: String) -> Data?{
        print("pdd 获取断点数据 ")
        guard let resumeDataURL = getResuemDataCacheURL(with: url) else {
            print("pdd 没有resumeDataURL")
            return nil
        }
        let resumingData: Data? = try? Data(contentsOf: resumeDataURL)
         
        if let data = resumingData {
            print("pdd 获取断点数据 成功")
            return data
        }
        print("pdd 获取断点数据 nil")
        return nil
    }
    
}

extension FZFileDownloadManager{
    
    /// 批量下载
//    func downloadFiles(urls: [String], progressHandler: ((String, Progress) -> Void)? = nil, completionHandler: ((String, Result<URL?, Error>) -> Void)? = nil
//    ) {
//        urls.forEach { url in
//            downloadFile(
//                from: url,
//                progress: { progress in
//                    progressHandler?(url, progress)
//                },
//                completion: { result in
//                    completionHandler?(url, result)
//                }
//            )
//        }
//    }
    
    /// 单个 下载
    func downloadFile(from url: String, progress: @escaping (Progress) -> Void, completion: @escaping (Result<URL?, Error>) -> Void
    ) {
        // 本地
        let fileURL = getDestinationURL(with: url)
          
        // 是否 已下载过
        if FileManager.default.fileExists(atPath: fileURL.path) {
            downloadStatus[url] = .completed(url)
            fileDownloadInfosDict[url] = nil
            completion(.success(fileURL))
            return
        }
         
        // 是否 正在下载
        if downloadingTasks.keys.contains(url) {
//            progress(0.0) // 初始进度    todo?
            return
        }
                
        // 是否 排队中
        if pendingDownloads[url] != nil { return }
         
        self.lock?.lock()
        let activeCount = self.downloadingTasks.count
        self.lock?.unlock()
        
        if activeCount < maxConcurrentDownloads {  // 在限制任务数量 内
            // 开始
            startDownload(from: url, progress: progress, completion: completion)
        } else {
            // 排队
            let param = FZDownloadParam(url: url, progress: progress, completion: completion)
            pendingDownloads[url] = param    // 先保存入参
        }
          
    }
    
    /// 开始下载
    func startDownload(from url: String, progress: @escaping (Progress) -> Void, completion: @escaping (Result<URL?, Error>) -> Void
    ) {
        
        if let resumeDataURL = getResuemDataCacheURL(with: url) {
            do {
                print("pdd 创建Cache目录 ")
                try FileManager.default.createDirectory(at: resumeDataURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            } catch {
                print("pdd 创建Cache目录 失败 \(error.localizedDescription)")
            }
        }
        
        // 下载到
        let fileURL = getDestinationURL(with: url)
        let destination: DownloadRequest.Destination = { _, _ in
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        var downloadTask: DownloadRequest
        // 是否有断点数据
        if let resumeData = getResumeData(url: url) {
            downloadTask = session.download(resumingWith: resumeData, to: destination)
            // 恢复下载
            removeResumeData(url: url)  //  清除
        }else{
            // 新建下载
            downloadTask = session.download(url, to: destination)
        }
         
        saveTask(downloadTask, for: url)   // 记录
        downloadStatus[url] = .pending

        downloadQueue.async { [weak self] in
            
            self?.operationQueue.addOperation {
                
                downloadTask.downloadProgress { progressData in
                    if progressData.fractionCompleted < 1{
                        self?.updateDownloadStatus(for: url, progress: progressData)
                        progress(progressData)
                    }
                    
                }.response { response in
//                    debugPrint("pdd handleDownload 完成Response")
                    self?.handleDownloadResponse(url: url, response: response, completion: completion)
                }
            }
        }
    }
     
    
    /// 处理下载结果
    private func handleDownloadResponse(url: String, response: AFDownloadResponse<URL?>, completion: (Result<URL?, Error>) -> Void) {
        switch response.result {
        case .success(let fileURL):
            print("pdd --下载 success")
            downloadStatus[url] = .completed(url)
            completion(.success(fileURL))
                
        case .failure(let error):
            if let resumeData = response.resumeData {
                // 缓存， 以支持断点续传
                print("pdd --下载failure")
                cacheResumeData(resumeData, url: url)
                // 保存下载状态
                downloadStatus[url] = .paused(progress: getProgress(for: url) ?? 0.0)
            } else {
                downloadStatus[url] = .failed(error)
            }
            completion(.failure(error))
        }
        // 移除
        saveTask(nil, for: url)
        
        self.lock?.lock()
        fileDownloadInfosDict[url] = nil
        self.lock?.unlock()
        
        // 启动下一个任务
        if let nextTask = pendingDownloads.popFirst()?.value {
            startDownload(from: nextTask.url, progress: nextTask.progress, completion: nextTask.completion)
        }else{
//            debugPrint("pdd 没有了")
        }
    }
    
    /// 取消单个任务
    func cancelDownload(for url: String) {
//        downloadingTasks[url]?.cancel()
        
        guard let task = downloadingTasks[url] else { return }
        task.cancel {[weak self] resumeData in
            print("pdd --下载 取消")
            if let resumeData = resumeData {
                self?.cacheResumeData(resumeData, url: url)  // 保存断点数据
            }
            
            self?.saveTask(nil, for: url)
    //        self?.removeResumeData(url: url)   // 清除断点数据 ?
            self?.downloadStatus[url] = nil
            self?.pendingDownloads[url] = nil
            
            self?.lock?.lock()
            self?.fileDownloadInfosDict[url] = nil
            self?.lock?.unlock()
        }
         
    }
    
    /// 暂停下载任务
    func pauseDownload(for url: String) {
        guard let task = downloadingTasks[url] else { return }
            
        task.cancel { resumeData in
            if let resumeData = resumeData {
                self.cacheResumeData(resumeData, url: url)  // 保存断点数据
                self.saveTask(nil, for: url)
                
                if let progress = self.getProgress(for: url) {
                    self.downloadStatus[url] = .paused(progress: progress)
                }
            }
        }
    }
    
    /// 批量取消任务
    func cancelAllDownloads() {
        downloadingTasks.keys.forEach { cancelDownload(for: $0) }
        pendingDownloads.keys.forEach { cancelDownload(for: $0) }
    }
    
    /// 批量暂停任务
    func pauseAllDownloads() {
        downloadingTasks.keys.forEach { pauseDownload(for: $0) }
    }
     
    /// 更新下载状态
    private func updateDownloadStatus(for url: String, progress: Progress) {
        downloadStatus[url] = .downloading(progress: progress.fractionCompleted)
        
        self.lock?.lock()
        FZFileDownloadManager.shared.fileDownloadInfosDict[url]?.progress = progress
        self.lock?.unlock()
    }
    /// 保存下载任务
    private func saveTask(_ task: DownloadRequest?, for url: String) {
        if let task = task {
            downloadingTasks[url] = task
        } else {
            downloadingTasks.removeValue(forKey: url)
        }
    }
    
}


// MARK: - 业务相关
extension FZFileDownloadManager{
    /// 文件的 保存 目录 （自定义
    private func getDestinationURL(with url: String) -> URL{
        let path = fileDownloadInfosDict[url]?.appFileRelativePath ?? ""

        let fileURL = downloadDirectory.appendingPathComponent(path)
        return fileURL
    }
    /// 文件的 保存 缓存目录 （自定义
    private func getResuemDataCacheURL(with url: String) -> URL?{
        if let path = fileDownloadInfosDict[url]?.appResumeDataPath {
            let fileURL = cacheDirectory.appendingPathComponent(path)
            print("pddz CacheURL是\(fileURL)")
            return fileURL
        }
        return nil
    }
    
    /// 获取 所有下载 任务数
    func getAllDownloadingCount() -> Int {
        self.lock?.lock()
        let c = fileDownloadInfosDict.count
        self.lock?.unlock()
        return c
    }
    
    func getAllDownloadList() -> [FZFileDownloadInfo] {
        
        if let list = fileDownloadInfosDict.map({ $0.value }) as? [FZFileDownloadInfo]{
//        if let list = Array(fileDownloadInfosDict.values) as? [FZFileDownloadInfo]{
            return list
        }
        return []
    }
    
    /// 保存 加入下载列表的 fdModel
    func addFileToDownload(fdModel: FZRobotFileDBModel){
        
//        guard let url = fdModel.mediaFileURLPath else { return }
//        let url = ""
//        let item = FZFileDownloadInfo.init(fileModel: fdModel, url: url)
//
//        self.lock?.lock()
//        FZFileDownloadManager.shared.fileDownloadInfosDict[url] = item   // 记录
//        self.lock?.unlock()
    }
}
