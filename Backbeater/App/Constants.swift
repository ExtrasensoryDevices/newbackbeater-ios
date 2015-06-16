//
//  Constants.swift
//  Backbeater
//
//  Created by Alina on 2015-06-04.
//  Copyright (c) 2015 Samsung Accelerator. All rights reserved.
//

import UIKit

struct SongTempo {
    var songName:String
    var tempoValue:Int
}

let DEFAULT_TEMPO = 120


enum ColorPalette: Int {
    case
    Black = 0x262626,
    Pink = 0xDD2F44,
    Grey = 0x4C4C4C
    
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