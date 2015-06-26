//
//  StringExtension.swift
//  Backbeater
//
//  Created by Alina on 2015-06-19.
//

import Foundation

extension String {
    func trim() -> String {
        return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }
}