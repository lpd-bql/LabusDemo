//
//  FZAVPlayLayerView.swift
//  ElmApp
//
//  Created by lpd on 2025/1/10.
//  Copyright © 2025 Enabot Technology (Shenzhen) Company Limited. All rights reserved.
//

import AVKit

class FZAVPlayLayerView : UIView {
    // AVPlayerLayer使用自动布局：https://cloud.tencent.com/developer/ask/sof/102182036
    var player: AVPlayer? {
        get {
            return (self.layer as? AVPlayerLayer)?.player
        }
        set(newPlayer) {
            (self.layer as? AVPlayerLayer)?.player = newPlayer
        }
    }

    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
}
 
