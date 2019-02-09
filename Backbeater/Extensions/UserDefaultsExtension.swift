//
//  UserDefaultsExtension.swift
//  Backbeater
//
//  Created by Alina Kholcheva on 2019-01-28.
//  Copyright © 2019 Alina Kholcheva. All rights reserved.
//

import Foundation

extension UserDefaults {
    enum Key:String {
        case sensitivity         = "sensitivity"
        case strikesWindowIndex  = "strikesWindowSelectedIndex"
        case timeSignatureIndex  = "timeSignatureSelectedIndex"
        case metronomeSoundIndex = "metronomeSoundSelectedIndex"
        
        case metronomeTempo  = "metronomeTempo"
        case lastPlayedTempo = "lastPlayedTempo"
        
        case songList = "songList"
    }
    
    // Int
    static func set(integer: Int, for key: UserDefaults.Key) {
        let  userDefaults = UserDefaults.standard
        userDefaults.set(integer, forKey: key.rawValue)
        userDefaults.synchronize()
    }
    static func integer(for key: UserDefaults.Key) -> Int? {
        if UserDefaults.standard.object(forKey: key.rawValue) != nil {
            return UserDefaults.standard.integer(forKey: key.rawValue)
        } else {
            return nil
        }
    }
    
    // Object
    static func set(data: Data?, for key: UserDefaults.Key) {
        let  userDefaults = UserDefaults.standard
        userDefaults.set(data, forKey: key.rawValue)
        userDefaults.synchronize()
    }
    static func data(for key: UserDefaults.Key) -> Any? {
        return UserDefaults.standard.data(forKey: key.rawValue)
    }
}
