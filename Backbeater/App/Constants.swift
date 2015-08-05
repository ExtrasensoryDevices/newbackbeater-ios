//
//  Constants.swift
//  Backbeater
//
//  Created by Alina on 2015-06-04.
//

import UIKit

struct SongTempo: Equatable {
    var songName:String
    var tempoValue:Int
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




func ==(lhs: SongTempo, rhs: SongTempo) -> Bool {
    return lhs.songName == rhs.songName && lhs.tempoValue == rhs.tempoValue
}


@objc class SoundConstant {
    private init() {}
    
    class func DEFAULT_SENSITIVITY() -> Int {return 100}
    class func DEFAULT_TEMPO() -> Int {return 120}
    class func MAX_TEMPO() -> Int {return 221}
    class func MIN_TEMPO() -> Int {return 20}
}


let HELP_URL = "http://backbeater.com/m"
let BUY_SENSOR_URL = "http://www.backbeater.com"

let IDLE_TIMEOUT = 5.0


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

let BORDER_WIDTH:CGFloat = 2.5

let CHECK_INTERVAL_SECONDS = 60.0 * 5
let PLIST_URL = "https://backbeater.com/app/backbeater.plist"