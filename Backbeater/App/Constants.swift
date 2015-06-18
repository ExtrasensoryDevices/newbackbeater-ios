//
//  Constants.swift
//  Backbeater
//
//  Created by Alina on 2015-06-04.
//

import UIKit

struct SongTempo {
    var songName:String
    var tempoValue:Int
}

let DEFAULT_TEMPO = 120
let HELP_URL = "http://www.google.com"


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
    SteelfishReg = "SteelfishRg-Regular"
    
    func get(size: CGFloat) -> UIFont {
        return UIFont(name: self.rawValue, size: size)!
    }
}

let BORDER_WIDTH:CGFloat = 2.5

let CHECK_INTERVAL_SECONDS = 60.0 * 15
let PLIST_URL = "https://tm9.io/sticki/Sticki.plist"