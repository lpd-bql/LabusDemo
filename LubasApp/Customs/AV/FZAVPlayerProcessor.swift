//
//  FZAVPlayerProcessor.swift
//  ElmApp
//
//  Created by lpd on 2024/12/30.
//  Copyright © 2024 Enabot Technology (Shenzhen) Company Limited. All rights reserved.
//


import Foundation
import AVKit


protocol FZAVPlayerProcessorDelegate: AnyObject {
    // 监听加载状态
    func observe(status: AVPlayer.Status)
    
    // 监听AVPlayer "rate"属性以便我们去更新播放进度控件. rate = 0暂停rate = 1播放
//    func observe(rate: Float)
    
    // 监听缓冲进度;  可有可无，可以增加用户体验
    func observe(timeRange: CMTimeRange)

    // 监听 当前播放进度
    func observePeriodicTime(totalDuration: Double, currentDuration: Double)
     
    // 监听播放器的播放缓冲区 是否为空；缓存不够了 自动暂停播放
    func observePlaybackBufferEmpty()
    
    // 监听是否缓冲好了;  缓冲可播放的时候 调用
    func observePlaybackLikelyToKeepUp()
    
    func observeApplicationBecomeActive(isPlayVideo: Bool)
    
    func observeApplicationEnterBackground(isPauseVideo: Bool)
     
    // 播放结束通知
    func observeDidPlayToEndTime()
}


class FZAVPlayerProcessor: NSObject {
    
    weak var delegate: FZAVPlayerProcessorDelegate?
    
    var playerItem: AVPlayerItem?            //视频资源载体
    var player: AVPlayer?                    //视频播放器
    var playerLayer: AVPlayerLayer?
    
    var currentAsset: AVURLAsset?
    var videoScale: CGFloat?{  // 画面 宽高比
        // 注意：同步获取会耗时
        if let track = currentAsset?.tracks(withMediaType: .video).first {
            return track.naturalSize.width / track.naturalSize.height
        }
        return 375.0 / 210.0
    }
     
    private var playerTimeObserver: Any?
    
    private var rePlayWhenAppBecomeActive = false
    
    private var addObserversFlag = false
 
    func setUpVideoPlayerWith(urlStr: String) {
        
        if let url: URL = URL(string: urlStr) {
            let asset: AVURLAsset = AVURLAsset.init(url: url)
            currentAsset = asset
             
            self.playerItem = AVPlayerItem.init(asset: asset)
        }
        
        self.player = AVPlayer.init(playerItem: self.playerItem)
        self.player?.automaticallyWaitsToMinimizeStalling = false
        //        self.player?.rate = 1.0//播放速度

        //创建显示视频的图层
        let avPlayerLayer = AVPlayerLayer.init(player: self.player)
        avPlayerLayer.videoGravity = .resizeAspect
        playerLayer = avPlayerLayer
        
        if addObserversFlag == false{
            addStatusObserver()
            addPlayerObserver()
            addPlayingTimeObserver()
            addObserversFlag = true
        }
        
    }
    
    deinit {
        if addObserversFlag {
            removeStatusObserver()
            removePlayerObserver()
        }
    }
}


extension FZAVPlayerProcessor {
    
    func isPlaying() -> Bool {
        if let avPlayer = player {
            return avPlayer.rate > 0
        }
        return false
    }
    
    func play() {
        player?.play()   // 播放速度= 1.0
    }
    
    func pause() {
        player?.pause()
    }
    
    func seekTo(relativeValue: Float) {
        guard let status = player?.currentItem?.status, status == .readyToPlay else { return }
        guard let duration = player?.currentItem?.duration else { return }
        let newTime = CMTimeMultiplyByFloat64(duration, multiplier: Float64(relativeValue))
        
        player?.seek(to: newTime, toleranceBefore: .zero, toleranceAfter: .zero)
    }
    
    func replacePlayerItemWith(urlStr: String?) {
        guard let urlStr = urlStr else { return }
        guard let videoUrl = URL(string: urlStr) else { return }
 
        let asset = AVURLAsset.init(url: videoUrl, options: nil)
        currentAsset = asset
        let item = AVPlayerItem.init(asset: asset)
 
        replaceItem(item)

    }
    
    func replaceItem(_ item: AVPlayerItem?) {
        playerItem = item
        // 希望缓存多少秒的视频数据，减小这个值可 降低播放的启动延迟
        playerItem?.preferredForwardBufferDuration = 12

        player?.pause()
        player?.seek(to: .zero)
        player?.replaceCurrentItem(with: item)
         
    }
}

// MARK: - 监听各种状态
extension FZAVPlayerProcessor {
    
    // KVO
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        
        guard let avPlayer = self.player else { return }

        if keyPath == "status" {
            delegate?.observe(status: avPlayer.status)
              
        } else if keyPath == "rate" {
//                delegate?.observe(rate: avPlayer.rate)
            
        } else if keyPath == "loadedTimeRanges" {    // 缓冲进度
            if let timeRanges = avPlayer.currentItem?.loadedTimeRanges as? [NSValue],
                let timeRange = timeRanges.first?.timeRangeValue {
                delegate?.observe(timeRange: timeRange)
            }
            
        } else if keyPath == "playbackBufferEmpty" { // 正在缓冲视频 请稍等
            delegate?.observePlaybackBufferEmpty()
            
        }  else if keyPath == "playbackLikelyToKeepUp" { // 缓冲好了 继续播放
            delegate?.observePlaybackLikelyToKeepUp()
        }
    }

    private func addPlayingTimeObserver() {
        let interval = CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        playerTimeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main) { [weak self] time in
            guard let strongSelf = self else { return }
            guard let avPlayer = strongSelf.player else { return }
            
            let currentTime = CMTimeGetSeconds(avPlayer.currentTime())
            let totalTime = CMTimeGetSeconds(avPlayer.currentItem?.duration ?? CMTime.zero)
            
            if totalTime > 0 { // to avoid division by zero
                strongSelf.delegate?.observePeriodicTime(totalDuration: totalTime, currentDuration: currentTime)
            }
        }
    }
    
    func handlingInterruptions() {
    }
    
    private func addStatusObserver() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationBecomeActive), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: nil)
        
//        addPlayerObserver()
    }
    
    private func addPlayerObserver() {
        player?.addObserver(self, forKeyPath: "rate", options: .new, context: nil)
        player?.currentItem?.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        player?.currentItem?.addObserver(self, forKeyPath: "loadedTimeRanges", options: .new, context: nil)
        player?.currentItem?.addObserver(self, forKeyPath: "playbackBufferEmpty", options: .new, context: nil)
        player?.currentItem?.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: .new,context: nil)
    }
    
    private func removeStatusObserver() {
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
        
//        removePlayerObserver()
    }
    
    private func removePlayerObserver() {
        
        player?.removeObserver(self, forKeyPath: "rate", context: nil)
        
        if player?.currentItem?.observationInfo != nil{
            player?.currentItem?.removeObserver(self, forKeyPath: "status", context: nil)
            player?.currentItem?.removeObserver(self, forKeyPath: "loadedTimeRanges", context: nil)
            player?.currentItem?.removeObserver(self, forKeyPath: "playbackBufferEmpty", context: nil)
            player?.currentItem?.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp", context: nil)
        }
    }
    
    @objc func playerDidFinishPlaying(note: NSNotification) {
        delegate?.observeDidPlayToEndTime()
    }
    
    @objc func applicationBecomeActive() {
        if rePlayWhenAppBecomeActive {
            delegate?.observeApplicationBecomeActive(isPlayVideo: true)
            rePlayWhenAppBecomeActive = false
        }
    }
    
    @objc func applicationEnterBackground() {
        // 记录并停止当前的视频
        if isPlaying() {
            delegate?.observeApplicationEnterBackground(isPauseVideo: true)
            rePlayWhenAppBecomeActive = true
        }
    }
}

