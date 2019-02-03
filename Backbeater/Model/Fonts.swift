//
//  Fonts.swift
//  Backbeater
//
//  Created by Alina Kholcheva on 2019-01-08.
//  Copyright © 2019 Alina Kholcheva. All rights reserved.
//

import Foundation

enum Font: String {
    case FuturaDemi  = "FuturaRound-Demi"
    case FuturaBook  = "FuturaRound-Book"
    case SteelfishRg = "SteelfishRg-Regular"
    
    func get(_ size: CGFloat) -> UIFont {
        return UIFont(name: self.rawValue, size: size)!
    }
}
