//
//  AnyObjectExtensions.swift
//
//  Created by Alina on 10/11/14.
//

import Foundation

extension Int {
    func inBounds(#minValue:Int, maxValue:Int) -> Int {
        return Swift.max(minValue, Swift.min(maxValue, self))
    }
}