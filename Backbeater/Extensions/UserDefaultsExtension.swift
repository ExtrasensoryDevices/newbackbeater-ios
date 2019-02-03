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
        return UserDefaults.standard.integer(forKey: key.rawValue)
    }
    
    // Object
    static func set(object: Any?, for key: UserDefaults.Key) {
        let  userDefaults = UserDefaults.standard
        userDefaults.set(object, forKey: key.rawValue)
        userDefaults.synchronize()
    }
    static func object(for key: UserDefaults.Key) -> Any? {
        return UserDefaults.standard.object(forKey: key.rawValue)
    }
}
