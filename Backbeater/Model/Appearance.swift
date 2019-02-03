//
//  ColorPalete.swift
//  Backbeater
//
//  Created by Alina Kholcheva on 2019-01-08.
//  Copyright © 2019 Alina Kholcheva. All rights reserved.
//

import Foundation

let BORDER_WIDTH_THIN:CGFloat = 2.5 // UI elements border width
let BORDER_WIDTH:CGFloat = 3.2 // UI elements border width


enum ColorPalette: Int {
    case black          = 0x262626
    case pink           = 0xDD2F44
    case grey           = 0x4C4C4C
    case keyboardBg     = 0xC7CDD1
    case keyboardBorder = 0xE7E7E7
    
    var color: UIColor {
        return UIColor(hex: self.rawValue)
    }
    
    var cgColor: CGColor {
        return UIColor(hex: self.rawValue).cgColor
    }
    
}

