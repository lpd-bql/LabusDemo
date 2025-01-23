//
//  Untitled.swift
//  ElmApp
//
//  Created by lpd on 2024/12/30.
//  Copyright © 2024 Enabot Technology (Shenzhen) Company Limited. All rights reserved.
//


import UIKit

class FZVideoPlayerLandscapeVC: UIViewController {
    
    var playerProcessor = FZAVPlayerProcessor()
    var titleStr: String = ""

    var isHideToolFlag: Bool = false
      
    lazy var playerContainerView: FZAVPlayLayerView = {
        let view = FZAVPlayLayerView()
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapViewAction))
        view.addGestureRecognizer(tap)
        return view
    }()
    
    lazy var mediaControlView: FZPlayerControlView = {
        let view = FZPlayerControlView(frame: .zero)
        return view
    }()
    
    lazy var bufferSpinner: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .medium)
        view.color = .white
        view.isHidden = true
        return view
    } ()
    
    override func viewDidLoad() {
        super.viewDidLoad()
         
        setUpSubviews()
        configVideo()

    }
     
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        /// 为了让程序更健壮，这里多加一个冗余的lockOrientation
//        ELMUIUtils.lockOrientation([.landscapeRight, .landscapeLeft])
        lockOrientation([.landscapeRight, .landscapeLeft], andRotateTo: .landscapeRight)
        UIApplication.shared.isIdleTimerDisabled = true
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.isBeingDismissed || self.isMovingFromParent {
            navigationController?.navigationBar.isHidden = true
            lockOrientation(UIInterfaceOrientationMask.portrait, andRotateTo: .portrait)
        }
    }
    
    func lockOrientation(_ orientationMask: UIInterfaceOrientationMask, andRotateTo rotateOrientation: UIInterfaceOrientation) {
       
       var intermediateOrientation: UIInterfaceOrientation = UIInterfaceOrientation.portrait
       
       if intermediateOrientation == rotateOrientation {
           /// intermediateOrientation 必须与 rotateOrientation 不一样，这样才能触发系统通知
           intermediateOrientation = UIInterfaceOrientation.landscapeRight
       }
        
       UIDevice.current.setValue(intermediateOrientation.rawValue, forKey: "orientation")
       UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
       UIViewController.attemptRotationToDeviceOrientation()
    }
    
    func configVideo() {
        if let player = self.playerProcessor.player {
            self.playerContainerView.player = player
        }
    }
    
    public func exitFullScreenAction() {

//        navigationController?.popViewController(animated: false)
//        ELMUIUtils.lockOrientation(UIInterfaceOrientationMask.portrait, andRotateTo: .portrait)
    }
    
    public func checkHideToolView() {
        isHideToolFlag = !isHideToolFlag

        mediaControlView.isHidden = isHideToolFlag
    }
    
    @objc func tapViewAction() {
        
        checkHideToolView()
    }
    
    @objc func backAction(_ btn: UIButton) {
        exitFullScreenAction()
    }
    
}


extension FZVideoPlayerLandscapeVC{
    
    private func setUpSubviews() {
        view.backgroundColor = .black
        view.addSubview(playerContainerView)
        playerContainerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        view.addSubview(bufferSpinner)
        bufferSpinner.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(CGSize(width: 50, height: 50))
        }
         
         
        view.addSubview(mediaControlView)
        mediaControlView.snp.makeConstraints { make in
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).offset(10)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).offset(-10)
            make.height.equalTo(FZPlayerControlView.defaultLandscapeHeight)
            make.bottom.equalToSuperview().offset(-20)
        }
        mediaControlView.applyLandscapeUI()
        
    }
}
