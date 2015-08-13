//
//  Constants.swift
//  Backbeater
//
//  Created by Alina on 2015-06-04.
//

import UIKit


@objc class BridgeConstants:NSObject { // has to be that way to be used in objc sound processor part
    class func DEFAULT_SENSITIVITY() -> Int {return 100}
    class func DEFAULT_TEMPO() -> Int {return 120}
    class func MAX_TEMPO() -> Int {return 200}
    class func MIN_TEMPO() -> Int {return 20}
    
    class func FLURRY_API_KEY() -> String {return "DPF2V399HZKGGTKSG5Q2"}
}

// updater
let CHECK_INTERVAL_SECONDS = 60.0 * 5
let PLIST_URL = "https://backbeater.com/app/backbeater.plist"

// urls
let HELP_URL = "http://backbeater.com/apphelp/?app=ios"
let BUY_SENSOR_URL = "http://backbeater.com/appbuy/?app=ios"

let IDLE_TIMEOUT = 5.0

let BORDER_WIDTH_THIN:CGFloat = 2.5 // UI elements border width
let BORDER_WIDTH:CGFloat = 3.2 // UI elements border width


enum ColorPalette: Int {
    case
    Black = 0x262626,
    Pink = 0xDD2F44,
    Grey = 0x4C4C4C,
    KeyboardBg = 0xC7CDD1,
    KeyboardBorder = 0xE7E7E7
    
    func color() -> UIColor {
        return UIColor(hex: self.rawValue)
    }
    
}


enum Font: String {
    case FuturaDemi = "FuturaRound-Demi",
    FuturaBook = "FuturaRound-Book",
    SteelfishRg = "SteelfishRg-Regular"
    
    func get(size: CGFloat) -> UIFont {
        return UIFont(name: self.rawValue, size: size)!
    }
}



// Song/Tempo list

struct SongTempo: Equatable {
    var songName:String
    var tempoValue:Int
    
    init(songName: String, tempoValue:  Int) {
        self.songName = songName.uppercaseString
        self.tempoValue = tempoValue
    }
}


func ==(lhs: SongTempo, rhs: SongTempo) -> Bool {
    return lhs.songName == rhs.songName && lhs.tempoValue == rhs.tempoValue
}


func prepareToSaveSongTempoList(songList:[SongTempo]?) -> [NSDictionary]? {
    if songList == nil {
        return nil
    }
    var result = [NSDictionary]()
    for songTempo in songList! {
        result.append(["songName": songTempo.songName, "tempoValue": songTempo.tempoValue])
    }
    return result
}

func restoreSongTempoList(songList:[NSDictionary]?) -> [SongTempo]? {
    if songList == nil {
        return nil
    }
    var result = [SongTempo]()
    for songTempo in songList! {
        let songName =  songTempo["songName"] as! String
        let tempoValue =  songTempo["tempoValue"] as! Int
        
        result.append(SongTempo(songName:songName, tempoValue: tempoValue))
    }
    return result
}


// Analytics


@objc class FlurryEvent: NSObject {
    class func APP_OPENED() -> String {return "app_opened"}
    class func APP_CLOSED() -> String {return "app_closed"}
    class func TEMPO_LIST_CREATED() -> String {return "tempo_list_created"}
    class func METRONOME_STATE_CHANGED() -> String {return "metronome_state_changed"}
    class func SENSITIVITY_VALUE_CHANGED() -> String {return "sensitivity_value_changed"}
    class func STRIKES_WINDOW_VALUE_CHANGED() -> String {return "strikes_window_value_changed"}
    class func TIME_SIGNATURE_VALUE_CHANGED() -> String {return "time_signature_value_changed"}
    class func METRONOME_TEMPO_VALUE_CHANGED() -> String {return "metronome_tempo_value_changed"}
}


