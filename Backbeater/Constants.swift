//
//  Constants.swift
//  Backbeater
//
//  Created by Alina on 2015-06-04.
//  Copyright (c) 2015 Samsung Accelerator. All rights reserved.
//

import UIKit


enum ColorPalette: String {
    case
    Black = "262626",
    Pink = "#DD2F44",
    Grey = "#4C4C4C"
    
    func color() -> UIColor {
        return UIColor(hexString: self.rawValue)
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