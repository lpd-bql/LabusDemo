//
//  Untitled.swift
//  ElmApp
//
//  Created by lpd on 2024/12/30.
//  Copyright © 2024 Enabot Technology (Shenzhen) Company Limited. All rights reserved.
//


import UIKit
import SnapKit


protocol FZMediaControlDelegate: AnyObject {
    
    func mediaControlOnClickPlay()
//    func mediaControlOnClickContinue()
    func mediaControlOnClickPause()
    func mediaControlOnClickRate(rate: Float)
    func mediaControlOnSliderBegan()
    func mediaControlOnSliderChangedWith(relativeValue: Float)
    func mediaControlOnSliderCancelledWith(relativeValue: Float, updateUIWasCalledWhenSliding: Bool)
    func mediaControlOnSliderEndedWith(relativeValue: Float, updateUIWasCalledWhenSliding: Bool)
}

protocol FZPlayerControlViewDelegate: AnyObject {
    func mediaControlOnClickFullScreen()
    func mediaControlOnClickExitFullScreen()
}

class FZPlayerControlView: UIView {
    weak var viewDelegate: FZPlayerControlViewDelegate?
    weak var controlDelegate: FZMediaControlDelegate?

    static let defaultSliderHeight: CGFloat = 48
    static let defaultBtnHeight: CGFloat = 44
    static let defaultPortraitHeight: CGFloat = defaultSliderHeight + defaultBtnHeight
    static let defaultLandscapeHeight: CGFloat = defaultSliderHeight
    
    static let twoPartsLabelWidth: CGFloat = 44
    static let threePartsLabelWidth: CGFloat = 66
    
    var touchAreaInsetDx: CGFloat = -20
    var touchAreaInsetDy: CGFloat = -20
    
    private(set) var isSliding: Bool = false
    private(set) var updateUIWasCalledWhenSliding: Bool = false

    private var currentTimeLabelWidthConstraint: Constraint?
    private var durationTimeLabelWidthConstraint: Constraint?
    private var lastShowThreeParts: Bool = false // fale表示 "00:00", true表示 "00:00:00"
    
    private var speedRate: Float = 1.0
    private var speedRates: [Float] = [1.0, 2.0, 4.0, 8.0]

    private lazy var currentTimeLabel: UILabel = {
        let view = UILabel(frame: .zero)
        view.font = UIFont.systemFont(ofSize: 13.0)
        view.textColor = .white
        view.text = "00:00"
        view.textAlignment = .center
        return view
    }()

    private lazy var durationTimeLabel: UILabel = {
        let view = UILabel(frame: .zero)
        view.font = UIFont.systemFont(ofSize: 13.0)
        view.textColor = .white
        view.text = "00:00"
        view.textAlignment = .center
        return view
    }()
    
    private lazy var controlBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "MediaPlayIcon"), for: .normal)
        btn.setImage(UIImage(named: "MediaPlayIconHighlighted"), for: .highlighted)
        btn.setImage(UIImage(named: "MediaPauseIcon"), for: .selected)
        btn.setImage(UIImage(named: "MediaPauseIconHighlighted"), for: [.selected, .highlighted])
        btn.imageView?.contentMode = .scaleAspectFit
        btn.addTarget(self, action: #selector(self.onClickControlBtn(_:)), for: .touchUpInside)
        return btn
    }()
    
    
    private lazy var slider: PointableSlider = {
        let slider = PointableSlider(frame: .zero)
        slider.minimumValue = 0
        slider.maximumValue = 100
        slider.value = 0
        // 小于滑块当前值滑块条的颜色
        slider.minimumTrackTintColor = UIColor.cyan
        // 大于滑块当前值滑块条的颜色
        slider.maximumTrackTintColor = .white.withAlphaComponent(0.4)
        
        slider.addTarget(self, action: #selector(self.onSliderChange(slider:event:)), for: .valueChanged)
        return slider
    }()
    
    private lazy var timeSliderBox: UIView = {
        let v = UIView()
        v.addSubview(currentTimeLabel)
        v.addSubview(durationTimeLabel)
        v.addSubview(slider)

        currentTimeLabel.snp.remakeConstraints { make in
            make.top.bottom.leading.equalToSuperview()
            currentTimeLabelWidthConstraint = make.width.equalTo(FZPlayerControlView.twoPartsLabelWidth).constraint
        }
        
        durationTimeLabel.snp.remakeConstraints { make in
            make.top.bottom.trailing.equalToSuperview()
            durationTimeLabelWidthConstraint = make.width.equalTo(FZPlayerControlView.twoPartsLabelWidth).constraint
        }
        
        slider.snp.remakeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalTo(currentTimeLabel.snp.trailing).offset(12)
            make.trailing.equalTo(durationTimeLabel.snp.leading).offset(-12)
        }
        
        return v
    }()
    
    private lazy var fullScreenBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "MediaFullScreenIcon"), for: .normal)
        btn.setImage(UIImage(named: "MediaFullScreenIconHighlighted"), for: .highlighted)
        btn.imageView?.contentMode = .scaleAspectFit
        btn.addTarget(self, action: #selector(self.onClickFullScreenBtn(_:)), for: .touchUpInside)
        return btn
    }()
    
    private lazy var exitFullScreenBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "MediaExitFullScreenIcon"), for: .normal)
        btn.setImage(UIImage(named: "MediaExitFullScreenIconHighlighted"), for: .highlighted)
        btn.imageView?.contentMode = .scaleAspectFit
        btn.addTarget(self, action: #selector(self.onClickExitFullScreenBtn(_:)), for: .touchUpInside)
        return btn
    }()
     
    private lazy var rateBtn: UIButton = {
        let view = UIButton()
        view.addTarget(self, action: #selector(self.onClickRateBtn(_:)), for: .touchUpInside)
        view.setTitle("1x", for: .normal)
        view.setTitleColor(.white, for: .normal)
        view.titleLabel?.font = .boldSystemFont(ofSize: 15)
        view.titleLabel?.shadowColor = UIColor(hex: 0x666666).withAlphaComponent(0.3)
        view.titleLabel?.shadowOffset = CGSize(width: 1, height: 1)
        view.layer.cornerRadius = 4
        view.layer.masksToBounds = true
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.borderWidth = 1.5
        return view
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        commonInit()
    }
    
    
    @objc func onClickControlBtn(_ btn: UIButton) {
        btn.isSelected = !btn.isSelected

        /// btn.isSelected 与isPlaying一致
        if btn.isSelected {
            controlDelegate?.mediaControlOnClickPlay()
//            controlDelegate?.mediaControlOnClickContinue()
        } else {
            controlDelegate?.mediaControlOnClickPause()
        }
    }
    
    @objc func onClickRateBtn(_ btn: UIButton) {
        if var index: Int = speedRates.firstIndex(of: speedRate) {
            if index + 1 < speedRates.count {
                index += 1
            } else {
                index = 0
            }
            if index < speedRates.count {
                setSpeedRate(rate: speedRates[index])
            } else {
                setSpeedRate(rate: 1.0)
            }
        } else {
            setSpeedRate(rate: 1.0)
        }
        controlDelegate?.mediaControlOnClickRate(rate: speedRate)
    }
    
    
    @objc func onClickFullScreenBtn(_ btn: UIButton) {
     
        viewDelegate?.mediaControlOnClickFullScreen()
    }
    
    @objc func onClickExitFullScreenBtn(_ btn: UIButton) {
 
        viewDelegate?.mediaControlOnClickExitFullScreen()
    }
    
    @objc func onSliderChange(slider: UISlider, event: UIEvent) {
        guard let touch = event.allTouches?.first else { return }
        switch touch.phase {
        case .began:
            isSliding = true
            updateUIWasCalledWhenSliding = false // 清空flag
            controlDelegate?.mediaControlOnSliderBegan()
        case .moved, .stationary:
            let relative: Float = slider.getRelativeValue()
            controlDelegate?.mediaControlOnSliderChangedWith(relativeValue: relative)
        case .cancelled:
            isSliding = false
            let relative: Float = slider.getRelativeValue()
            controlDelegate?.mediaControlOnSliderCancelledWith(relativeValue: relative, updateUIWasCalledWhenSliding: updateUIWasCalledWhenSliding)
        case .ended:
            isSliding = false
            let relative: Float = slider.getRelativeValue()
            controlDelegate?.mediaControlOnSliderEndedWith(relativeValue: relative, updateUIWasCalledWhenSliding: updateUIWasCalledWhenSliding)
        case .regionEntered, .regionMoved, .regionExited:
            break
        @unknown default:
            break
        }
    }
}
extension FZPlayerControlView {
    /// 当forceThreeParts为true的时候，强制显示格式"00:01:01"
    static func getVideoDurationStr(secondsInt: Int64, forceThreeParts: Bool) -> String {
        let seconds: Double = Double(secondsInt)
        return getVideoDurationStr(seconds: seconds, forceThreeParts: forceThreeParts)
    }
    
    static func getVideoDurationStr(seconds: Double, forceThreeParts: Bool) -> String {
        guard seconds >= 0 else {
            if forceThreeParts {
                return "00:00:00"
            }
            return "00:00"
        }
        let max: Double = 59 + 59 * 60 + 99 * 60 * 60
        guard seconds <= max else {
            /// 359999
            return "99:59:59"
        }
        var time: String = "00:00"
        if seconds > 3600 || forceThreeParts {
            time = String(format:"%02d:%02d:%02d",
                Int(seconds / 3600),
                Int((seconds / 60).truncatingRemainder(dividingBy: 60)),
                Int(seconds.truncatingRemainder(dividingBy: 60)))
        } else {
            time = String(format:"%02d:%02d",
                Int((seconds / 60).truncatingRemainder(dividingBy: 60)),
                Int(seconds.truncatingRemainder(dividingBy: 60)))
        }
        return time
    }
}

extension FZPlayerControlView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        return super.hitTest(point, with: event)
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let hitFrame = bounds.insetBy(dx: self.touchAreaInsetDx, dy: self.touchAreaInsetDy)
        return hitFrame.contains(point)
    }
}

extension FZPlayerControlView {
    
    func updateUI(isPlaying: Bool) {
        /// 注意：controlBtn.isSelected 与isPlaying一致
        if isPlaying {
            self.controlBtn.isSelected = true
        } else {
            self.controlBtn.isSelected = false
        }
    }
    
    func setSpeedRate(rate: Float) {
        if speedRates.contains(rate) {
            speedRate = rate
        } else {
            speedRate = 1.0
        }
        let rateInt: Int = Int(rate)
        rateBtn.setTitle(String(format: "%d", rateInt) + "x", for: .normal)
    }
    
    func getSpeedRate() -> Float {
        return speedRate
    }
    
    private func updateConstraintsForTimeLabel(showThreeParts: Bool) {
        if showThreeParts {
            currentTimeLabelWidthConstraint?.update(offset: FZPlayerControlView.threePartsLabelWidth)
            durationTimeLabelWidthConstraint?.update(offset: FZPlayerControlView.threePartsLabelWidth)
        } else {
            currentTimeLabelWidthConstraint?.update(offset: FZPlayerControlView.twoPartsLabelWidth)
            durationTimeLabelWidthConstraint?.update(offset: FZPlayerControlView.twoPartsLabelWidth)
        }
    }
    
    func updateUI(durationTime: Double, currentTime: Double, isPlaying: Bool, skipSlider: Bool) {
        let duration: Double = durationTime
        var current: Double = currentTime
        if current > duration {
            /// 强制异常修正。
            current = 0
        }
        if current < 0 {
            /// 强制异常修正。
            current = 0
        }
        let showThreeParts: Bool = duration > 3600
        if self.lastShowThreeParts == showThreeParts {
            /// 节约开销
            /// updateConstraintsForTimeLabel(showThreeParts: showThreePart
        } else {
            self.lastShowThreeParts = showThreeParts
            updateConstraintsForTimeLabel(showThreeParts: showThreeParts)
        }

        let durationStr: String = FZPlayerControlView.getVideoDurationStr(seconds: duration, forceThreeParts: showThreeParts)
        let currentStr: String = FZPlayerControlView.getVideoDurationStr(seconds: current, forceThreeParts: showThreeParts)
        durationTimeLabel.text = durationStr
        currentTimeLabel.text = currentStr

        updateUI(isPlaying: isPlaying)

        guard !skipSlider else {  return }
        
        guard !self.isSliding else {
            /// 用户滑动中，有外部其他方法调用了updateUI，不能调用setValue。
            updateUIWasCalledWhenSliding = true
            return
        }
        
        //  update slider
        if duration > 0 {
            let relative: Float = Float(current / duration)
            let range: Float = self.slider.maximumValue - self.slider.minimumValue
            let newValue: Float = relative * range + self.slider.minimumValue
            if range > 0 {
                self.slider.setValue(newValue, animated: true)
            } else {
                self.slider.setValue(0, animated: false)
            }
        } else {
            self.slider.setValue(0, animated: false)
        }
    }
    
    func updateLocalPlayer(withTotalDuration totalDuration: Double, currentDuration: Double) {
        let progress = currentDuration / totalDuration
        let convertedValue = progress * 100
        durationTimeLabel.text = totalDuration.durationFormatted
        currentTimeLabel.text = currentDuration.durationFormatted
        
        guard !self.isSliding else {
            /// 用户滑动中，有外部其他方法调用了updateUI，不能调用setValue。
            updateUIWasCalledWhenSliding = true
            return
        }
        slider.setValue(Float(convertedValue), animated: true)
    }
    
    func updateLocalPlayer(withDefaultTotalDuration duration: Double) {
        durationTimeLabel.text = duration.durationFormatted
    }
}

extension FZPlayerControlView {
    
    private func commonInit() {
        addSubview(timeSliderBox)
        timeSliderBox.addSubview(currentTimeLabel)
        timeSliderBox.addSubview(durationTimeLabel)
        timeSliderBox.addSubview(slider)
        
        addSubview(controlBtn)
        addSubview(fullScreenBtn)
        addSubview(exitFullScreenBtn)
        addSubview(rateBtn)
    }
    
    func hideSliderBox() {
        timeSliderBox.isHidden = true
    }
    
    /// 只调用一次（横屏时调用
    func applyLandscapeUI() {
        controlBtn.snp.remakeConstraints { make in
            make.centerY.leading.equalToSuperview()
            make.size.equalTo(CGSize(width: FZPlayerControlView.defaultBtnHeight, height: FZPlayerControlView.defaultBtnHeight))
        }
        exitFullScreenBtn.snp.remakeConstraints { make in
            make.centerY.trailing.equalToSuperview()
            make.size.equalTo(controlBtn)
        }
        
        rateBtn.snp.remakeConstraints { make in
            make.centerY.equalTo(exitFullScreenBtn)
            make.trailing.equalTo(exitFullScreenBtn.snp.leading).offset(-12)
            make.size.equalTo(CGSize(width: FZPlayerControlView.defaultBtnHeight - 2, height: FZPlayerControlView.defaultBtnHeight/2))
        }
        
        timeSliderBox.snp.remakeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalTo(controlBtn.snp.trailing)
            make.trailing.equalTo(rateBtn.snp.leading).offset(-12)
        }
        
        exitFullScreenBtn.isHidden = false
        fullScreenBtn.isHidden = true
    }
    
    /// 只调用一次（竖屏时
    func applyPortaitUI() {
        controlBtn.snp.remakeConstraints { make in
            make.bottom.leading.equalToSuperview()
            make.size.equalTo(CGSize(width: FZPlayerControlView.defaultBtnHeight, height: FZPlayerControlView.defaultBtnHeight))
        }
        fullScreenBtn.snp.remakeConstraints { make in
            make.bottom.trailing.equalToSuperview()
            make.size.equalTo(controlBtn)
        }
        
        rateBtn.snp.remakeConstraints { make in
            make.centerY.equalTo(fullScreenBtn)
            make.trailing.equalTo(fullScreenBtn.snp.leading).offset(-12)
            make.size.equalTo(CGSize(width: FZPlayerControlView.defaultBtnHeight - 2, height: FZPlayerControlView.defaultBtnHeight/2))
        }
        
        timeSliderBox.snp.remakeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(controlBtn.snp.top)
        }
         
        
        exitFullScreenBtn.isHidden = true
        fullScreenBtn.isHidden = false
    }
}


extension Double {
    var durationFormatted: String {
        let hours = Int(self / 3600)
        let minutes = Int((self.truncatingRemainder(dividingBy: 3600)) / 60)
        let seconds = Int(self.truncatingRemainder(dividingBy: 60))

        var result = ""
        if hours > 0 {
            result += String(format: "%02d:", hours)
        }
        result += String(format: "%02d:%02d", minutes, seconds)
        return result
    }
}


extension UISlider {
    /// [0, 1]之间的相对值
    func getRelativeValue() -> Float {
        let value: Float = self.value
        let diff: Float = value - self.minimumValue
        let range: Float = self.maximumValue - self.minimumValue
        return range > 0 ? diff / range : 0
    }
}
 
class PointableSlider: UISlider {
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        return true
    }
}
