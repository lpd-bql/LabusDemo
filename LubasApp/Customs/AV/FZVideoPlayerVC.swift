//
//  Untitled.swift
//  ElmApp
//
//  Created by lpd on 2024/12/30.
//  Copyright © 2024 Enabot Technology (Shenzhen) Company Limited. All rights reserved.
//

import AVFoundation
import UIKit

class FZVideoPlayerVC: UIViewController {
    var urlStr: String = ""
    var titleStr: String = ""
    var coverImage: UIImage?
    var isConfigShareBtn: Bool = true
    var fileModel: FZRobotFileDBModel?

    var playerProcessor: FZAVPlayerProcessor = FZAVPlayerProcessor()

    private weak var landscapeVC: FZVideoPlayerLandscapeVC?

    lazy var shareBtn: UIButton = {
        let btn = UIButton()
//        btn.setImage(UIImage(named: ImageSet.rcVideoShareIcon), for: .normal)
        btn.addTarget(self, action: #selector(shareAction(_:)), for: .touchUpInside)
        return btn
    }()

    lazy var infoBtn: UIButton = {
        let view = UIButton()
//        view.setImage(.fz.imgName(light: "", dark: "iconInfoWhite"), for: .normal)
        view.addTarget(self, action: #selector(infoAction(_:)), for: .touchUpInside)
        return view
    }()

    lazy var playerContainerView: FZAVPlayLayerView = {
        let view = FZAVPlayLayerView()
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapContainerAction))
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
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

//        setNavBarTitle(titleStr)
//
//        darkLightStyle()

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

    deinit {
        playerProcessor.removeObservers()
    }

    func configVideo() {
        showBufferActivity()

        playerProcessor.delegate = self

        playerProcessor.setUpVideoPlayer()

        playerProcessor.replacePlayerItemWith(urlStr: urlStr)

        playerContainerView.player = playerProcessor.player
    }

    @objc func tapContainerAction() {
        mediaControlView.removeRateList()

        enterFullscreen()
    }

    func enterFullscreen() {

//        let vc = SEGen2VideoPlayerLandscapeVC()  // FZVideoPlayerLandscapeVC()
//        vc.titleStr = titleStr
//        vc.fileModel = fileModel
//        vc.playerProcessor = playerProcessor
//        vc.hideSpeedBtn()   // 暂时不需要 倍速
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
//            landscapeVC?.mediaControlView.updateLocalPlayer(
//                withTotalDuration: totalTime, currentDuration: currentTime)
//        }
    }

    @objc func shareAction(_ btn: UIButton) {
        // 获取分享的封面
        shareInfo(titleStr: titleStr, urlStr: urlStr, coverImage: coverImage)
    }

    private func shareInfo(titleStr: String, urlStr: String, coverImage: UIImage?) {
        var activityItems: [Any] = []
        let text = titleStr
        var image = UIImage()   //EBOImageUtils.getGrayPlaceHolderImage()
        if let cover = coverImage {
            image = cover
        }
        guard let url = URL(string: urlStr) else {
            return
        }
        activityItems = [text, image, url]
        let activityVC = UIActivityViewController(
            activityItems: activityItems, applicationActivities: nil)
        // 如果是ipad, 那么需要使用pop的方式显示方向界面

        present(activityVC, animated: true, completion: nil)
    }

    @objc func infoAction(_ btn: UIButton) {
 
    }

}

// MARK: FZAVPlayerProcessorDelegate
extension FZVideoPlayerVC: FZAVPlayerProcessorDelegate {
    func observe(rate: Float) {

    }

    func observe(status: AVPlayer.Status) {
        switch status {
        case .unknown:
            break
        case .readyToPlay:
            print("pdd FZ VideoPlayerVC readyToPlay")
            hideBufferActivity()
//            mediaPlay()
        case .failed:
            hideBufferActivity()
            mediaControlViewUpdateUI(isPlaying: false)
             
        @unknown default:
            break
        }
    }

    func observePeriodicTime(totalDuration: Double, currentDuration: Double) {

        debugPrint("pdd  FZ VideoPlayerVC", currentDuration, "==", totalDuration)
        print("pdd FZ VideoPlayerVC rate:", playerProcessor.player?.rate)
        mediaControlView.updateLocalPlayer(
            withTotalDuration: totalDuration, currentDuration: currentDuration)
        landscapeVC?.mediaControlView.updateLocalPlayer(
            withTotalDuration: totalDuration, currentDuration: currentDuration)
    }

    func observeDidPlayToEndTime() {
        print("pdd FZ VideoPlayerVC PlayToEndTime")
        playerProcessor.seekTo(relativeValue: 0)
        mediaPause()
        playerProcessor.replaceItem(nil)
    }

    func observe(timeRange: CMTimeRange) {
        // 缓存进度
    }

    func observePlaybackBufferEmpty() {
        print("pdd FZ VideoPlayerVC observePlaybackBufferEmpty")
        showBufferActivity()
    }

    func observePlaybackLikelyToKeepUp() {
        print("pdd FZ VideoPlayerVC observePlaybackLikelyToKeepUp")
        hideBufferActivity()
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
        if let _ = playerProcessor.playerItem {
            mediaPlay()   // 继续播
        }else{
            playerProcessor.replacePlayerItemWith(urlStr: urlStr)  // 重播
            mediaPlay()
        }
        
    }

    func mediaControlOnClickPause() {
        mediaPause()
    }
    func mediaControlOnClickRate(rate: Float) {
        debugPrint("pdd av mediaControlOnClickRate: ", rate)

        mediaControlView.setSpeedRate(rate: rate)
 
        playerProcessor.setRate(rate)
    }

    func mediaControlOnSliderBegan() {
        mediaPause()  // 开始拖，先暂停
    }

    func mediaControlOnSliderChangedWith(relativeValue: Float) {
        mediaPause()
        //        playerProcessor.seekTo(relativeValue: relativeValue)
        let total = playerProcessor.currentItemDuration
        let sec = total * relativeValue
        mediaControlView.updateUI(
            durationTime: Double(total), currentTime: Double(sec), isPlaying: false,
            skipSlider: true)

    }
    func mediaControlOnSliderCancelledWith(relativeValue: Float, updateUIWasCalledWhenSliding: Bool)
    {
        if updateUIWasCalledWhenSliding {  //} && playerProcessor.isPlaying() {
            mediaPause()
        }
    }
    func mediaControlOnSliderEndedWith(relativeValue: Float, updateUIWasCalledWhenSliding: Bool) {
        if updateUIWasCalledWhenSliding {
            playerProcessor.seekTo(relativeValue: relativeValue)
            mediaPlay()
        }
    }
}

// MARK: FZPlayerControlViewDelegate
extension FZVideoPlayerVC: FZPlayerControlViewDelegate {

    func mediaControlOnClickFullScreen() {
        enterFullscreen()
    }
    func mediaControlOnClickExitFullScreen() {
        landscapeVC?.exitFullScreenAction()
    }
}

extension FZVideoPlayerVC {

    private func mediaPlay() {
        playerProcessor.play()
        let rate = mediaControlView.getSpeedRate()
        playerProcessor.setRate(rate)
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
        bufferSpinner.startAnimating()
        landscapeVC?.bufferSpinner.isHidden = false
        landscapeVC?.bufferSpinner.startAnimating()

    }

    func hideBufferActivity() {
        bufferSpinner.isHidden = true
        bufferSpinner.stopAnimating()
        landscapeVC?.bufferSpinner.isHidden = true
        landscapeVC?.bufferSpinner.stopAnimating()

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
            var adapt = 1.25
            if let aspect = self.playerProcessor.videoScale {  // 防卡顿
                adapt = aspect
            }
            DispatchQueue.main.async {
                self.playerContainerView.snp.makeConstraints { make in
                    make.center.width.equalToSuperview()
                    let screenW = UIScreen.main.bounds.width
                    make.height.equalTo(screenW / adapt)
                }
            }
        }

    }

}

 
extension FZVideoPlayerVC {
    func hideSpeedBtn(){
        mediaControlView.speedRateIsHidden = true
    }
}
