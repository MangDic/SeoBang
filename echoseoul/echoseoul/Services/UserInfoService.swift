//
//  UserInfoService.swift
//  echoseoul
//
//  Created by 이명직 on 2023/05/19.
//

import Foundation

class UserInfoService {
    static let shared = UserInfoService()

    let userNickNameKey = "UserNickName"
    let regionKey = "Region"
    let uuidKey = "UUID"
    let clearKey = "Clear"

    var userNickName: String {
        get {
            return UserDefaults.standard.string(forKey: userNickNameKey) ?? "Null"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: userNickNameKey)
        }
    }
    
    var region: String {
        get {
            return UserDefaults.standard.string(forKey: regionKey) ?? "강남구"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: regionKey)
        }
    }
    
    var uuid: String {
        if let uuid = UserDefaults.standard.string(forKey: uuidKey) {
            return uuid
        } else {
            let newUUID = UUID().uuidString
            UserDefaults.standard.set(newUUID, forKey: uuidKey)
            return newUUID
        }
    }
    
    var clearCount: Int {
        get {
            return Int(UserDefaults.standard.string(forKey: clearKey) ?? "0")!
        }
        set {
            UserDefaults.standard.set(newValue, forKey: clearKey)
        }
    }
    
    func updateUserInfo(userNickName: String, region: String) {
        self.userNickName = userNickName
        self.region = region
    }
}

