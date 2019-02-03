//
//  CollectionExtension.swift
//  Backbeater
//
//  Created by Alina Kholcheva on 2019-01-12.
//  Copyright © 2019 Alina Kholcheva. All rights reserved.
//

import Foundation

extension Collection where Indices.Iterator.Element == Index {
    
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
    
    func isSafe(index:Index) -> Bool {
        return indices.contains(index)
    }
}
