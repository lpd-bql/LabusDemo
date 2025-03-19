//
//  FZCommonTableCellActionType.swift
//  ElmApp
//
//  Created by lpd on 2025/2/25.
//  Copyright © 2025 Enabot Technology (Shenzhen) Company Limited. All rights reserved.
//


enum FZCommonTableCellActionType {
    // 眼灯设置页
    case eyesLampSwitch
    case eyesLampCustomPush
    case eyesLampFreeStateTimeTick
    case eyesLampFreeStateEmojiTick
    case eyesLampFreeStateEmojiSet 
    case eyesLampSportStateEmojiTick
    case eyesLampSportStateEmojiSet
    case eyesLampBrightnessSet
    
    // 自动回充设置
    case autoRechargManual   // 手动
    case autoRechargAuto     // 自动
    case autoRechargSwitch
    case autoRechargTime
    
    // 设备设置
    case settingNotDisturb
    case settingVolume
    case settingWatermark
    case settingReboot
    case settingCleanSD
    
    // 定时录制 设置
    case timedRecordPush
    case timedRecordArea
    case timedRecordResolution  // 分辨率
    case timedRecordResolution2K
    case timedRecordResolutionSpeek
    case timedRecordSensitivity
    // 侦测灵敏度
    case detectSensitivityHigh
    case detectSensitivityMid
    case detectSensitivityLow
    
    // WiFi管理
    case wifiConfig
    case wifiRoam
    case wifiCheck

    // 其他....
    case other
    
    /// 提醒设置
    case reminderRepeat
    case reminderName
    case reminderSound
    case reminderTime
    case reminderRecord
    
    /// AI看护
    case personMoved
    case petFound
    case deviceMoved
    case screenChanged
    case timePeriod
    case aiCareRepeat
    case aiCareNotification
    case anomalyWarning
}
