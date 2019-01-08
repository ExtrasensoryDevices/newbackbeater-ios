//
//  StringExtension.swift
//  Backbeater
//
//  Created by Alina Khgolcheva on 2015-06-19.
//

import Foundation

extension String {
    func trim() -> String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
}
