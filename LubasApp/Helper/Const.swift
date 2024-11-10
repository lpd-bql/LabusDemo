//
//  Const.swift
//  LubasApp
//
//  Created by Pidong Ling on 2024/10/15.
//

import UIKit



// MARK: App
let kAppConnectID = "xxxxxxxxxxxx"

let kAppLoginToken = "xxxxxxxxxxxxxxxx"

let kAppUserDefaults = UserDefaults.standard

let kAppMainWindow = UIApplication.shared.delegate?.window


// MARK: - Cell ID

let kWaterFallCellID = "WaterFallCellID"


/// App下载链接
/// - Returns: 地址
func kURLAppStoreDownload() -> (String) {
    return "https://itunes.apple.com/app/id" + kAppConnectID
}


// MARK: UserDefault Key

let kUserDefaultKeyForToken = "UserDefaultKeyForToken"
