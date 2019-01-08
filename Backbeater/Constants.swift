//
//  Constants.swift
//  Backbeater
//
//  Created by Alina Khgolcheva on 2015-06-04.
//

import UIKit


@objcMembers
public class Constants: NSObject {
    public static let DEFAULT_SENSITIVITY:Int = 100
    public static let DEFAULT_TEMPO:Int       = 120
    
    public static let MAX_TEMPO:Int           = 200
    public static let MIN_TEMPO:Int           =  20
    
    public static let IDLE_TIMEOUT:Double     =  10.0
}


// urls
let HELP_URL = "http://backbeater.com/apphelp/?app=ios"
let BUY_SENSOR_URL = "http://backbeater.com/appbuy/?app=ios"

let BORDER_WIDTH_THIN:CGFloat = 2.5 // UI elements border width
let BORDER_WIDTH:CGFloat = 3.2 // UI elements border width


enum ColorPalette: Int {
    case
    black = 0x262626,
    pink = 0xDD2F44,
    grey = 0x4C4C4C,
    keyboardBg = 0xC7CDD1,
    keyboardBorder = 0xE7E7E7
    
    func color() -> UIColor {
        return UIColor(hex: self.rawValue)
    }
    
}


enum Font: String {
    case FuturaDemi = "FuturaRound-Demi"
    case FuturaBook = "FuturaRound-Book"
    case SteelfishRg = "SteelfishRg-Regular"
    
    func get(_ size: CGFloat) -> UIFont {
        return UIFont(name: self.rawValue, size: size)!
    }
}



// Song/Tempo list

struct SongTempo: Equatable {
    var songName:String
    var tempoValue:Int
    
    init(songName: String, tempoValue:  Int) {
        self.songName = songName.uppercased()
        self.tempoValue = tempoValue
    }
}


func ==(lhs: SongTempo, rhs: SongTempo) -> Bool {
    return lhs.songName == rhs.songName && lhs.tempoValue == rhs.tempoValue
}


func prepareToSaveSongTempoList(_ songList:[SongTempo]?) -> [NSDictionary]? {
    if songList == nil {
        return nil
    }
    var result = [NSDictionary]()
    for songTempo in songList! {
        result.append(["songName": songTempo.songName, "tempoValue": songTempo.tempoValue])
    }
    return result
}

func restoreSongTempoList(_ songList:[NSDictionary]?) -> [SongTempo]? {
    if songList == nil {
        return nil
    }
    
    var result = [SongTempo]()
    for songTempo in songList! {
        let songName =  songTempo["songName"] as! String
        let tempoValue =  songTempo["tempoValue"] as! Int
        
        result.append(SongTempo(songName:songName, tempoValue: tempoValue))
    }
    return result.count > 0 ? result : nil
}


// Analytics

let FLURRY_API_KEY = "DPF2V399HZKGGTKSG5Q2"


@objcMembers
class FlurryEvent: NSObject {
    public static let APP_OPENED  = "app_opened"
    public static let APP_CLOSED = "app_closed"
    
    public static let TEMPO_LIST_CREATED = "tempo_list_created"
    
    public static let METRONOME_STATE_CHANGED       = "metronome_state_changed"
    public static let SENSITIVITY_VALUE_CHANGED     = "sensitivity_value_changed"
    public static let STRIKES_WINDOW_VALUE_CHANGED  = "strikes_window_value_changed"
    public static let TIME_SIGNATURE_VALUE_CHANGED  = "time_signature_value_changed"
    public static let METRONOME_TEMPO_VALUE_CHANGED = "metronome_tempo_value_changed"
}


