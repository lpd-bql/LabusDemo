//
//  test.swift
//  ElmApp
//
//  Created by lpd on 2025/1/6.
//  Copyright © 2025 Enabot Technology (Shenzhen) Company Limited. All rights reserved.
//

import Alamofire
import Combine

protocol FZFileDownloadHelperDelegate: AnyObject{
         
    func didFinishedDownload(model: FZRobotFileDBModel, state: Int, progress: Progress?)
}

class FZRobotFileDBModel {
    
}

class FZFileDownloadHelper{
    static let shared = FZFileDownloadHelper.init()
    private init() {}
    
    weak var delegate: FZFileDownloadHelperDelegate?
      
    // 传入 fdModel 下载
    func beginDownload(fdModel: FZRobotFileDBModel){
          
        let url = ""
        
        // 下载
        // 记录
        FZFileDownloadManager.shared.addFileToDownload(fdModel: fdModel)
        
        FZFileDownloadManager.shared.downloadFile(from: url) { [weak self] progress in
             
            self?.delegate?.didFinishedDownload(model: fdModel, state: 1, progress: progress)
            
        } completion: {[weak self] res in
            switch res {
                case let .success(Url):
//                    print("pdd 下载成功，保存路径：", Url ?? "")
 
                    self?.delegate?.didFinishedDownload(model: fdModel, state: 0, progress: nil)

                case let .failure(err):
//                    reback(-1)
                    self?.delegate?.didFinishedDownload(model: fdModel, state: -1, progress: nil)
            }
        }
 
    }
    
}

extension FZFileDownloadHelper{
    
    static func getActiveDownloadsCount() -> Int{
        FZFileDownloadManager.shared.getAllDownloadingCount()
    }
    static func getDownloadList() -> [FZFileDownloadInfo]{
        FZFileDownloadManager.shared.getAllDownloadList()
    }
    static func cancelDownload(for url: String) {
        FZFileDownloadManager.shared.cancelDownload(for: url)
    }
    
    static func getFileAppSaveURL(with path: String) -> URL{
        return FZFileDownloadManager.shared.downloadDirectory.appendingPathComponent(path)
    }
}

// 下载任务的文件信息
struct FZFileDownloadInfo {
    
//    var fileModel: FZRobotFileDBModel
    
    var url: String    //即fileModel.mediaFileURLPath 文件的下载地址
     
    var progress: Progress?
    
    var fileKey: String {
        return ""//fileModel.fileKey
    }
    
    //  文件下载 保存目录path
    var appFileRelativePath: String{
        return ""//fileModel.appFileRelativePath
    }
    
    //  断点数据 缓存目录path
    var appResumeDataPath: String{
//        elog.debug("pdd appResumeDataPath是\(fileModel.appResumeDataPath)")
        return ""//fileModel.appResumeDataPath
    }
}

extension FZFileDownloadInfo: Hashable {
    static func == (lhs: FZFileDownloadInfo, rhs: FZFileDownloadInfo) -> Bool {
        return lhs.fileKey == rhs.fileKey
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(fileKey)
    }
}
