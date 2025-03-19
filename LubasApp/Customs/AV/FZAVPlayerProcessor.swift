//
//  FZAVPlayerProcessor.swift
//  ElmApp
//
//  Created by lpd on 2024/12/30.
//  Copyright © 2024 Enabot Technology (Shenzhen) Company Limited. All rights reserved.
//

import AVKit
import Foundation
//import KTVHTTPCache

protocol FZAVPlayerProcessorDelegate: AnyObject {
    // 监听加载状态
    func observe(status: AVPlayer.Status)

    // 监听AVPlayer "rate"属性以便我们去更新播放进度控件. rate = 0暂停   rate = 1播放
    func observe(rate: Float)

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

    var playerItem: AVPlayerItem?  //视频资源载体
    var player: AVPlayer?  //视频播放器
    var playerLayer: AVPlayerLayer?

    var currentAsset: AVURLAsset?
    var videoScale: CGFloat? {  // 画面 宽高比
        // 注意：同步获取会耗时
        if let track = currentAsset?.tracks(withMediaType: .video).first {
            return track.naturalSize.width / track.naturalSize.height
        }
        return 375.0 / 210.0
    }

    var currentItemDuration: Float {
        return Float(CMTimeGetSeconds(playerItem?.duration ?? CMTime.zero))
    }
    var playingCurrentTime = 0.0

    private var playingTimeObserver: Any?

    private var rePlayWhenAppBecomeActive = false

    private var addObserversFlag = false

    private var addObserversItemFlag = false

    private var suspendObserversFlag = false  // 暂停Observer，防止冲突；切换vc播放视频 情况下 使用

    private var didPlayToEndFlag = false

    private var rateBySetting: Float = 1.0  // 用户设置的 播放速度

    private var playingState = false
    
    deinit {
        removeObservers()
    }
}

extension FZAVPlayerProcessor {

    func setUpVideoPlayer() {

        self.player = AVPlayer.init()
        self.player?.automaticallyWaitsToMinimizeStalling = false
        //        self.player?.rate = 1.0//播放速度

        //创建显示视频的图层
        let avPlayerLayer = AVPlayerLayer.init(player: player)
        avPlayerLayer.videoGravity = .resizeAspect
        playerLayer = avPlayerLayer

        addObservers()
    }

    /// 添加Observer 监听播放 状态；注意 移除Observer ！！
    public func addObservers() {
        if addObserversFlag == false {
            addStatusObserver()
            //            addPlayerItemObserver()
            //            addPeriodicTimeObserver()
            addObserversFlag = true
        }
    }

    public func removeObservers() {
        if addObserversFlag {
            print("pdd av removeObservers")
            removeStatusObserver()
            removePlayerItemObserver()
            removePeriodicTimeObserver()
            addObserversFlag = false
        }
    }

    // 暂停
    public func suspendObservers() {
        removePlayerItemObserver()
        removePeriodicTimeObserver()

        suspendObserversFlag = true
    }

    public func continueObservers() {
        if suspendObserversFlag {
            suspendObserversFlag = false
            addPlayerItemObserver()
            addPeriodicTimeObserver()
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
        playingState = true
        player?.play()   // 注：此方法，倍速 = 1
    }

    func pause() {
        playingState = false
        player?.pause()
    }

    func setRate(_ rate: Float) {
        rateBySetting = rate
        player?.playImmediately(atRate: rateBySetting)  // 立即生效
        playingState = true
    }

    func seekTo(relativeValue: Float) {
        guard let status = player?.currentItem?.status, status == .readyToPlay else { return }
        guard let duration = player?.currentItem?.duration else { return }
        let newTime = CMTimeMultiplyByFloat64(duration, multiplier: Float64(relativeValue))

        player?.seek(to: newTime, toleranceBefore: .zero, toleranceAfter: .zero)
    }

    func replacePlayerItemWith(urlStr: String?) {
        guard let urlStr = urlStr else {
            removePlayerItemObserver()
            removePeriodicTimeObserver()
            return
        }
        guard let videoUrl = URL(string: urlStr) else {
            removePlayerItemObserver()
            removePeriodicTimeObserver()
            return
        }
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let asset = AVURLAsset.init(url: videoUrl, options: nil)
            let keys = ["playable"]
            self?.currentAsset = asset

            asset.loadValuesAsynchronously(forKeys: keys) {
                DispatchQueue.main.async {
                    if asset.statusOfValue(forKey: "playable", error: nil) == .loaded {
                        let item = AVPlayerItem.init(asset: asset)
                        self?.replaceItem(item)
                    } else {
//                        elog.debug("💚 AVURLAsset load error")
                    }
                }
            }
        }

    }

    func replaceItem(_ item: AVPlayerItem?) {
        guard item != nil else {
            playerItem = nil
            removePlayerItemObserver()
            removePeriodicTimeObserver()
            return
        }

        playerItem = item
        // 希望缓存多少秒的视频数据，减小这个值可 降低播放的启动延迟
        playerItem?.preferredForwardBufferDuration = 16

        player?.pause()
        player?.seek(to: .zero)

        player?.replaceCurrentItem(with: item)
        
        didPlayToEndFlag = false  // 复位

        addPlayerItemObserver()
        addPeriodicTimeObserver()
    }
}

// MARK: - 监听各种状态
extension FZAVPlayerProcessor {

    // KVO
    override func observeValue(
        forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?,
        context: UnsafeMutableRawPointer?
    ) {

        guard let avPlayer = self.player else { return }

        if keyPath == "status" {
            if let item = object as? AVPlayerItem {
                if item.status == .failed {
                    debugPrint("播放错误: \(item.error?.localizedDescription ?? "未知错误")")
                }
            }
            delegate?.observe(status: avPlayer.status)
            //            debugPrint("pdd--status:", avPlayer.status)

        } else if keyPath == "rate" {
            delegate?.observe(rate: avPlayer.rate)
            //            debugPrint("pdd--rate:", avPlayer.rate)

        } else if keyPath == "loadedTimeRanges" {  // 缓冲进度
            if let timeRanges = avPlayer.currentItem?.loadedTimeRanges as? [NSValue],
                let timeRange = timeRanges.first?.timeRangeValue
            {
                delegate?.observe(timeRange: timeRange)
            }

        } else if keyPath == "playbackBufferEmpty" {  //
            debugPrint("pdd -正在缓冲 -rate:", avPlayer.rate)
            delegate?.observePlaybackBufferEmpty()

        } else if keyPath == "playbackLikelyToKeepUp" {  // 缓冲好了 继续播放
            if let item = object as? AVPlayerItem {
                if item.isPlaybackLikelyToKeepUp {
                    debugPrint("pdd 缓冲好了 继续播放")
                    delegate?.observePlaybackLikelyToKeepUp()
                    if playingState{
                        setRate(rateBySetting)  // 必须。fix：倍速 复位 问题
                    }
                }
            }
        }
    }

    private func addPeriodicTimeObserver() {
        removePeriodicTimeObserver()

        guard player != nil else { return }

        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        playingTimeObserver = player?.addPeriodicTimeObserver(
            forInterval: interval, queue: DispatchQueue.main
        ) { [weak self] time in
            //            debugPrint("pdd PeriodicTimeObserver")
            guard let strongSelf = self else { return }
            guard let avPlayer = strongSelf.player else { return }

            let currentTime = CMTimeGetSeconds(avPlayer.currentTime())
            let totalTime = CMTimeGetSeconds(avPlayer.currentItem?.duration ?? CMTime.zero)

            //                        debugPrint("pdd PeriodicTime: ", currentTime, "===", totalTime)
            if totalTime > 0 && currentTime >= 0 {  // to avoid division by zero
                strongSelf.delegate?.observePeriodicTime(
                    totalDuration: totalTime, currentDuration: currentTime)
                strongSelf.playingCurrentTime = currentTime
                
                // 判断是否 播放完毕
//                if floor(currentTime) == floor(totalTime) {
//                    strongSelf.videoEnd()
//                }
            }
        }
    }

    func handlingInterruptions() {
    }

    private func addStatusObserver() {

        player?.addObserver(self, forKeyPath: "rate", options: .new, context: nil)
 
        NotificationCenter.default.addObserver(
            self, selector: #selector(applicationBecomeActive),
            name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(
            self, selector: #selector(applicationEnterBackground),
            name: UIApplication.didEnterBackgroundNotification, object: nil)
 
    }

    private func addPlayerItemObserver() {
        removePlayerItemObserver()  // 移除
        debugPrint("pdd addPlayer ItemObserver")
        addObserversItemFlag = true
        
        player?.currentItem?.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        player?.currentItem?.addObserver(
            self, forKeyPath: "loadedTimeRanges", options: .new, context: nil)
        player?.currentItem?.addObserver(
            self, forKeyPath: "playbackBufferEmpty", options: .new, context: nil)
        player?.currentItem?.addObserver(
            self, forKeyPath: "playbackLikelyToKeepUp", options: .new, context: nil)

        if let playerItem = player?.currentItem {
            debugPrint("pdd addObserver DidplayToEndTime")
            NotificationCenter.default.addObserver(
                self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime,
                object: playerItem)
        }
    }

    private func removeStatusObserver() {
        //        debugPrint("pdd removeStatusObserver")
        
        player?.removeObserver(self, forKeyPath: "rate", context: nil)
 
        NotificationCenter.default.removeObserver(
            self, name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.removeObserver(
            self, name: UIApplication.didEnterBackgroundNotification, object: nil)
    }

    private func removePlayerItemObserver() {

        if player?.currentItem?.observationInfo != nil && addObserversItemFlag {
                    debugPrint("pdd removePlayer ItemObserver")

            player?.currentItem?.removeObserver(self, forKeyPath: "status", context: nil)
            player?.currentItem?.removeObserver(self, forKeyPath: "loadedTimeRanges", context: nil)
            player?.currentItem?.removeObserver(
                self, forKeyPath: "playbackBufferEmpty", context: nil)
            player?.currentItem?.removeObserver(
                self, forKeyPath: "playbackLikelyToKeepUp", context: nil)
        }

        NotificationCenter.default.removeObserver(
            self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
        
        addObserversItemFlag = false

    }

    private func removePeriodicTimeObserver() {
        guard let player = player, let observer = playingTimeObserver else { return }
        //        debugPrint("pdd removeTimeObserver")
        // 移除观察者
        player.removeTimeObserver(observer)
        // 清空令牌
        playingTimeObserver = nil
    }

    @objc func playerDidFinishPlaying(note: NSNotification) {
//        player?.seek(to: .zero)   // ！！
        
        guard didPlayToEndFlag else {
            didPlayToEndFlag = true

            delegate?.observeDidPlayToEndTime()
            return
        }
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
