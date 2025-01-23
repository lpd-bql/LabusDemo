//
//  Untitled.swift
//  ElmApp
//
//  Created by lpd on 2024/12/30.
//  Copyright © 2024 Enabot Technology (Shenzhen) Company Limited. All rights reserved.
//


import UIKit
import AVFoundation
//import Toast_Swift

class FZVideoPlayerVC: UIViewController {
    var urlStr: String = ""
    var titleStr: String = ""
    var coverImage: UIImage?
//    var isConfigShareBtn: Bool = true
//    var fileModel: FZRobotFileDBModel?
    
    var playerProcessor: FZAVPlayerProcessor = FZAVPlayerProcessor()
    
    private weak var landscapeVC: FZVideoPlayerLandscapeVC?
     
    
    lazy var playerContainerView: FZAVPlayLayerView = {
        let view = FZAVPlayLayerView()
        let tap = UITapGestureRecognizer(target: self, action: #selector(fullScreenAction))
        view.addGestureRecognizer(tap)
        return view
    }()
    
    lazy var mediaControlView: FZPlayerControlView = {
        let view = FZPlayerControlView(frame: .zero)
        view.viewDelegate = self
        view.controlDelegate = self
        return view
    }()
    
    lazy var bufferSpinner: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .large)
        view.color = .white
        view.isHidden = true
        return view
    } ()
    
    override func viewDidLoad() {
        super.viewDidLoad()
           
        configVideo()
        
        setUpSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mediaControlView.isHidden = false
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        mediaControlView.isHidden = true
    }
    
    func configVideo() {
        showBufferActivity()
        
        playerProcessor.delegate = self
        playerProcessor.setUpVideoPlayerWith(urlStr: urlStr)
        
        playerContainerView.player = playerProcessor.player
    }
    
    @objc func fullScreenAction() {
        
//        let vc = SEGen2VideoPlayerLandscapeVC()  // FZVideoPlayerLandscapeVC()
//        vc.titleStr = titleStr
//        vc.fileModel = fileModel
//        vc.playerProcessor = playerProcessor
//
//        navigationController?.pushViewController(vc, animated: false)
//        
//        landscapeVC = vc
//        landscapeVC?.mediaControlView.viewDelegate = self
//        landscapeVC?.mediaControlView.controlDelegate = self
//        // 初始化数据
//        landscapeVC?.mediaControlView.updateUI(isPlaying: playerProcessor.isPlaying())
//        landscapeVC?.mediaControlView.setSpeedRate(rate: mediaControlView.getSpeedRate())
//        
//        if let avPlayer = playerProcessor.player {
//            let currentTime = CMTimeGetSeconds(avPlayer.currentTime())
//            let totalTime = CMTimeGetSeconds(avPlayer.currentItem?.duration ?? CMTime.zero)
//            guard currentTime >= 0 && totalTime >= 0 else {
//                return
//            }
//            landscapeVC?.mediaControlView.updateLocalPlayer(withTotalDuration: totalTime, currentDuration: currentTime)
//        }
    }
       

}

// MARK: FZAVPlayerProcessorDelegate
extension FZVideoPlayerVC: FZAVPlayerProcessorDelegate {
    
    func observe(status: AVPlayer.Status) {
        switch status {
            case .unknown:
                break
            case .readyToPlay:
                hideBufferActivity()
                mediaPlay()
            case .failed:
                hideBufferActivity()
                mediaControlViewUpdateUI(isPlaying: false)
                 
            @unknown default:
                break
        }
    }
    
    func observePeriodicTime(totalDuration: Double, currentDuration: Double) {
        
        mediaControlView.updateLocalPlayer(withTotalDuration: totalDuration, currentDuration: currentDuration)
        landscapeVC?.mediaControlView.updateLocalPlayer(withTotalDuration: totalDuration, currentDuration: currentDuration)

    }
    
    func observeDidPlayToEndTime() {
        playerProcessor.seekTo(relativeValue: 0)
        mediaPause()
    }
    
    func observe(timeRange: CMTimeRange) {
        // 缓存进度
    }
    
    func observePlaybackBufferEmpty() {
        showBufferActivity()
    }
    
    func observePlaybackLikelyToKeepUp() {
        hideBufferActivity()
        if playerProcessor.isPlaying() {
            mediaPlay()
        }
    }
    
    func observeApplicationBecomeActive(isPlayVideo: Bool) {
        mediaPlay()
    }
    
    func observeApplicationEnterBackground(isPauseVideo: Bool) {
        mediaPause()
    }
}

// MARK: FZMediaControlDelegate
extension FZVideoPlayerVC: FZMediaControlDelegate {
    
    func mediaControlOnClickPlay() {
        mediaPlay()
    }
    
    func mediaControlOnClickPause() {
        mediaPause()
    }
    func mediaControlOnClickRate(rate: Float) {
        mediaControlView.setSpeedRate(rate: rate)
        mediaPlay()
    }
    
    func mediaControlOnSliderBegan() {}
    
    func mediaControlOnSliderChangedWith(relativeValue: Float) {
        playerProcessor.seekTo(relativeValue: relativeValue)
    }
    func mediaControlOnSliderCancelledWith(relativeValue: Float, updateUIWasCalledWhenSliding: Bool) {
        if updateUIWasCalledWhenSliding && playerProcessor.isPlaying() {
            mediaPlay()
        }
    }
    func mediaControlOnSliderEndedWith(relativeValue: Float, updateUIWasCalledWhenSliding: Bool) {
        if updateUIWasCalledWhenSliding && playerProcessor.isPlaying() {
            mediaPlay()
        }
    }
}

// MARK: FZPlayerControlViewDelegate
extension FZVideoPlayerVC: FZPlayerControlViewDelegate {
    
    func mediaControlOnClickFullScreen() {
        fullScreenAction()
    }
    func mediaControlOnClickExitFullScreen() {
        landscapeVC?.exitFullScreenAction()
    }
}

extension FZVideoPlayerVC {
    
    private func mediaPlay() {
        playerProcessor.play()
        playerProcessor.player?.rate = mediaControlView.getSpeedRate()
        mediaControlViewUpdateUI(isPlaying: true)
    }
    
    private func mediaPause() {
        playerProcessor.pause()
        mediaControlViewUpdateUI(isPlaying: false)
    }
    
    private func mediaControlViewUpdateUI(isPlaying: Bool) {
        mediaControlView.updateUI(isPlaying: isPlaying)
        landscapeVC?.mediaControlView.updateUI(isPlaying: isPlaying)
    }
    
    func showBufferActivity() {
        bufferSpinner.isHidden = false
        landscapeVC?.bufferSpinner.isHidden = false
    }
    
    func hideBufferActivity() {
        bufferSpinner.isHidden = true
        landscapeVC?.bufferSpinner.isHidden = true
    }
}


extension FZVideoPlayerVC {
    
    private func setUpSubviews() {
        view.backgroundColor = .black
         
        
        view.addSubview(playerContainerView)
         
        view.addSubview(bufferSpinner)
        bufferSpinner.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(CGSize(width: 50, height: 50))
        }
        
        
        view.addSubview(mediaControlView)
        mediaControlView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(FZPlayerControlView.defaultPortraitHeight)
            make.bottom.equalToSuperview().offset(-34)
        }
        mediaControlView.applyPortaitUI()
        
        DispatchQueue.global().async {
            if let aspect = self.playerProcessor.videoScale {   // 防卡顿
                DispatchQueue.main.async {
                    self.playerContainerView.snp.makeConstraints { make in
                        make.center.width.equalToSuperview()
                        let screenW = UIScreen.main.bounds.width
                        make.height.equalTo(screenW/aspect)
                    }
                }
            }
        }
        
    }
    
}
